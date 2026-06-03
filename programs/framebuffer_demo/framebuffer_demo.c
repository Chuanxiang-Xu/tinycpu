#include "tinycpu_mmio.h"

#define BOARD_WIDTH 10
#define BOARD_HEIGHT 20
#define BOARD_CELLS (BOARD_WIDTH * BOARD_HEIGHT)

static void clear_board(void) {
    for (unsigned int i = 0; i < BOARD_CELLS; i++) {
        TINYCPU_FRAMEBUFFER[i] = 0;
    }
}

static void draw_frame(unsigned int frame) {
    unsigned int x = frame % (BOARD_WIDTH - 1);
    unsigned int y = (frame / 2u) % (BOARD_HEIGHT - 1);
    unsigned char color = (unsigned char)((frame % 7u) + 1u);

    clear_board();
    TINYCPU_FRAMEBUFFER[y * BOARD_WIDTH + x] = color;
    TINYCPU_FRAMEBUFFER[y * BOARD_WIDTH + x + 1u] = color;
    TINYCPU_FRAMEBUFFER[(y + 1u) * BOARD_WIDTH + x] = color;
    TINYCPU_FRAMEBUFFER[(y + 1u) * BOARD_WIDTH + x + 1u] = color;
}

int main(void) {
    TINYCPU_GAME_STATUS = 1;
    TINYCPU_TEST_CODE = 0;

    for (unsigned int frame = 0; frame < 16u; frame++) {
        draw_frame(frame);
        TINYCPU_FRAME_COUNTER = frame + 1u;
    }

    TINYCPU_TEST_STATUS = 1;

    while (1) {
        for (unsigned int spin = 0; spin < 512u; spin++) {
            __asm__ volatile ("nop");
        }
        unsigned int frame = TINYCPU_FRAME_COUNTER + 1u;
        draw_frame(frame);
        TINYCPU_FRAME_COUNTER = frame;
    }
}
