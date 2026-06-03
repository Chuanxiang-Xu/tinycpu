#ifndef TINYCPU_MMIO_H
#define TINYCPU_MMIO_H

#define TINYCPU_LED_REG          (*(volatile unsigned int *)0x10000000u)
#define TINYCPU_SWITCH_REG       (*(volatile unsigned int *)0x10000004u)

#define TINYCPU_HOST_INPUT       (*(volatile unsigned int *)0x10000010u)
#define TINYCPU_APP_STATUS       (*(volatile unsigned int *)0x10000014u)
#define TINYCPU_APP_VALUE0       (*(volatile unsigned int *)0x10000018u)
#define TINYCPU_APP_VALUE1       (*(volatile unsigned int *)0x1000001Cu)
#define TINYCPU_FRAME_COUNTER    (*(volatile unsigned int *)0x10000020u)
#define TINYCPU_COMMAND_ACK      (*(volatile unsigned int *)0x10000024u)

#define TINYCPU_FRAMEBUFFER      ((volatile unsigned char *)0x10000100u)

#define TINYCPU_TEST_STATUS      (*(volatile unsigned int *)0x10000FF0u)
#define TINYCPU_TEST_CODE        (*(volatile unsigned int *)0x10000FF4u)

#define TINYCPU_GAME_INPUT       TINYCPU_HOST_INPUT
#define TINYCPU_GAME_STATUS      TINYCPU_APP_STATUS
#define TINYCPU_GAME_SCORE       TINYCPU_APP_VALUE0

#endif
