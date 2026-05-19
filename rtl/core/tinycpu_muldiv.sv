// Multi-cycle RV32M multiply/divide unit.
//
// Multiply operations use a registered product with a short busy interval.
// Divide/remainder operations use a 32-cycle unsigned restoring divider with
// signed pre/post processing for DIV and REM.
module tinycpu_muldiv #(
    parameter int MUL_LATENCY = 2
) (
    input  logic        clk,
    input  logic        rst,

    input  logic        start,
    input  logic [2:0]  op,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,

    output logic        busy,
    output logic        done,
    output logic [31:0] result
);

    localparam logic [5:0] MUL_COUNT = (MUL_LATENCY < 1) ? 6'd1 : MUL_LATENCY[5:0];

    logic [31:0] result_q;
    logic [5:0]  count_q;
    logic        div_active_q;
    logic        div_quotient_result_q;
    logic        div_negate_quotient_q;
    logic        div_negate_remainder_q;
    logic [31:0] div_dividend_q;
    logic [31:0] div_divisor_q;
    logic [31:0] div_quotient_q;
    logic [32:0] div_remainder_q;

    logic [31:0] rs1_abs;
    logic [31:0] rs2_abs;
    logic [63:0] product_uu;
    logic signed [63:0] product_ss;
    logic signed [63:0] product_su;
    logic signed [63:0] rs1_s64;
    logic signed [63:0] rs2_s64;
    logic signed [63:0] rs2_u64_as_signed;
    logic [31:0] mul_result;

    logic [32:0] rem_shifted;
    logic [32:0] rem_subtracted;
    logic [32:0] remainder_shifted;
    logic [31:0] quotient_shifted;
    logic [31:0] quotient_final;
    logic [31:0] remainder_final;

    assign rs1_abs = rs1[31] ? (~rs1 + 32'd1) : rs1;
    assign rs2_abs = rs2[31] ? (~rs2 + 32'd1) : rs2;

    assign rs1_s64 = {{32{rs1[31]}}, rs1};
    assign rs2_s64 = {{32{rs2[31]}}, rs2};
    assign rs2_u64_as_signed = {32'b0, rs2};
    assign product_uu = {32'b0, rs1} * {32'b0, rs2};
    assign product_ss = rs1_s64 * rs2_s64;
    assign product_su = rs1_s64 * rs2_u64_as_signed;

    always @* begin
        case (op)
            3'b000: mul_result = product_uu[31:0];  // MUL
            3'b001: mul_result = product_ss[63:32]; // MULH
            3'b010: mul_result = product_su[63:32]; // MULHSU
            3'b011: mul_result = product_uu[63:32]; // MULHU
            default: mul_result = 32'h0000_0000;
        endcase
    end

    assign rem_shifted = {div_remainder_q[31:0], div_dividend_q[31]};
    assign rem_subtracted = rem_shifted - {1'b0, div_divisor_q};
    assign remainder_shifted = (rem_shifted >= {1'b0, div_divisor_q}) ?
                               rem_subtracted :
                               rem_shifted;
    assign quotient_shifted = {div_quotient_q[30:0],
                               (rem_shifted >= {1'b0, div_divisor_q})};
    assign quotient_final = div_negate_quotient_q ? (~quotient_shifted + 32'd1) :
                                                    quotient_shifted;
    assign remainder_final = div_negate_remainder_q ? (~remainder_shifted[31:0] + 32'd1) :
                                                      remainder_shifted[31:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            busy                  <= 1'b0;
            done                  <= 1'b0;
            result_q              <= 32'h0000_0000;
            count_q               <= 6'd0;
            div_active_q          <= 1'b0;
            div_quotient_result_q <= 1'b0;
            div_negate_quotient_q <= 1'b0;
            div_negate_remainder_q <= 1'b0;
            div_dividend_q        <= 32'h0000_0000;
            div_divisor_q         <= 32'h0000_0000;
            div_quotient_q        <= 32'h0000_0000;
            div_remainder_q       <= 33'h0_0000_0000;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                busy <= 1'b1;

                if (!op[2]) begin
                    result_q     <= mul_result;
                    count_q      <= MUL_COUNT;
                    div_active_q <= 1'b0;
                end else if (rs2 == 32'h0000_0000) begin
                    result_q     <= op[1] ? rs1 : 32'hffff_ffff;
                    count_q      <= 6'd1;
                    div_active_q <= 1'b0;
                end else if ((op[0] == 1'b0) && (rs1 == 32'h8000_0000) &&
                             (rs2 == 32'hffff_ffff)) begin
                    result_q     <= op[1] ? 32'h0000_0000 : 32'h8000_0000;
                    count_q      <= 6'd1;
                    div_active_q <= 1'b0;
                end else begin
                    count_q               <= 6'd32;
                    div_active_q          <= 1'b1;
                    div_quotient_result_q <= !op[1];
                    div_negate_quotient_q <= (op[0] == 1'b0) && (rs1[31] ^ rs2[31]);
                    div_negate_remainder_q <= (op[0] == 1'b0) && rs1[31];
                    div_dividend_q        <= (op[0] == 1'b0) ? rs1_abs : rs1;
                    div_divisor_q         <= (op[0] == 1'b0) ? rs2_abs : rs2;
                    div_quotient_q        <= 32'h0000_0000;
                    div_remainder_q       <= 33'h0_0000_0000;
                end
            end else if (busy) begin
                if (div_active_q) begin
                    div_dividend_q  <= {div_dividend_q[30:0], 1'b0};
                    div_quotient_q  <= quotient_shifted;
                    div_remainder_q <= remainder_shifted;

                    if (count_q == 6'd1) begin
                        busy         <= 1'b0;
                        done         <= 1'b1;
                        count_q      <= 6'd0;
                        div_active_q <= 1'b0;
                        result_q     <= div_quotient_result_q ? quotient_final :
                                                               remainder_final;
                    end else begin
                        count_q <= count_q - 6'd1;
                    end
                end else if (count_q <= 6'd1) begin
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    count_q <= 6'd0;
                end else begin
                    count_q <= count_q - 6'd1;
                end
            end
        end
    end

    assign result = result_q;

endmodule
