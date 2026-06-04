#include "tinycpu_mmio.h"

#define WIDTH 10
#define HEIGHT 20
#define CELLS (WIDTH * HEIGHT)
#define NO_PIECE 7u

#define INPUT_LEFT       (1u << 0)
#define INPUT_RIGHT      (1u << 1)
#define INPUT_ROTATE     (1u << 2)
#define INPUT_SOFT_DROP  (1u << 3)
#define INPUT_HARD_DROP  (1u << 4)
#define INPUT_START      (1u << 5)
#define INPUT_PAUSE      (1u << 6)
#define INPUT_HOLD       (1u << 7)

#define STATUS_RUNNING        (1u << 0)
#define STATUS_GAME_OVER      (1u << 1)
#define STATUS_PAUSED         (1u << 2)
#define STATUS_FRAME_READY    (1u << 3)
#define STATUS_INPUT_CONSUMED (1u << 4)
#define STATUS_HOLD_USED      (1u << 5)

static const unsigned short shapes[7][4] = {
    {0x0F00u, 0x2222u, 0x00F0u, 0x4444u}, /* I */
    {0x8E00u, 0x6440u, 0x0E20u, 0x44C0u}, /* J */
    {0x2E00u, 0x4460u, 0x0E80u, 0xC440u}, /* L */
    {0x6600u, 0x6600u, 0x6600u, 0x6600u}, /* O */
    {0x6C00u, 0x4620u, 0x06C0u, 0x8C40u}, /* S */
    {0x4E00u, 0x4640u, 0x0E40u, 0x4C40u}, /* T */
    {0xC600u, 0x2640u, 0x0C60u, 0x4C80u}, /* Z */
};

static unsigned int board_words[(CELLS + 3) / 4];
static const unsigned int bag[7] = {0u, 3u, 5u, 2u, 6u, 1u, 4u};
static unsigned int bag_index;
static int piece_x;
static int piece_y;
static unsigned int piece_kind;
static unsigned int piece_rot;
static unsigned int next_piece;
static unsigned int hold_piece;
static unsigned int hold_used;
static unsigned int score;
static unsigned int lines;
static unsigned int frame;
static unsigned int gravity_count;
static unsigned int running;
static unsigned int paused;
static unsigned int game_over;
static unsigned int prev_input;

static unsigned int index_at(int x, int y) {
    return (unsigned int)y * WIDTH + (unsigned int)x;
}

static unsigned int board_get(unsigned int index) {
    unsigned int word = board_words[index >> 2];
    unsigned int shift = (index & 3u) << 3;
    return (word >> shift) & 0xFFu;
}

static void board_set(unsigned int index, unsigned int value) {
    unsigned int word_index = index >> 2;
    unsigned int shift = (index & 3u) << 3;
    unsigned int mask = 0xFFu << shift;
    board_words[word_index] =
        (board_words[word_index] & ~mask) | ((value & 0xFFu) << shift);
}

static unsigned int level(void) {
    unsigned int remaining = lines;
    unsigned int value = 0;

    while (remaining >= 10u && value < 20u) {
        remaining -= 10u;
        value++;
    }

    return value;
}

static unsigned int gravity_interval(void) {
    unsigned int lvl = level();
    return 512u > lvl * 20u ? 512u - lvl * 20u : 64u;
}

static unsigned int shape_cell(unsigned int kind, unsigned int rot, int x, int y) {
    unsigned int bit = (unsigned int)(15 - (y * 4 + x));
    return (shapes[kind][rot & 3u] >> bit) & 1u;
}

static unsigned int take_from_bag(void) {
    unsigned int value = bag[bag_index];

    bag_index++;
    if (bag_index >= 7u) {
        bag_index = 0;
    }

    return value;
}

static void clear_board(void) {
    for (unsigned int i = 0; i < (CELLS + 3u) / 4u; i++) {
        board_words[i] = 0;
    }
}

