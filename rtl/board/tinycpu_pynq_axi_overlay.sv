// PYNQ-Z2 overlay wrapper for the tinycpu AXI-Lite loader path.
//
// This module is intended to be used as a Vivado block-design module reference.
// The Zynq PS M_AXI_GP0 port drives S_AXI through an AXI interconnect, while
// tinycpu itself still sees the compact loader/control AXI-Lite signals.
module tinycpu_pynq_axi_overlay #(
    parameter RAM_HEX = "programs/led_switch_demo.hex",
    parameter integer RAM_INIT_WORDS = 4
) (
    input  logic        s_axi_aclk,
    input  logic        s_axi_aresetn,

    input  logic [3:0]  btn,
    input  logic [1:0]  sw,
    output logic [3:0]  led,

    input  logic [31:0] s_axi_awaddr,
    input  logic [2:0]  s_axi_awprot,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    input  logic [31:0] s_axi_araddr,
    input  logic [2:0]  s_axi_arprot,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready
);

    logic [3:0] soc_led;
    logic [25:0] heartbeat_counter;
    logic        rst;
    logic [31:0] loader_awaddr;
    logic [31:0] loader_araddr;

    assign rst = !s_axi_aresetn || btn[0];
    assign loader_awaddr = {15'h0000, s_axi_awaddr[16:0]};
    assign loader_araddr = {15'h0000, s_axi_araddr[16:0]};

    tinycpu_soc #(
        .RAM_HEX(RAM_HEX),
        .RAM_INIT_WORDS(RAM_INIT_WORDS)
    ) soc_i (
        .clk          (s_axi_aclk),
        .rst          (rst),
        .sw           (sw),
        .led          (soc_led),
        .s_axi_awaddr (loader_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata  (s_axi_wdata),
        .s_axi_wstrb  (s_axi_wstrb),
        .s_axi_wvalid (s_axi_wvalid),
        .s_axi_wready (s_axi_wready),
        .s_axi_bresp  (s_axi_bresp),
        .s_axi_bvalid (s_axi_bvalid),
        .s_axi_bready (s_axi_bready),
        .s_axi_araddr (loader_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata  (s_axi_rdata),
        .s_axi_rresp  (s_axi_rresp),
        .s_axi_rvalid (s_axi_rvalid),
        .s_axi_rready (s_axi_rready)
    );

    always_ff @(posedge s_axi_aclk) begin
        if (rst) begin
            heartbeat_counter <= 26'd0;
        end else begin
            heartbeat_counter <= heartbeat_counter + 26'd1;
        end
    end

    assign led[1:0] = soc_led[1:0];
    assign led[2]   = rst;
    assign led[3]   = heartbeat_counter[25];

    wire unused_axi_prot = ^{s_axi_awprot, s_axi_arprot};
    wire unused_buttons  = ^btn[3:1];
    wire unused_soc_led  = ^soc_led[3:2];
    wire unused_params   = ^RAM_INIT_WORDS[7:0];

endmodule
