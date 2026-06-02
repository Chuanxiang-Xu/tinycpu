#include <stdint.h>

#define TINYCPU_LED (*(volatile uint32_t *)0x10000000u)
#define TINYCPU_SW  (*(volatile uint32_t *)0x10000004u)

static volatile uint32_t sink;

int main(void)
{
    for (;;) {
        uint32_t sw = TINYCPU_SW & 0x03u;
        uint32_t row = 7u + sw;
        uint32_t col = 3u;
        uint32_t width = 10u;
        uint32_t index = row * width + col;
        uint32_t piece = (123u + sw) % 7u;
        int32_t signed_q = ((int32_t)index - 100) / 3;
        int32_t signed_r = ((int32_t)index - 100) % 3;

        sink = index + piece + (uint32_t)signed_q + (uint32_t)signed_r;
        TINYCPU_LED = sink & 0x0fu;
    }
}
