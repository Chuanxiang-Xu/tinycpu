// tinycpu-pynq v0.6 pipeline SoC.
//
// The CPU core has Harvard-style simple memory ports. Physical memory is a
// unified 64 KiB true dual-port BRAM:
//   Port A: instruction fetch
//   Port B: data RAM access, or AXI-Lite loader access while the CPU is halted
module tinycpu_soc #(
    parameter RAM_HEX = "programs/led_switch_demo.hex",
    parameter integer RAM_INIT_WORDS = 4
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [1:0]  sw,
    output logic [3:0]  led,

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
    input  logic        s_axi_rready
);

    logic        imem_valid;
    logic [31:0] imem_addr;
    logic        imem_ready;
    logic [31:0] imem_rdata;
    logic        imem_valid_q;

    logic        dmem_valid;
    logic        dmem_we;
    logic [3:0]  dmem_wstrb;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic        dmem_ready;
    logic [31:0] dmem_rdata;

    logic        cpu_bram_en;
    logic [15:0] cpu_bram_addr;
    logic [31:0] cpu_bram_wdata;
    logic [3:0]  cpu_bram_wstrb;
    logic [31:0] bram_b_rdata;

    logic        loader_bram_en;
    logic [15:0] loader_bram_addr;
    logic [31:0] loader_bram_wdata;
    logic [3:0]  loader_bram_wstrb;
    logic [31:0] loader_bram_rdata;

    logic        bram_b_en;
    logic [15:0] bram_b_addr;
    logic [31:0] bram_b_wdata;
    logic [3:0]  bram_b_wstrb;

    logic        cpu_reset_req;
    logic        cpu_halt_req;
    logic        cpu_clear_pipeline;
    logic [31:0] boot_pc;
    logic        core_rst;
    logic        loader_owns_bram;

    logic        cpu_running;
    logic        cpu_halted;
    logic        cpu_trap;
    logic [31:0] test_status;
    logic [31:0] test_code;
    logic [31:0] app_status;
    logic [31:0] app_value0;
    logic [31:0] app_value1;
    logic [31:0] frame_counter;
    logic [31:0] host_input;
    logic [7:0]  fb_mirror_index;
    logic [31:0] fb_mirror_rdata;

    logic        dbg_if_id_valid;
    logic        dbg_id_ex_valid;
    logic        dbg_ex_mem_valid;
    logic        dbg_mem_wb_valid;

    assign core_rst = rst || cpu_reset_req;
    assign loader_owns_bram = cpu_halt_req || cpu_reset_req || rst;
    assign imem_ready = 1'b1;
    assign loader_bram_rdata = bram_b_rdata;

    always_ff @(posedge clk) begin
        imem_valid_q <= imem_valid;
    end

    tinycpu_core_pipe #(
        .RESET_PC(32'h0000_0000)
    ) core_i (
        .clk              (clk),
        .rst              (core_rst),
        .halt             (cpu_halt_req),
        .clear_pipeline   (cpu_clear_pipeline),
        .boot_pc          (boot_pc),
        .imem_valid       (imem_valid),
        .imem_addr        (imem_addr),
        .imem_ready       (imem_ready),
        .imem_rdata       (imem_rdata),
        .dmem_valid       (dmem_valid),
        .dmem_we          (dmem_we),
        .dmem_wstrb       (dmem_wstrb),
        .dmem_addr        (dmem_addr),
        .dmem_wdata       (dmem_wdata),
        .dmem_ready       (dmem_ready),
        .dmem_rdata       (dmem_rdata),
        .dbg_if_id_valid  (dbg_if_id_valid),
        .dbg_id_ex_valid  (dbg_id_ex_valid),
        .dbg_ex_mem_valid (dbg_ex_mem_valid),
        .dbg_mem_wb_valid (dbg_mem_wb_valid),
        .cpu_running      (cpu_running),
        .cpu_halted       (cpu_halted),
        .cpu_trap         (cpu_trap)
    );

    tinycpu_dmem_decoder dmem_decoder_i (
        .clk       (clk),
        .rst       (rst),
        .dmem_valid(dmem_valid),
        .dmem_we   (dmem_we),
        .dmem_wstrb(dmem_wstrb),
        .dmem_addr (dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_ready(dmem_ready),
        .dmem_rdata(dmem_rdata),
        .bram_en   (cpu_bram_en),
        .bram_addr (cpu_bram_addr),
        .bram_wdata(cpu_bram_wdata),
        .bram_wstrb(cpu_bram_wstrb),
        .bram_rdata(bram_b_rdata),
        .sw        (sw),
        .host_input_i(host_input),
        .led       (led),
        .test_status_o(test_status),
        .test_code_o  (test_code),
        .app_status_o (app_status),
        .app_value0_o (app_value0),
        .app_value1_o (app_value1),
        .frame_counter_o(frame_counter),
        .fb_mirror_index_i(fb_mirror_index),
        .fb_mirror_rdata_o(fb_mirror_rdata)
    );

    tinycpu_axil_loader loader_i (
        .clk              (clk),
        .rst              (rst),
        .s_axi_awaddr     (s_axi_awaddr),
        .s_axi_awvalid    (s_axi_awvalid),
        .s_axi_awready    (s_axi_awready),
        .s_axi_wdata      (s_axi_wdata),
        .s_axi_wstrb      (s_axi_wstrb),
        .s_axi_wvalid     (s_axi_wvalid),
        .s_axi_wready     (s_axi_wready),
        .s_axi_bresp      (s_axi_bresp),
        .s_axi_bvalid     (s_axi_bvalid),
        .s_axi_bready     (s_axi_bready),
        .s_axi_araddr     (s_axi_araddr),
        .s_axi_arvalid    (s_axi_arvalid),
        .s_axi_arready    (s_axi_arready),
        .s_axi_rdata      (s_axi_rdata),
        .s_axi_rresp      (s_axi_rresp),
        .s_axi_rvalid     (s_axi_rvalid),
        .s_axi_rready     (s_axi_rready),
        .loader_bram_en   (loader_bram_en),
        .loader_bram_addr (loader_bram_addr),
        .loader_bram_wdata(loader_bram_wdata),
        .loader_bram_wstrb(loader_bram_wstrb),
        .loader_bram_rdata(loader_bram_rdata),
        .cpu_reset_req    (cpu_reset_req),
        .cpu_halt_req     (cpu_halt_req),
        .cpu_clear_pipeline(cpu_clear_pipeline),
        .boot_pc          (boot_pc),
        .cpu_running      (cpu_running),
        .cpu_halted       (cpu_halted),
        .cpu_trap         (cpu_trap),
        .test_status_i    (test_status),
        .test_code_i      (test_code),
        .app_status_i     (app_status),
        .app_value0_i     (app_value0),
        .app_value1_i     (app_value1),
        .frame_counter_i  (frame_counter),
        .host_input_o     (host_input),
        .fb_mirror_index_o(fb_mirror_index),
        .fb_mirror_rdata_i(fb_mirror_rdata)
    );

    always @* begin
        if (loader_owns_bram) begin
            bram_b_en    = loader_bram_en;
            bram_b_addr  = loader_bram_addr;
            bram_b_wdata = loader_bram_wdata;
            bram_b_wstrb = loader_bram_wstrb;
        end else begin
            bram_b_en    = cpu_bram_en;
            bram_b_addr  = cpu_bram_addr;
            bram_b_wdata = cpu_bram_wdata;
            bram_b_wstrb = cpu_bram_wstrb;
        end
    end

    tinycpu_tdp_bram #(
        .ADDR_WIDTH(16),
        .DATA_WIDTH (32),
        .MEM_BYTES  (65536),
        .INIT_FILE  (RAM_HEX)
    ) bram_i (
        .clk    (clk),
        .a_en   (imem_valid),
        .a_addr (imem_addr[15:0]),
        .a_wdata(32'h0000_0000),
        .a_wstrb(4'b0000),
        .a_rdata(imem_rdata),
        .b_en   (bram_b_en),
        .b_addr (bram_b_addr),
        .b_wdata(bram_b_wdata),
        .b_wstrb(bram_b_wstrb),
        .b_rdata(bram_b_rdata)
    );

    wire unused_debug = ^{RAM_INIT_WORDS[7:0], dbg_if_id_valid, dbg_id_ex_valid,
                          dbg_ex_mem_valid, dbg_mem_wb_valid};

endmodule
