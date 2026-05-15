// PYNQ-Z2 board top for tinycpu-pynq v0.4-fuller-rv32i-c-support.
//
// This module only adapts board pins to the SoC. CPU, memory, interconnect,
// and GPIO internals live under rtl/core, rtl/axil, and rtl/soc.
module pynqz2_top #(
    parameter RAM_HEX = "programs/led_switch_demo.hex",
    parameter integer RAM_INIT_WORDS = 4
) (
    input  logic       sysclk,
    input  logic [3:0] btn,
    input  logic [1:0] sw,
    output logic [3:0] led
);

    logic [3:0] soc_led;
    logic [25:0] heartbeat_counter;

    tinycpu_soc #(
        .RAM_HEX(RAM_HEX),
        .RAM_INIT_WORDS(RAM_INIT_WORDS)
    ) soc_i (
        .clk(sysclk),
        .rst(btn[0]),
        .sw (sw),
        .led(soc_led)
    );

    always_ff @(posedge sysclk) begin
        if (btn[0]) begin
            heartbeat_counter <= 26'd0;
        end else begin
            heartbeat_counter <= heartbeat_counter + 26'd1;
        end
    end

    assign led[1:0] = soc_led[1:0];
    assign led[2]   = btn[0];
    assign led[3]   = heartbeat_counter[25];

    wire unused_buttons = ^btn[3:1];
    wire unused_soc_led = ^soc_led[3:2];

endmodule
