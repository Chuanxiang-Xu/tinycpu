// True dual-port block RAM for tinycpu.
//
// The default configuration is a unified 64 KiB, 32-bit-wide memory. Both
// ports have synchronous reads and per-byte write enables so FPGA tools can
// infer real dual-port BRAM.
module tinycpu_tdp_bram #(
    parameter integer ADDR_WIDTH = 16,
    parameter integer DATA_WIDTH = 32,
    parameter integer MEM_BYTES  = 65536,
    parameter INIT_FILE = ""
) (
    input  logic                  clk,

    input  logic                  a_en,
    input  logic [ADDR_WIDTH-1:0] a_addr,
    input  logic [DATA_WIDTH-1:0] a_wdata,
    input  logic [DATA_WIDTH/8-1:0] a_wstrb,
    output logic [DATA_WIDTH-1:0] a_rdata,

    input  logic                  b_en,
    input  logic [ADDR_WIDTH-1:0] b_addr,
    input  logic [DATA_WIDTH-1:0] b_wdata,
    input  logic [DATA_WIDTH/8-1:0] b_wstrb,
    output logic [DATA_WIDTH-1:0] b_rdata
);

    localparam integer BYTE_LANES = DATA_WIDTH / 8;
    localparam integer DEPTH = MEM_BYTES / BYTE_LANES;
    localparam integer WORD_ADDR_WIDTH = (ADDR_WIDTH > 2) ? (ADDR_WIDTH - 2) : 1;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [WORD_ADDR_WIDTH-1:0] a_word_addr;
    logic [WORD_ADDR_WIDTH-1:0] b_word_addr;

    integer i;
    integer lane;

    assign a_word_addr = a_addr[ADDR_WIDTH-1:2];
    assign b_word_addr = b_addr[ADDR_WIDTH-1:2];

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end

        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always @* begin
        a_rdata = a_en ? mem[a_word_addr] : {DATA_WIDTH{1'b0}};
    end

    always_ff @(posedge clk) begin
        if (b_en) begin
            for (lane = 0; lane < BYTE_LANES; lane = lane + 1) begin
                if (b_wstrb[lane]) begin
                    mem[b_word_addr][lane * 8 +: 8] <= b_wdata[lane * 8 +: 8];
                end
            end
            b_rdata <= mem[b_word_addr];
        end
    end

endmodule
