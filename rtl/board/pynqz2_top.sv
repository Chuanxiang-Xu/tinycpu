// PYNQ-Z2 board top for tinycpu-pynq v0.3-open-rv32im.
//
// This module only adapts board pins to the SoC. CPU, memory, interconnect,
// and GPIO internals live under rtl/core, rtl/axil, and rtl/soc.
module pynqz2_top (
    input  logic       sysclk,
    input  logic [3:0] btn,
    input  logic [1:0] sw,
    output logic [3:0] led
);

    tinycpu_soc #(
        .RAM_HEX("programs/led_switch_demo.hex")
    ) soc_i (
        .clk(sysclk),
        .rst(btn[0]),
        .sw (sw),
        .led(led)
    );

    wire unused_buttons = ^btn[3:1];

endmodule
