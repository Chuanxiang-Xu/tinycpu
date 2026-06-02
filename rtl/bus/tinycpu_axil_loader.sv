// AXI-Lite RAM loader and CPU control/status block.
//
// Address map within this slave:
//   0x00000 - 0x0ffff: unified BRAM loader window
//   0x10000: CONTROL {clear_pipeline, start_pulse, cpu_halt, cpu_reset}
//   0x10004: STATUS  {loader_blocked, cpu_trap, cpu_halted, cpu_running}
//   0x10008: BOOT_PC
//   0x1000c: DEBUG/RESERVED
module tinycpu_axil_loader (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] s_axi_awaddr,
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
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    output logic        loader_bram_en,
    output logic [15:0] loader_bram_addr,
    output logic [31:0] loader_bram_wdata,
    output logic [3:0]  loader_bram_wstrb,
    input  logic [31:0] loader_bram_rdata,

    output logic        cpu_reset_req,
    output logic        cpu_halt_req,
    output logic        cpu_clear_pipeline,
    output logic [31:0] boot_pc,

    input  logic        cpu_running,
    input  logic        cpu_halted,
    input  logic        cpu_trap
);

    localparam logic [31:0] RAM_LAST       = 32'h0000_FFFF;
    localparam logic [31:0] CONTROL_OFFSET = 32'h0001_0000;
    localparam logic [31:0] STATUS_OFFSET  = 32'h0001_0004;
    localparam logic [31:0] BOOT_PC_OFFSET = 32'h0001_0008;
    localparam logic [31:0] DEBUG_OFFSET   = 32'h0001_000C;

    localparam logic [1:0] RESP_OKAY  = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    logic [31:0] awaddr_q;
    logic        aw_seen_q;
    logic [31:0] debug_q;
    logic        blocked_q;
    logic        write_fire;
    logic        read_fire;
    logic        write_to_ram;
    logic        read_from_ram;
    logic        loader_allowed;
    logic [31:0] status_word;
    logic        awvalid_hi;
    logic        wvalid_hi;
    logic        arvalid_hi;
    logic        bready_hi;
    logic        rready_hi;

    integer lane;

    assign awvalid_hi = (s_axi_awvalid === 1'b1);
    assign wvalid_hi  = (s_axi_wvalid === 1'b1);
    assign arvalid_hi = (s_axi_arvalid === 1'b1);
    assign bready_hi  = (s_axi_bready === 1'b1);
    assign rready_hi  = (s_axi_rready === 1'b1);

    assign write_fire = wvalid_hi && (aw_seen_q || awvalid_hi) &&
                        !s_axi_bvalid;
    assign read_fire = arvalid_hi && !s_axi_rvalid;
    assign write_to_ram = ((aw_seen_q ? awaddr_q : s_axi_awaddr) <= RAM_LAST);
    assign read_from_ram = (s_axi_araddr <= RAM_LAST);
    assign loader_allowed = cpu_halt_req || cpu_reset_req || cpu_halted || !cpu_running;
    assign status_word = {28'b0, blocked_q, cpu_trap, cpu_halted, cpu_running};

    always @* begin
        s_axi_awready = !aw_seen_q && !s_axi_bvalid;
        s_axi_wready  = (aw_seen_q || s_axi_awvalid) && !s_axi_bvalid;
        s_axi_arready = !s_axi_rvalid;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            awaddr_q          <= 32'h0000_0000;
            aw_seen_q         <= 1'b0;
            s_axi_bresp       <= RESP_OKAY;
            s_axi_bvalid      <= 1'b0;
            s_axi_rdata       <= 32'h0000_0000;
            s_axi_rresp       <= RESP_OKAY;
            s_axi_rvalid      <= 1'b0;
            loader_bram_en    <= 1'b0;
            loader_bram_addr  <= 16'h0000;
            loader_bram_wdata <= 32'h0000_0000;
            loader_bram_wstrb <= 4'b0000;
            cpu_reset_req     <= 1'b0;
            cpu_halt_req      <= 1'b0;
            cpu_clear_pipeline <= 1'b0;
            boot_pc           <= 32'h0000_0000;
            debug_q           <= 32'h0000_0000;
            blocked_q         <= 1'b0;
        end else begin
            loader_bram_en    <= 1'b0;
            loader_bram_wstrb <= 4'b0000;
            cpu_clear_pipeline <= 1'b0;
            blocked_q         <= 1'b0;

            if (s_axi_bvalid && bready_hi) begin
                s_axi_bvalid <= 1'b0;
                s_axi_bresp  <= RESP_OKAY;
            end

            if (s_axi_rvalid && rready_hi) begin
                s_axi_rvalid <= 1'b0;
                s_axi_rresp  <= RESP_OKAY;
            end

            if (awvalid_hi && s_axi_awready) begin
                awaddr_q  <= s_axi_awaddr;
                aw_seen_q <= 1'b1;
            end

            if (write_fire) begin
                aw_seen_q    <= 1'b0;
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= RESP_OKAY;

                if (write_to_ram) begin
                    if (loader_allowed) begin
                        loader_bram_en    <= 1'b1;
                        loader_bram_addr  <= (aw_seen_q ? awaddr_q[15:0] :
                                                         s_axi_awaddr[15:0]);
                        loader_bram_wdata <= s_axi_wdata;
                        loader_bram_wstrb <= s_axi_wstrb;
                    end else begin
                        s_axi_bresp <= RESP_SLVERR;
                        blocked_q   <= 1'b1;
                    end
                end else begin
                    case (aw_seen_q ? awaddr_q : s_axi_awaddr)
                        CONTROL_OFFSET: begin
                            cpu_reset_req <= s_axi_wdata[0];
                            cpu_halt_req  <= s_axi_wdata[1] && !s_axi_wdata[2];
                            if (s_axi_wdata[2]) begin
                                cpu_halt_req <= 1'b0;
                            end
                            cpu_clear_pipeline <= s_axi_wdata[3];
                        end
                        BOOT_PC_OFFSET: begin
                            for (lane = 0; lane < 4; lane = lane + 1) begin
                                if (s_axi_wstrb[lane]) begin
                                    boot_pc[lane * 8 +: 8] <=
                                        s_axi_wdata[lane * 8 +: 8];
                                end
                            end
                        end
                        DEBUG_OFFSET: begin
                            for (lane = 0; lane < 4; lane = lane + 1) begin
                                if (s_axi_wstrb[lane]) begin
                                    debug_q[lane * 8 +: 8] <=
                                        s_axi_wdata[lane * 8 +: 8];
                                end
                            end
                        end
                        default: begin
                            s_axi_bresp <= RESP_SLVERR;
                        end
                    endcase
                end
            end

            if (read_fire) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= RESP_OKAY;

                if (read_from_ram) begin
                    loader_bram_en    <= 1'b1;
                    loader_bram_addr  <= s_axi_araddr[15:0];
                    loader_bram_wdata <= 32'h0000_0000;
                    loader_bram_wstrb <= 4'b0000;
                    s_axi_rdata       <= loader_bram_rdata;
                end else begin
                    case (s_axi_araddr)
                        CONTROL_OFFSET: s_axi_rdata <= {28'b0, 1'b0, 1'b0,
                                                        cpu_halt_req,
                                                        cpu_reset_req};
                        STATUS_OFFSET:  s_axi_rdata <= status_word;
                        BOOT_PC_OFFSET: s_axi_rdata <= boot_pc;
                        DEBUG_OFFSET:   s_axi_rdata <= debug_q;
                        default: begin
                            s_axi_rdata <= 32'h0000_0000;
                            s_axi_rresp <= RESP_SLVERR;
                        end
                    endcase
                end
            end
        end
    end

endmodule
