// Basic hazard helper for the teaching pipeline structure.
//
// The current core globally stalls around AXI-Lite transactions. This module
// captures the standard load-use hazard rule and branch flush signal so the
// policy is explicit and can grow in v0.4.
module tinycpu_hazard (
    input  logic       id_valid,
    input  logic [4:0] id_rs1,
    input  logic [4:0] id_rs2,
    input  logic       ex_valid,
    input  logic       ex_is_load,
    input  logic [4:0] ex_rd,
    input  logic       branch_taken,
    output logic       stall_if,
    output logic       stall_id,
    output logic       flush_if_id,
    output logic       flush_id_ex
);

    logic load_use_hazard;

    assign load_use_hazard = id_valid && ex_valid && ex_is_load && (ex_rd != 5'd0) &&
                             ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    assign stall_if    = load_use_hazard;
    assign stall_id    = load_use_hazard;
    assign flush_if_id = branch_taken;
    assign flush_id_ex = load_use_hazard || branch_taken;

endmodule
