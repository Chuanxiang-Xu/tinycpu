// Minimal PYNQ-Z2 pin smoke test.
//
// This top intentionally bypasses the CPU/SoC. Use it when basic board IO must
// be proven before debugging the tinycpu datapath.
module pynqz2_pin_smoke_top (
    input  logic       sysclk,
    input  logic [3:0] btn,
    input  logic [1:0] sw,
    output logic [3:0] led
);

    logic [25:0] heartbeat_counter;

    always_ff @(posedge sysclk) begin
        heartbeat_counter <= heartbeat_counter + 26'd1;
    end

    assign led[0] = sw[0];
    assign led[1] = sw[1];
    assign led[2] = btn[0];
    assign led[3] = heartbeat_counter[25];

    wire unused_buttons = ^btn[3:1];

endmodule
