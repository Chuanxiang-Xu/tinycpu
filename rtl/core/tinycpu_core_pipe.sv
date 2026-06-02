// Clean-room RV32IM five-stage overlapped pipeline core.
//
// The core has simple Harvard-style instruction/data memory ports. The SoC is
// responsible for mapping those ports to BRAM, MMIO, and AXI-Lite loader logic.
module tinycpu_core_pipe #(
    parameter logic [31:0] RESET_PC = 32'h0000_0000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        halt,
    input  logic        clear_pipeline,
    input  logic [31:0] boot_pc,

    output logic        imem_valid,
    output logic [31:0] imem_addr,
    input  logic        imem_ready,
    input  logic [31:0] imem_rdata,

    output logic        dmem_valid,
    output logic        dmem_we,
    output logic [3:0]  dmem_wstrb,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic        dmem_ready,
    input  logic [31:0] dmem_rdata,

    output logic        dbg_if_id_valid,
    output logic        dbg_id_ex_valid,
    output logic        dbg_ex_mem_valid,
    output logic        dbg_mem_wb_valid,
    output logic        cpu_running,
    output logic        cpu_halted,
    output logic        cpu_trap
);

    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_OP_IMM = 7'b0010011;
    localparam logic [6:0] OPCODE_OP     = 7'b0110011;

    localparam logic [2:0] FUNCT3_ADDI_SL = 3'b000;
    localparam logic [2:0] FUNCT3_SLL     = 3'b001;
    localparam logic [2:0] FUNCT3_SLT     = 3'b010;
    localparam logic [2:0] FUNCT3_SLTU    = 3'b011;
    localparam logic [2:0] FUNCT3_XOR     = 3'b100;
    localparam logic [2:0] FUNCT3_SHIFT_R = 3'b101;
    localparam logic [2:0] FUNCT3_OR      = 3'b110;
    localparam logic [2:0] FUNCT3_AND     = 3'b111;

    localparam logic [2:0] FUNCT3_LB  = 3'b000;
    localparam logic [2:0] FUNCT3_LH  = 3'b001;
    localparam logic [2:0] FUNCT3_LW  = 3'b010;
    localparam logic [2:0] FUNCT3_LBU = 3'b100;
    localparam logic [2:0] FUNCT3_LHU = 3'b101;

    localparam logic [2:0] FUNCT3_SB = 3'b000;
    localparam logic [2:0] FUNCT3_SH = 3'b001;
    localparam logic [2:0] FUNCT3_SW = 3'b010;

    localparam logic [2:0] FUNCT3_BEQ  = 3'b000;
    localparam logic [2:0] FUNCT3_BNE  = 3'b001;
    localparam logic [2:0] FUNCT3_BLT  = 3'b100;
    localparam logic [2:0] FUNCT3_BGE  = 3'b101;
    localparam logic [2:0] FUNCT3_BLTU = 3'b110;
    localparam logic [2:0] FUNCT3_BGEU = 3'b111;

    localparam logic [6:0] FUNCT7_ALT = 7'b0100000;

    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_AND  = 4'd2;
    localparam logic [3:0] ALU_OR   = 4'd3;
    localparam logic [3:0] ALU_XOR  = 4'd4;
    localparam logic [3:0] ALU_SLL  = 4'd5;
    localparam logic [3:0] ALU_SRL  = 4'd6;
    localparam logic [3:0] ALU_SRA  = 4'd7;
    localparam logic [3:0] ALU_SLT  = 4'd8;
    localparam logic [3:0] ALU_SLTU = 4'd9;

    localparam logic [1:0] WB_ALU = 2'd0;
    localparam logic [1:0] WB_MEM = 2'd1;
    localparam logic [1:0] WB_PC4 = 2'd2;

    localparam logic [1:0] FWD_REG    = 2'd0;
    localparam logic [1:0] FWD_EX_MEM = 2'd1;
    localparam logic [1:0] FWD_MEM_WB = 2'd2;

    logic [31:0] pc_q;
    logic [31:0] fetch_pc_q;
    logic        fetch_valid_q;

    logic        if_id_valid_q;
    logic [31:0] if_id_pc_q;
    logic [31:0] if_id_instr_q;

    logic        id_ex_valid_q;
    logic [31:0] id_ex_pc_q;
    logic [31:0] id_ex_instr_q;
    logic [31:0] id_ex_rs1_data_q;
    logic [31:0] id_ex_rs2_data_q;
    logic [31:0] id_ex_imm_i_q;
    logic [31:0] id_ex_imm_s_q;
    logic [31:0] id_ex_imm_b_q;
    logic [31:0] id_ex_imm_u_q;
    logic [31:0] id_ex_imm_j_q;
    logic [4:0]  id_ex_rs1_q;
    logic [4:0]  id_ex_rs2_q;
    logic [4:0]  id_ex_rd_q;
    logic [2:0]  id_ex_funct3_q;
    logic [6:0]  id_ex_funct7_q;
    logic        id_ex_is_lui_q;
    logic        id_ex_is_auipc_q;
    logic        id_ex_is_jal_q;
    logic        id_ex_is_jalr_q;
    logic        id_ex_is_branch_q;
    logic        id_ex_is_load_q;
    logic        id_ex_is_store_q;
    logic        id_ex_is_op_imm_q;
    logic        id_ex_is_op_q;
    logic        id_ex_is_muldiv_q;
    logic [2:0]  id_ex_muldiv_op_q;
    logic        id_ex_reg_write_q;
    logic [1:0]  id_ex_wb_sel_q;

    logic        ex_mem_valid_q;
    logic [31:0] ex_mem_pc_q;
    logic [31:0] ex_mem_alu_result_q;
    logic [31:0] ex_mem_store_data_q;
    logic [4:0]  ex_mem_rd_q;
    logic [2:0]  ex_mem_funct3_q;
    logic        ex_mem_reg_write_q;
    logic        ex_mem_is_load_q;
    logic        ex_mem_is_store_q;
    logic [1:0]  ex_mem_wb_sel_q;
    logic        ex_mem_req_sent_q;

    logic        mem_wb_valid_q;
    logic [31:0] mem_wb_alu_result_q;
    logic [31:0] mem_wb_load_data_q;
    logic [31:0] mem_wb_pc_plus4_q;
    logic [4:0]  mem_wb_rd_q;
    logic        mem_wb_reg_write_q;
    logic [1:0]  mem_wb_wb_sel_q;

    logic [6:0]  id_opcode;
    logic [2:0]  id_funct3;
    logic [6:0]  id_funct7;
    logic [4:0]  id_rs1;
    logic [4:0]  id_rs2;
    logic [4:0]  id_rd;
    logic [31:0] id_imm_i;
    logic [31:0] id_imm_s;
    logic [31:0] id_imm_b;
    logic [31:0] id_imm_u;
    logic [31:0] id_imm_j;
    logic        id_is_lui;
    logic        id_is_auipc;
    logic        id_is_jal;
    logic        id_is_jalr;
    logic        id_is_branch;
    logic        id_is_load;
    logic        id_is_store;
    logic        id_is_op_imm;
    logic        id_is_op;
    logic        id_is_muldiv;
    logic [2:0]  id_muldiv_op;
    logic        id_muldiv_is_div;
    logic        id_muldiv_is_signed;
    logic        id_illegal;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        wb_we;
    logic [31:0] wb_data;

    logic [1:0]  fwd_a_sel;
    logic [1:0]  fwd_b_sel;
    logic [31:0] ex_op_a;
    logic [31:0] ex_rs2_value;
    logic [31:0] ex_op_b;
    logic [3:0]  ex_alu_op;
    logic [31:0] ex_alu_result;
    logic        ex_eq;
    logic        branch_taken;
    logic [31:0] branch_target;
    logic [31:0] ex_result;
    logic [31:0] mem_forward_data;

    logic [31:0] load_shifted;
    logic [31:0] load_data_ext;
    logic [31:0] store_shifted;
    logic [3:0]  store_wstrb;

    logic id_ex_load_use_hazard;
    logic ex_mem_load_use_hazard;
    logic mem_wb_load_use_hazard;
    logic load_use_hazard;
    logic mem_busy;
    logic muldiv_start;
    logic muldiv_busy;
    logic muldiv_done;
    logic [31:0] muldiv_result;
    logic muldiv_active_q;
    logic core_stall;
    logic can_fetch_latch;

    assign dbg_if_id_valid  = if_id_valid_q;
    assign dbg_id_ex_valid  = id_ex_valid_q;
    assign dbg_ex_mem_valid = ex_mem_valid_q;
    assign dbg_mem_wb_valid = mem_wb_valid_q;
    assign cpu_halted = halt;
    assign cpu_running = !halt && !cpu_trap;

    assign imem_valid = !halt && !cpu_trap;
    assign imem_addr  = pc_q;

    assign dmem_valid = ex_mem_valid_q &&
                        (ex_mem_is_load_q || ex_mem_is_store_q);
    assign dmem_we    = ex_mem_is_store_q;
    assign dmem_addr  = {ex_mem_alu_result_q[31:2], 2'b00};
    assign dmem_wdata = store_shifted;
    assign dmem_wstrb = ex_mem_is_store_q ? store_wstrb : 4'b0000;

    tinycpu_decode decode_i (
        .instr    (if_id_instr_q),
        .opcode   (id_opcode),
        .funct3   (id_funct3),
        .funct7   (id_funct7),
        .rs1      (id_rs1),
        .rs2      (id_rs2),
        .rd       (id_rd),
        .imm_i    (id_imm_i),
        .imm_s    (id_imm_s),
        .imm_b    (id_imm_b),
        .imm_u    (id_imm_u),
        .imm_j    (id_imm_j),
        .is_lui   (id_is_lui),
        .is_auipc (id_is_auipc),
        .is_jal   (id_is_jal),
        .is_jalr  (id_is_jalr),
        .is_branch(id_is_branch),
        .is_load  (id_is_load),
        .is_store (id_is_store),
        .is_op_imm(id_is_op_imm),
        .is_op    (id_is_op),
        .is_muldiv(id_is_muldiv),
        .muldiv_op(id_muldiv_op),
        .muldiv_is_div(id_muldiv_is_div),
        .muldiv_is_signed(id_muldiv_is_signed),
        .illegal  (id_illegal)
    );

    tinycpu_regfile regfile_i (
        .clk      (clk),
        .rst      (rst),
        .rs1_addr (id_rs1),
        .rs1_rdata(rs1_data),
        .rs2_addr (id_rs2),
        .rs2_rdata(rs2_data),
        .rd_we    (wb_we),
        .rd_addr  (mem_wb_rd_q),
        .rd_wdata (wb_data)
    );

    tinycpu_forwarding forwarding_i (
        .id_ex_rs1       (id_ex_rs1_q),
        .id_ex_rs2       (id_ex_rs2_q),
        .ex_mem_valid    (ex_mem_valid_q),
        .ex_mem_reg_write(ex_mem_reg_write_q),
        .ex_mem_is_load  (ex_mem_is_load_q),
        .ex_mem_rd       (ex_mem_rd_q),
        .mem_wb_valid    (mem_wb_valid_q),
        .mem_wb_reg_write(mem_wb_reg_write_q),
        .mem_wb_rd       (mem_wb_rd_q),
        .fwd_a           (fwd_a_sel),
        .fwd_b           (fwd_b_sel)
    );

    tinycpu_alu alu_i (
        .op  (ex_alu_op),
        .a   (ex_op_a),
        .b   (ex_op_b),
        .y   (ex_alu_result),
        .zero()
    );

    tinycpu_muldiv muldiv_i (
        .clk   (clk),
        .rst   (rst),
        .start (muldiv_start),
        .op    (id_ex_muldiv_op_q),
        .rs1   (ex_op_a),
        .rs2   (ex_rs2_value),
        .busy  (muldiv_busy),
        .done  (muldiv_done),
        .result(muldiv_result)
    );

    always @* begin
        case (mem_wb_wb_sel_q)
            WB_ALU: wb_data = mem_wb_alu_result_q;
            WB_MEM: wb_data = mem_wb_load_data_q;
            WB_PC4: wb_data = mem_wb_pc_plus4_q;
            default: wb_data = 32'h0000_0000;
        endcase
    end

    assign wb_we = mem_wb_valid_q && mem_wb_reg_write_q && (mem_wb_rd_q != 5'd0);

    assign mem_forward_data = (ex_mem_wb_sel_q == WB_PC4) ?
                              (ex_mem_pc_q + 32'd4) :
                              ex_mem_alu_result_q;

    always @* begin
        case (fwd_a_sel)
            FWD_EX_MEM: ex_op_a = mem_forward_data;
            FWD_MEM_WB: ex_op_a = wb_data;
            default:    ex_op_a = id_ex_rs1_data_q;
        endcase

        case (fwd_b_sel)
            FWD_EX_MEM: ex_rs2_value = mem_forward_data;
            FWD_MEM_WB: ex_rs2_value = wb_data;
            default:    ex_rs2_value = id_ex_rs2_data_q;
        endcase
    end

    always @* begin
        ex_alu_op = ALU_ADD;
        if (id_ex_is_op_q || id_ex_is_op_imm_q) begin
            case (id_ex_funct3_q)
                FUNCT3_ADDI_SL: ex_alu_op = (id_ex_is_op_q &&
                                             (id_ex_funct7_q == FUNCT7_ALT)) ?
                                             ALU_SUB : ALU_ADD;
                FUNCT3_SLL:     ex_alu_op = ALU_SLL;
                FUNCT3_SLT:     ex_alu_op = ALU_SLT;
                FUNCT3_SLTU:    ex_alu_op = ALU_SLTU;
                FUNCT3_XOR:     ex_alu_op = ALU_XOR;
                FUNCT3_SHIFT_R: ex_alu_op = (id_ex_funct7_q == FUNCT7_ALT) ?
                                             ALU_SRA : ALU_SRL;
                FUNCT3_OR:      ex_alu_op = ALU_OR;
                FUNCT3_AND:     ex_alu_op = ALU_AND;
                default:        ex_alu_op = ALU_ADD;
            endcase
        end
    end

    always @* begin
        if (id_ex_is_op_q || id_ex_is_branch_q) begin
            ex_op_b = ex_rs2_value;
        end else if (id_ex_is_store_q) begin
            ex_op_b = id_ex_imm_s_q;
        end else begin
            ex_op_b = id_ex_imm_i_q;
        end
    end

    assign ex_eq = (ex_op_a == ex_rs2_value);

    always @* begin
        branch_taken  = 1'b0;
        branch_target = id_ex_pc_q + 32'd4;

        if (id_ex_is_branch_q) begin
            case (id_ex_funct3_q)
                FUNCT3_BEQ:  branch_taken = ex_eq;
                FUNCT3_BNE:  branch_taken = !ex_eq;
                FUNCT3_BLT:  branch_taken = ($signed(ex_op_a) < $signed(ex_rs2_value));
                FUNCT3_BGE:  branch_taken = !($signed(ex_op_a) < $signed(ex_rs2_value));
                FUNCT3_BLTU: branch_taken = (ex_op_a < ex_rs2_value);
                FUNCT3_BGEU: branch_taken = !(ex_op_a < ex_rs2_value);
                default:     branch_taken = 1'b0;
            endcase
            branch_target = id_ex_pc_q + id_ex_imm_b_q;
        end else if (id_ex_is_jal_q) begin
            branch_taken  = 1'b1;
            branch_target = id_ex_pc_q + id_ex_imm_j_q;
        end else if (id_ex_is_jalr_q) begin
            branch_taken  = 1'b1;
            branch_target = (ex_op_a + id_ex_imm_i_q) & 32'hFFFF_FFFE;
        end
    end

    always @* begin
        if (id_ex_is_lui_q) begin
            ex_result = id_ex_imm_u_q;
        end else if (id_ex_is_auipc_q) begin
            ex_result = id_ex_pc_q + id_ex_imm_u_q;
        end else if (id_ex_is_muldiv_q) begin
            ex_result = muldiv_result;
        end else begin
            ex_result = ex_alu_result;
        end
    end

    always @* begin
        load_shifted = dmem_rdata >> {ex_mem_alu_result_q[1:0], 3'b000};
        case (ex_mem_funct3_q)
            FUNCT3_LB:  load_data_ext = {{24{load_shifted[7]}}, load_shifted[7:0]};
            FUNCT3_LH:  load_data_ext = {{16{load_shifted[15]}}, load_shifted[15:0]};
            FUNCT3_LW:  load_data_ext = dmem_rdata;
            FUNCT3_LBU: load_data_ext = {24'b0, load_shifted[7:0]};
            FUNCT3_LHU: load_data_ext = {16'b0, load_shifted[15:0]};
            default:    load_data_ext = 32'h0000_0000;
        endcase
    end

    always @* begin
        store_shifted = 32'h0000_0000;
        store_wstrb   = 4'b0000;
        case (ex_mem_funct3_q)
            FUNCT3_SB: begin
                store_shifted = {4{ex_mem_store_data_q[7:0]}} <<
                                {ex_mem_alu_result_q[1:0], 3'b000};
                store_wstrb = 4'b0001 << ex_mem_alu_result_q[1:0];
            end
            FUNCT3_SH: begin
                store_shifted = {2{ex_mem_store_data_q[15:0]}} <<
                                {ex_mem_alu_result_q[1:0], 3'b000};
                store_wstrb = 4'b0011 << ex_mem_alu_result_q[1:0];
            end
            FUNCT3_SW: begin
                store_shifted = ex_mem_store_data_q;
                store_wstrb = 4'b1111;
            end
            default: begin
                store_shifted = 32'h0000_0000;
                store_wstrb = 4'b0000;
            end
        endcase
    end

    assign id_ex_load_use_hazard = if_id_valid_q && id_ex_valid_q &&
                                   id_ex_is_load_q && (id_ex_rd_q != 5'd0) &&
                                   ((id_ex_rd_q == id_rs1) ||
                                    (id_ex_rd_q == id_rs2));
    assign ex_mem_load_use_hazard = if_id_valid_q && ex_mem_valid_q &&
                                    ex_mem_is_load_q && (ex_mem_rd_q != 5'd0) &&
                                    ((ex_mem_rd_q == id_rs1) ||
                                     (ex_mem_rd_q == id_rs2));
    assign mem_wb_load_use_hazard = if_id_valid_q && mem_wb_valid_q &&
                                    (mem_wb_wb_sel_q == WB_MEM) &&
                                    (mem_wb_rd_q != 5'd0) &&
                                    ((mem_wb_rd_q == id_rs1) ||
                                     (mem_wb_rd_q == id_rs2));
    assign load_use_hazard = id_ex_load_use_hazard ||
                             ex_mem_load_use_hazard ||
                             mem_wb_load_use_hazard;

    assign mem_busy = ex_mem_valid_q && (ex_mem_is_load_q || ex_mem_is_store_q) &&
                      !dmem_ready;
    assign muldiv_start = id_ex_valid_q && id_ex_is_muldiv_q &&
                          !muldiv_active_q && !muldiv_busy;
    assign core_stall = mem_busy || muldiv_start ||
                        (muldiv_active_q && !muldiv_done);
    assign can_fetch_latch = imem_ready && !core_stall &&
                             !load_use_hazard &&
                             !(id_ex_valid_q && branch_taken) && !halt &&
                             !cpu_trap;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_q          <= RESET_PC;
            fetch_pc_q    <= RESET_PC;
            fetch_valid_q <= 1'b0;
            if_id_valid_q <= 1'b0;
            id_ex_valid_q <= 1'b0;
            ex_mem_valid_q <= 1'b0;
            mem_wb_valid_q <= 1'b0;
            ex_mem_req_sent_q <= 1'b0;
            muldiv_active_q <= 1'b0;
            cpu_trap <= 1'b0;
        end else if (clear_pipeline || halt) begin
            pc_q          <= boot_pc;
            fetch_pc_q    <= boot_pc;
            fetch_valid_q <= 1'b0;
            if_id_valid_q <= 1'b0;
            id_ex_valid_q <= 1'b0;
            ex_mem_valid_q <= 1'b0;
            mem_wb_valid_q <= 1'b0;
            ex_mem_req_sent_q <= 1'b0;
            muldiv_active_q <= 1'b0;
            if (clear_pipeline) begin
                cpu_trap <= 1'b0;
            end
        end else begin
            if (imem_valid) begin
                fetch_pc_q    <= imem_addr;
                fetch_valid_q <= 1'b1;
            end

            if (muldiv_start) begin
                muldiv_active_q <= 1'b1;
            end
            if (muldiv_done) begin
                muldiv_active_q <= 1'b0;
            end

            if (ex_mem_valid_q && (ex_mem_is_load_q || ex_mem_is_store_q) &&
                !ex_mem_req_sent_q) begin
                ex_mem_req_sent_q <= 1'b1;
            end

            if (!core_stall) begin
                if (branch_taken && id_ex_valid_q) begin
                    pc_q <= branch_target;
                end else if (!load_use_hazard) begin
                    pc_q <= pc_q + 32'd4;
                end

                if (ex_mem_valid_q && (ex_mem_is_load_q || ex_mem_is_store_q)) begin
                    if (dmem_ready) begin
                        mem_wb_valid_q      <= ex_mem_valid_q && !ex_mem_is_store_q;
                        mem_wb_alu_result_q <= ex_mem_alu_result_q;
                        mem_wb_load_data_q  <= load_data_ext;
                        mem_wb_pc_plus4_q   <= ex_mem_pc_q + 32'd4;
                        mem_wb_rd_q         <= ex_mem_rd_q;
                        mem_wb_reg_write_q  <= ex_mem_reg_write_q && !ex_mem_is_store_q;
                        mem_wb_wb_sel_q     <= ex_mem_wb_sel_q;
                    end else begin
                        mem_wb_valid_q <= 1'b0;
                    end
                end else begin
                    mem_wb_valid_q      <= ex_mem_valid_q;
                    mem_wb_alu_result_q <= ex_mem_alu_result_q;
                    mem_wb_load_data_q  <= 32'h0000_0000;
                    mem_wb_pc_plus4_q   <= ex_mem_pc_q + 32'd4;
                    mem_wb_rd_q         <= ex_mem_rd_q;
                    mem_wb_reg_write_q  <= ex_mem_reg_write_q;
                    mem_wb_wb_sel_q     <= ex_mem_wb_sel_q;
                end

                if (branch_taken && id_ex_valid_q) begin
                    ex_mem_valid_q <= id_ex_valid_q;
                end else begin
                    ex_mem_valid_q <= id_ex_valid_q;
                end
                ex_mem_pc_q         <= id_ex_pc_q;
                ex_mem_alu_result_q <= ex_result;
                ex_mem_store_data_q <= ex_rs2_value;
                ex_mem_rd_q         <= id_ex_rd_q;
                ex_mem_funct3_q     <= id_ex_funct3_q;
                ex_mem_reg_write_q  <= id_ex_reg_write_q;
                ex_mem_is_load_q    <= id_ex_is_load_q;
                ex_mem_is_store_q   <= id_ex_is_store_q;
                ex_mem_wb_sel_q     <= id_ex_wb_sel_q;
                ex_mem_req_sent_q   <= 1'b0;

                if (id_ex_valid_q && id_ex_is_muldiv_q && !muldiv_done) begin
                    ex_mem_valid_q <= 1'b0;
                end

                if (branch_taken && id_ex_valid_q) begin
                    id_ex_valid_q <= 1'b0;
                    if_id_valid_q <= 1'b0;
                    fetch_valid_q <= 1'b0;
                end else if (load_use_hazard) begin
                    id_ex_valid_q <= 1'b0;
                end else begin
                    id_ex_valid_q      <= if_id_valid_q && (id_illegal === 1'b0);
                    id_ex_pc_q         <= if_id_pc_q;
                    id_ex_instr_q      <= if_id_instr_q;
                    id_ex_rs1_data_q   <= rs1_data;
                    id_ex_rs2_data_q   <= rs2_data;
                    id_ex_imm_i_q      <= id_imm_i;
                    id_ex_imm_s_q      <= id_imm_s;
                    id_ex_imm_b_q      <= id_imm_b;
                    id_ex_imm_u_q      <= id_imm_u;
                    id_ex_imm_j_q      <= id_imm_j;
                    id_ex_rs1_q        <= id_rs1;
                    id_ex_rs2_q        <= id_rs2;
                    id_ex_rd_q         <= id_rd;
                    id_ex_funct3_q     <= id_funct3;
                    id_ex_funct7_q     <= id_funct7;
                    id_ex_is_lui_q     <= id_is_lui;
                    id_ex_is_auipc_q   <= id_is_auipc;
                    id_ex_is_jal_q     <= id_is_jal;
                    id_ex_is_jalr_q    <= id_is_jalr;
                    id_ex_is_branch_q  <= id_is_branch;
                    id_ex_is_load_q    <= id_is_load;
                    id_ex_is_store_q   <= id_is_store;
                    id_ex_is_op_imm_q  <= id_is_op_imm;
                    id_ex_is_op_q      <= id_is_op;
                    id_ex_is_muldiv_q  <= id_is_muldiv;
                    id_ex_muldiv_op_q  <= id_muldiv_op;
                    id_ex_reg_write_q  <= id_is_lui || id_is_auipc ||
                                          id_is_op_imm || id_is_op ||
                                          id_is_load || id_is_jal ||
                                          id_is_jalr;
                    id_ex_wb_sel_q     <= id_is_load ? WB_MEM :
                                          ((id_is_jal || id_is_jalr) ?
                                           WB_PC4 : WB_ALU);
                    if (if_id_valid_q && (id_illegal === 1'b1)) begin
                        cpu_trap <= 1'b1;
                    end
                end

                if (can_fetch_latch) begin
                    if_id_valid_q <= 1'b1;
                    if_id_pc_q    <= imem_addr;
                    if_id_instr_q <= imem_rdata;
                end else if (!load_use_hazard && !(id_ex_valid_q && branch_taken)) begin
                    if_id_valid_q <= 1'b0;
                end
            end
        end
    end

    wire unused_decode = ^{id_opcode, id_muldiv_is_div, id_muldiv_is_signed,
                           id_ex_instr_q, OPCODE_LUI, OPCODE_AUIPC,
                           OPCODE_JAL, OPCODE_JALR, OPCODE_BRANCH,
                           OPCODE_LOAD, OPCODE_STORE, OPCODE_OP_IMM, OPCODE_OP};

endmodule
