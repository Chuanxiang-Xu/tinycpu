#include <stdint.h>

#define TINYCPU_LED (*(volatile uint32_t *)0x10000000u)
#define TINYCPU_SW  (*(volatile uint32_t *)0x10000004u)

int main(void)
{
    for (;;) {
        uint32_t sw = TINYCPU_SW;
        TINYCPU_LED = sw & 0x0fu;
    }
}
