#include "tinycpu_mmio.h"

#define WIDTH 10u
#define HEIGHT 20u
#define CELLS (WIDTH * HEIGHT)

#define INPUT_FINISH (1u << 7)

static void clear_board(void) {
    for (unsigned int i = 0; i < CELLS; i++) {
        TINYCPU_FRAMEBUFFER[i] = 0;
    }
}

static void draw_input(unsigned int value) {
    clear_board();

    for (unsigned int bit = 0; bit < 8u; bit++) {
        unsigned char cell = (value & (1u << bit)) ? (unsigned char)(bit + 1u) : 0u;
        TINYCPU_FRAMEBUFFER[bit] = cell;
        TINYCPU_FRAMEBUFFER[WIDTH + bit] = cell;
    }
}

int main(void) {
    unsigned int frame = 0;
    TINYCPU_TEST_CODE = 0;

    while (1) {
        unsigned int input = TINYCPU_HOST_INPUT;

        draw_input(input);
        TINYCPU_APP_STATUS = 1u | 8u;
        TINYCPU_APP_VALUE0 = input;
        TINYCPU_APP_VALUE1 = input & 0xffu;
        TINYCPU_FRAME_COUNTER = frame;
        TINYCPU_COMMAND_ACK = input;

        if (input & INPUT_FINISH) {
            TINYCPU_TEST_STATUS = 1;
        }

        frame++;
    }
}