static int collides(unsigned int kind, unsigned int rot, int px, int py) {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (!shape_cell(kind, rot, x, y)) {
                continue;
            }

            int bx = px + x;
            int by = py + y;
            if (bx < 0 || bx >= WIDTH || by < 0 || by >= HEIGHT) {
                return 1;
            }
            if (board_get(index_at(bx, by))) {
                return 1;
            }
        }
    }

    return 0;
}

static void spawn_specific(unsigned int kind) {
    piece_kind = kind;
    piece_rot = 0;
    piece_x = 3;
    piece_y = 0;

    if (collides(piece_kind, piece_rot, piece_x, piece_y)) {
        running = 0;
        game_over = 1;
    }
}

static void spawn_next(void) {
    spawn_specific(next_piece);
    next_piece = take_from_bag();
    hold_used = 0;
}

static void reset_game(void) {
    clear_board();
    bag_index = 0;
    score = 0;
    lines = 0;
    frame = 0;
    gravity_count = 0;
    running = 1;
    paused = 0;
    game_over = 0;
    prev_input = 0;
    hold_piece = NO_PIECE;
    hold_used = 0;
    next_piece = take_from_bag();
    spawn_next();
    gravity_count = 0;
}

static void lock_piece(void) {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (shape_cell(piece_kind, piece_rot, x, y)) {
                int bx = piece_x + x;
                int by = piece_y + y;
                if (bx >= 0 && bx < WIDTH && by >= 0 && by < HEIGHT) {
                    board_set(index_at(bx, by), piece_kind + 1u);
                }
            }
        }
    }
}

static unsigned int clear_lines(void) {
    unsigned int cleared = 0;

    for (int y = HEIGHT - 1; y >= 0; y--) {
        unsigned int full = 1;
        for (int x = 0; x < WIDTH; x++) {
            if (!board_get(index_at(x, y))) {
                full = 0;
                break;
            }
        }

        if (full) {
            for (int row = y; row > 0; row--) {
                for (int x = 0; x < WIDTH; x++) {
                    board_set(index_at(x, row), board_get(index_at(x, row - 1)));
                }
            }
            for (int x = 0; x < WIDTH; x++) {
                board_set(index_at(x, 0), 0);
            }
            cleared++;
            y++;
        }
    }

    return cleared;
}

static void score_lines(unsigned int cleared) {
    static const unsigned int line_score[5] = {0, 100, 300, 500, 800};

    if (cleared > 4u) {
        cleared = 4u;
    }
    score += line_score[cleared] * (level() + 1u);
    lines += cleared;
}

static void lock_and_spawn(void) {
    lock_piece();
    score_lines(clear_lines());
    score += 1u;
    spawn_next();
    gravity_count = 0;
}

static unsigned int drop_distance(void) {
    unsigned int distance = 0;
    while (!collides(piece_kind, piece_rot, piece_x, piece_y + (int)distance + 1)) {
        distance++;
    }
    return distance;
}

static void gravity_step(void) {
    if (!running || paused || game_over) {
        return;
    }

    if (!collides(piece_kind, piece_rot, piece_x, piece_y + 1)) {
        piece_y++;
        return;
    }

    lock_and_spawn();
}

static void draw_shape(unsigned int kind, unsigned int rot, int px, int py,
                       unsigned char color, unsigned int only_empty) {
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            if (shape_cell(kind, rot, x, y)) {
                int bx = px + x;
                int by = py + y;
                if (bx >= 0 && bx < WIDTH && by >= 0 && by < HEIGHT) {
                    unsigned int idx = index_at(bx, by);
                    if (!only_empty || TINYCPU_FRAMEBUFFER[idx] == 0) {
                        TINYCPU_FRAMEBUFFER[idx] = color;
                    }
                }
            }
        }
    }
}

static void draw(void) {
    for (unsigned int i = 0; i < CELLS; i++) {
        TINYCPU_FRAMEBUFFER[i] = (unsigned char)board_get(i);
    }

    if (running && !game_over) {
        int ghost_y = piece_y + (int)drop_distance();
        draw_shape(piece_kind, piece_rot, piece_x, ghost_y, 8u, 1u);
        draw_shape(piece_kind, piece_rot, piece_x, piece_y,
                   (unsigned char)(piece_kind + 1u), 0u);
    }
}

