// tinycpu-pynq v0.3-open-rv32im SoC.
//
// CPU AXI-Lite master -> AXI-Lite interconnect -> RAM/GPIO slaves.
module tinycpu_soc #(
    parameter RAM_HEX = "programs/led_switch_demo.hex"
) (
    input  logic       clk,
    input  logic       rst,
    input  logic [1:0] sw,
    output logic [3:0] led
);

    logic [31:0] m_awaddr;
    logic        m_awvalid;
    logic        m_awready;
    logic [31:0] m_wdata;
    logic [3:0]  m_wstrb;
    logic        m_wvalid;
    logic        m_wready;
    logic [1:0]  m_bresp;
    logic        m_bvalid;
    logic        m_bready;
    logic [31:0] m_araddr;
    logic        m_arvalid;
    logic        m_arready;
    logic [31:0] m_rdata;
    logic [1:0]  m_rresp;
    logic        m_rvalid;
    logic        m_rready;

    logic [31:0] ram_awaddr;
    logic        ram_awvalid;
    logic        ram_awready;
    logic [31:0] ram_wdata;
    logic [3:0]  ram_wstrb;
    logic        ram_wvalid;
    logic        ram_wready;
    logic [1:0]  ram_bresp;
    logic        ram_bvalid;
    logic        ram_bready;
    logic [31:0] ram_araddr;
    logic        ram_arvalid;
    logic        ram_arready;
    logic [31:0] ram_rdata;
    logic [1:0]  ram_rresp;
    logic        ram_rvalid;
    logic        ram_rready;

    logic [31:0] gpio_awaddr;
    logic        gpio_awvalid;
    logic        gpio_awready;
    logic [31:0] gpio_wdata;
    logic [3:0]  gpio_wstrb;
    logic        gpio_wvalid;
    logic        gpio_wready;
    logic [1:0]  gpio_bresp;
    logic        gpio_bvalid;
    logic        gpio_bready;
    logic [31:0] gpio_araddr;
    logic        gpio_arvalid;
    logic        gpio_arready;
    logic [31:0] gpio_rdata;
    logic [1:0]  gpio_rresp;
    logic        gpio_rvalid;
    logic        gpio_rready;

    tinycpu_core_rv32im_axil #(
        .RESET_PC(32'h0000_0000)
    ) core_i (
        .clk          (clk),
        .rst          (rst),
        .m_axi_awaddr (m_awaddr),
        .m_axi_awvalid(m_awvalid),
        .m_axi_awready(m_awready),
        .m_axi_wdata  (m_wdata),
        .m_axi_wstrb  (m_wstrb),
        .m_axi_wvalid (m_wvalid),
        .m_axi_wready (m_wready),
        .m_axi_bresp  (m_bresp),
        .m_axi_bvalid (m_bvalid),
        .m_axi_bready (m_bready),
        .m_axi_araddr (m_araddr),
        .m_axi_arvalid(m_arvalid),
        .m_axi_arready(m_arready),
        .m_axi_rdata  (m_rdata),
        .m_axi_rresp  (m_rresp),
        .m_axi_rvalid (m_rvalid),
        .m_axi_rready (m_rready)
    );

    axil_interconnect interconnect_i (
        .clk          (clk),
        .rst          (rst),
        .m_awaddr     (m_awaddr),
        .m_awvalid    (m_awvalid),
        .m_awready    (m_awready),
        .m_wdata      (m_wdata),
        .m_wstrb      (m_wstrb),
        .m_wvalid     (m_wvalid),
        .m_wready     (m_wready),
        .m_bresp      (m_bresp),
        .m_bvalid     (m_bvalid),
        .m_bready     (m_bready),
        .m_araddr     (m_araddr),
        .m_arvalid    (m_arvalid),
        .m_arready    (m_arready),
        .m_rdata      (m_rdata),
        .m_rresp      (m_rresp),
        .m_rvalid     (m_rvalid),
        .m_rready     (m_rready),
        .ram_awaddr   (ram_awaddr),
        .ram_awvalid  (ram_awvalid),
        .ram_awready  (ram_awready),
        .ram_wdata    (ram_wdata),
        .ram_wstrb    (ram_wstrb),
        .ram_wvalid   (ram_wvalid),
        .ram_wready   (ram_wready),
        .ram_bresp    (ram_bresp),
        .ram_bvalid   (ram_bvalid),
        .ram_bready   (ram_bready),
        .ram_araddr   (ram_araddr),
        .ram_arvalid  (ram_arvalid),
        .ram_arready  (ram_arready),
        .ram_rdata    (ram_rdata),
        .ram_rresp    (ram_rresp),
        .ram_rvalid   (ram_rvalid),
        .ram_rready   (ram_rready),
        .gpio_awaddr  (gpio_awaddr),
        .gpio_awvalid (gpio_awvalid),
        .gpio_awready (gpio_awready),
        .gpio_wdata   (gpio_wdata),
        .gpio_wstrb   (gpio_wstrb),
        .gpio_wvalid  (gpio_wvalid),
        .gpio_wready  (gpio_wready),
        .gpio_bresp   (gpio_bresp),
        .gpio_bvalid  (gpio_bvalid),
        .gpio_bready  (gpio_bready),
        .gpio_araddr  (gpio_araddr),
        .gpio_arvalid (gpio_arvalid),
        .gpio_arready (gpio_arready),
        .gpio_rdata   (gpio_rdata),
        .gpio_rresp   (gpio_rresp),
        .gpio_rvalid  (gpio_rvalid),
        .gpio_rready  (gpio_rready)
    );

    axil_ram #(
        .ADDR_WIDTH(16),
        .INIT_WORDS (4),
        .MEM_HEX   (RAM_HEX)
    ) ram_i (
        .clk          (clk),
        .rst          (rst),
        .s_axi_awaddr (ram_awaddr),
        .s_axi_awvalid(ram_awvalid),
        .s_axi_awready(ram_awready),
        .s_axi_wdata  (ram_wdata),
        .s_axi_wstrb  (ram_wstrb),
        .s_axi_wvalid (ram_wvalid),
        .s_axi_wready (ram_wready),
        .s_axi_bresp  (ram_bresp),
        .s_axi_bvalid (ram_bvalid),
        .s_axi_bready (ram_bready),
        .s_axi_araddr (ram_araddr),
        .s_axi_arvalid(ram_arvalid),
        .s_axi_arready(ram_arready),
        .s_axi_rdata  (ram_rdata),
        .s_axi_rresp  (ram_rresp),
        .s_axi_rvalid (ram_rvalid),
        .s_axi_rready (ram_rready)
    );

    axil_gpio #(
        .GPIO_BASE(32'h4000_0000)
    ) gpio_i (
        .clk          (clk),
        .rst          (rst),
        .s_axi_awaddr (gpio_awaddr),
        .s_axi_awvalid(gpio_awvalid),
        .s_axi_awready(gpio_awready),
        .s_axi_wdata  (gpio_wdata),
        .s_axi_wstrb  (gpio_wstrb),
        .s_axi_wvalid (gpio_wvalid),
        .s_axi_wready (gpio_wready),
        .s_axi_bresp  (gpio_bresp),
        .s_axi_bvalid (gpio_bvalid),
        .s_axi_bready (gpio_bready),
        .s_axi_araddr (gpio_araddr),
        .s_axi_arvalid(gpio_arvalid),
        .s_axi_arready(gpio_arready),
        .s_axi_rdata  (gpio_rdata),
        .s_axi_rresp  (gpio_rresp),
        .s_axi_rvalid (gpio_rvalid),
        .s_axi_rready (gpio_rready),
        .sw           (sw),
        .led          (led)
    );

endmodule
