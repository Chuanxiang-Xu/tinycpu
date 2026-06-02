// Forwarding selection helper for the overlapped tinycpu pipeline.
module tinycpu_forwarding (
    input  logic [4:0] id_ex_rs1,
    input  logic [4:0] id_ex_rs2,

    input  logic       ex_mem_valid,
    input  logic       ex_mem_reg_write,
    input  logic       ex_mem_is_load,
    input  logic [4:0] ex_mem_rd,

    input  logic       mem_wb_valid,
    input  logic       mem_wb_reg_write,
    input  logic [4:0] mem_wb_rd,

    output logic [1:0] fwd_a,
    output logic [1:0] fwd_b
);

    localparam logic [1:0] FWD_REG    = 2'd0;
    localparam logic [1:0] FWD_EX_MEM = 2'd1;
    localparam logic [1:0] FWD_MEM_WB = 2'd2;

    always @* begin
        fwd_a = FWD_REG;
        fwd_b = FWD_REG;

        if (ex_mem_valid && ex_mem_reg_write && !ex_mem_is_load &&
            (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            fwd_a = FWD_EX_MEM;
        end else if (mem_wb_valid && mem_wb_reg_write &&
                     (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            fwd_a = FWD_MEM_WB;
        end

        if (ex_mem_valid && ex_mem_reg_write && !ex_mem_is_load &&
            (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            fwd_b = FWD_EX_MEM;
        end else if (mem_wb_valid && mem_wb_reg_write &&
                     (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            fwd_b = FWD_MEM_WB;
        end
    end

endmodule
