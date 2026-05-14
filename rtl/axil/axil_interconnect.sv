// One-master, two-slave AXI-Lite address decoder.
//
// Address map:
//   0x0000_0000 - 0x0000_FFFF -> RAM
//   0x4000_0000 - 0x4000_00FF -> GPIO
module axil_interconnect (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] m_awaddr,
    input  logic        m_awvalid,
    output logic        m_awready,
    input  logic [31:0] m_wdata,
    input  logic [3:0]  m_wstrb,
    input  logic        m_wvalid,
    output logic        m_wready,
    output logic [1:0]  m_bresp,
    output logic        m_bvalid,
    input  logic        m_bready,

    input  logic [31:0] m_araddr,
    input  logic        m_arvalid,
    output logic        m_arready,
    output logic [31:0] m_rdata,
    output logic [1:0]  m_rresp,
    output logic        m_rvalid,
    input  logic        m_rready,

    output logic [31:0] ram_awaddr,
    output logic        ram_awvalid,
    input  logic        ram_awready,
    output logic [31:0] ram_wdata,
    output logic [3:0]  ram_wstrb,
    output logic        ram_wvalid,
    input  logic        ram_wready,
    input  logic [1:0]  ram_bresp,
    input  logic        ram_bvalid,
    output logic        ram_bready,
    output logic [31:0] ram_araddr,
    output logic        ram_arvalid,
    input  logic        ram_arready,
    input  logic [31:0] ram_rdata,
    input  logic [1:0]  ram_rresp,
    input  logic        ram_rvalid,
    output logic        ram_rready,

    output logic [31:0] gpio_awaddr,
    output logic        gpio_awvalid,
    input  logic        gpio_awready,
    output logic [31:0] gpio_wdata,
    output logic [3:0]  gpio_wstrb,
    output logic        gpio_wvalid,
    input  logic        gpio_wready,
    input  logic [1:0]  gpio_bresp,
    input  logic        gpio_bvalid,
    output logic        gpio_bready,
    output logic [31:0] gpio_araddr,
    output logic        gpio_arvalid,
    input  logic        gpio_arready,
    input  logic [31:0] gpio_rdata,
    input  logic [1:0]  gpio_rresp,
    input  logic        gpio_rvalid,
    output logic        gpio_rready
);

    typedef enum logic [1:0] {
        SEL_NONE,
        SEL_RAM,
        SEL_GPIO,
        SEL_ERROR
    } sel_t;

    sel_t read_sel;
    sel_t write_sel;
    sel_t ar_decode;
    sel_t aw_decode;
    logic err_rvalid;
    logic err_bvalid;

    function automatic sel_t decode_addr(input logic [31:0] addr);
        if (addr[31:16] == 16'h0000) begin
            decode_addr = SEL_RAM;
        end else if ((addr & 32'hFFFF_FF00) == 32'h4000_0000) begin
            decode_addr = SEL_GPIO;
        end else begin
            decode_addr = SEL_ERROR;
        end
    endfunction

    always @* begin
        ar_decode = decode_addr(m_araddr);
        aw_decode = decode_addr(m_awaddr);

        ram_awaddr   = m_awaddr;
        ram_wdata    = m_wdata;
        ram_wstrb    = m_wstrb;
        gpio_awaddr  = m_awaddr;
        gpio_wdata   = m_wdata;
        gpio_wstrb   = m_wstrb;

        ram_araddr   = m_araddr;
        gpio_araddr  = m_araddr;

        ram_awvalid  = 1'b0;
        ram_wvalid   = 1'b0;
        ram_bready   = 1'b0;
        ram_arvalid  = 1'b0;
        ram_rready   = 1'b0;

        gpio_awvalid = 1'b0;
        gpio_wvalid  = 1'b0;
        gpio_bready  = 1'b0;
        gpio_arvalid = 1'b0;
        gpio_rready  = 1'b0;

        m_awready    = 1'b0;
        m_wready     = 1'b0;
        m_bresp      = 2'b00;
        m_bvalid     = 1'b0;
        m_arready    = 1'b0;
        m_rdata      = 32'h0000_0000;
        m_rresp      = 2'b00;
        m_rvalid     = 1'b0;

        case (ar_decode)
            SEL_RAM: begin
                ram_arvalid = m_arvalid;
                m_arready   = ram_arready;
            end
            SEL_GPIO: begin
                gpio_arvalid = m_arvalid;
                m_arready    = gpio_arready;
            end
            default: begin
                m_arready = !err_rvalid;
            end
        endcase

        case (read_sel)
            SEL_RAM: begin
                m_rdata    = ram_rdata;
                m_rresp    = ram_rresp;
                m_rvalid   = ram_rvalid;
                ram_rready = m_rready;
            end
            SEL_GPIO: begin
                m_rdata     = gpio_rdata;
                m_rresp     = gpio_rresp;
                m_rvalid    = gpio_rvalid;
                gpio_rready = m_rready;
            end
            SEL_ERROR: begin
                m_rdata  = 32'h0000_0000;
                m_rresp  = 2'b10;
                m_rvalid = err_rvalid;
            end
            default: begin
            end
        endcase

        case (aw_decode)
            SEL_RAM: begin
                ram_awvalid = m_awvalid;
                ram_wvalid  = m_wvalid;
                m_awready   = ram_awready;
                m_wready    = ram_wready;
            end
            SEL_GPIO: begin
                gpio_awvalid = m_awvalid;
                gpio_wvalid  = m_wvalid;
                m_awready    = gpio_awready;
                m_wready     = gpio_wready;
            end
            default: begin
                m_awready = !err_bvalid;
                m_wready  = !err_bvalid;
            end
        endcase

        case (write_sel)
            SEL_RAM: begin
                m_bresp    = ram_bresp;
                m_bvalid   = ram_bvalid;
                ram_bready = m_bready;
            end
            SEL_GPIO: begin
                m_bresp     = gpio_bresp;
                m_bvalid    = gpio_bvalid;
                gpio_bready = m_bready;
            end
            SEL_ERROR: begin
                m_bresp  = 2'b10;
                m_bvalid = err_bvalid;
            end
            default: begin
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            read_sel   <= SEL_NONE;
            write_sel  <= SEL_NONE;
            err_rvalid <= 1'b0;
            err_bvalid <= 1'b0;
        end else begin
            if ((read_sel == SEL_NONE) && m_arvalid && m_arready) begin
                read_sel <= ar_decode;
                if (ar_decode == SEL_ERROR) begin
                    err_rvalid <= 1'b1;
                end
            end else if ((read_sel != SEL_NONE) && m_rvalid && m_rready) begin
                read_sel   <= SEL_NONE;
                err_rvalid <= 1'b0;
            end

            if ((write_sel == SEL_NONE) && m_awvalid && m_awready && m_wvalid && m_wready) begin
                write_sel <= aw_decode;
                if (aw_decode == SEL_ERROR) begin
                    err_bvalid <= 1'b1;
                end
            end else if ((write_sel != SEL_NONE) && m_bvalid && m_bready) begin
                write_sel  <= SEL_NONE;
                err_bvalid <= 1'b0;
            end
        end
    end

    wire unused_inputs = clk ^ rst;

endmodule
