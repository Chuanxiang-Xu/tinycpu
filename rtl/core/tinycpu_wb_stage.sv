// Writeback stage mux.
module tinycpu_wb_stage (
    input  logic [31:0] alu_result,
    input  logic [31:0] load_data,
    input  logic [31:0] pc_plus4,
    input  logic [1:0]  wb_sel,
    output logic [31:0] wb_data
);

    always @* begin
        case (wb_sel)
            2'd0: wb_data = alu_result;
            2'd1: wb_data = load_data;
            2'd2: wb_data = pc_plus4;
            default: wb_data = 32'h0000_0000;
        endcase
    end

endmodule