static void publish(unsigned int consumed) {
    unsigned int status = STATUS_FRAME_READY;
    unsigned int hold_display = hold_piece == NO_PIECE ? 0u : hold_piece + 1u;
    unsigned int packed = (lines & 0xFFFFu) |
                          ((level() & 0xFFu) << 16) |
                          (((next_piece + 1u) & 0x0Fu) << 24) |
                          ((hold_display & 0x0Fu) << 28);

    if (running) {
        status |= STATUS_RUNNING;
    }
    if (paused) {
        status |= STATUS_PAUSED;
    }
    if (game_over) {
        status |= STATUS_GAME_OVER;
    }
    if (consumed) {
        status |= STATUS_INPUT_CONSUMED;
    }
    if (hold_used) {
        status |= STATUS_HOLD_USED;
    }

    TINYCPU_APP_STATUS = status;
    TINYCPU_APP_VALUE0 = score;
    TINYCPU_APP_VALUE1 = packed;
    TINYCPU_FRAME_COUNTER = frame;
}

static void frame_delay(void) {
    for (unsigned int spin = 0; spin < 512u; spin++) {
        __asm__ volatile ("nop");
    }
}

static unsigned int try_move(int dx, int dy) {
    if (!collides(piece_kind, piece_rot, piece_x + dx, piece_y + dy)) {
        piece_x += dx;
        piece_y += dy;
        return 1u;
    }
    return 0u;
}

static unsigned int try_rotate(void) {
    static const int kicks[5] = {0, -1, 1, -2, 2};
    unsigned int new_rot = (piece_rot + 1u) & 3u;

    for (unsigned int i = 0; i < 5u; i++) {
        int new_x = piece_x + kicks[i];
        if (!collides(piece_kind, new_rot, new_x, piece_y)) {
            piece_x = new_x;
            piece_rot = new_rot;
            return 1u;
        }
    }

    return 0u;
}

static unsigned int try_hold(void) {
    if (hold_used) {
        return 0u;
    }

    unsigned int old_hold = hold_piece;
    hold_piece = piece_kind;
    hold_used = 1;

    if (old_hold == NO_PIECE) {
        spawn_next();
        hold_used = 1;
        return 1u;
    }

    spawn_specific(old_hold);
    return 1u;
}

static unsigned int process_input(unsigned int input) {
    unsigned int edge = input & ~prev_input;
    unsigned int consumed = 0;

    if (edge & INPUT_START) {
        reset_game();
        consumed = 1;
    }
    if (!running || game_over) {
        prev_input = input;
        return consumed;
    }
    if (edge & INPUT_PAUSE) {
        paused ^= 1u;
        consumed = 1;
    }
    if (paused) {
        prev_input = input;
        return consumed;
    }
    if (edge & INPUT_HOLD) {
        consumed |= try_hold();
    }
    if (edge & INPUT_LEFT) {
        consumed |= try_move(-1, 0);
    }
    if (edge & INPUT_RIGHT) {
        consumed |= try_move(1, 0);
    }
    if (edge & INPUT_ROTATE) {
        consumed |= try_rotate();
    }
    if (input & INPUT_SOFT_DROP) {
        if (try_move(0, 1)) {
            score += 1u;
            consumed = 1;
        }
    }
    if (edge & INPUT_HARD_DROP) {
        unsigned int distance = drop_distance();
        piece_y += (int)distance;
        score += distance * 2u;
        lock_and_spawn();
        consumed = 1;
    }

    prev_input = input;
    return consumed;
}

int main(void) {
    reset_game();
    TINYCPU_TEST_CODE = 0;

    while (1) {
        unsigned int input = TINYCPU_HOST_INPUT;
        unsigned int consumed = process_input(input);

        if (running && !paused && !game_over) {
            gravity_count++;
            if (gravity_count >= gravity_interval()) {
                gravity_count = 0;
                gravity_step();
            }
        }

        publish(consumed);
        draw();
        frame++;
        frame_delay();
    }
}
