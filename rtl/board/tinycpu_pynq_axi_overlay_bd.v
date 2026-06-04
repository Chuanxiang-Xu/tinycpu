// Verilog module-reference wrapper for Vivado block designs.
//
// Vivado BD module-reference cells expect a Verilog top file. This wrapper
// keeps the block-design boundary Verilog-only while instantiating the
// SystemVerilog implementation in tinycpu_pynq_axi_overlay.sv.
module tinycpu_pynq_axi_overlay_bd #(
    parameter RAM_HEX = "programs/led_switch_demo.hex",
    parameter integer RAM_INIT_WORDS = 4
) (
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,

    input  wire [3:0]  btn,
    input  wire [1:0]  sw,
    output wire [3:0]  led,

    input  wire [31:0] s_axi_awaddr,
    input  wire [2:0]  s_axi_awprot,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,

    input  wire [31:0] s_axi_araddr,
    input  wire [2:0]  s_axi_arprot,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output wire [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    input  wire        s_axi_rready
);

    tinycpu_pynq_axi_overlay #(
        .RAM_HEX(RAM_HEX),
        .RAM_INIT_WORDS(RAM_INIT_WORDS)
    ) impl_i (
        .s_axi_aclk   (s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .btn          (btn),
        .sw           (sw),
        .led          (led),
        .s_axi_awaddr (s_axi_awaddr),
        .s_axi_awprot (s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata  (s_axi_wdata),
        .s_axi_wstrb  (s_axi_wstrb),
        .s_axi_wvalid (s_axi_wvalid),
        .s_axi_wready (s_axi_wready),
        .s_axi_bresp  (s_axi_bresp),
        .s_axi_bvalid (s_axi_bvalid),
        .s_axi_bready (s_axi_bready),
        .s_axi_araddr (s_axi_araddr),
        .s_axi_arprot (s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata  (s_axi_rdata),
        .s_axi_rresp  (s_axi_rresp),
        .s_axi_rvalid (s_axi_rvalid),
        .s_axi_rready (s_axi_rready)
    );

endmodule
