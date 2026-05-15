// Clean-room RV32IM-target tiny CPU with one AXI-Lite master port.
//
// v0.4-fuller-rv32i-c-support implements the RV32I integer base needed for
// simple freestanding C. The project target remains RV32IM; the M extension is
// intentionally left in tinycpu_muldiv.sv for a later integration step.
//
// The file is organized around the classic five stages (IF, ID, EX, MEM, WB).
// Because this teaching SoC has one simple AXI-Lite master for both instruction
// fetch and data access, the current implementation globally stalls around bus
// transactions. The explicit stage helper modules keep the pipeline boundaries,
// hazard policy, and future forwarding/stall work visible.
module tinycpu_core_rv32im_axil #(
    parameter logic [31:0] RESET_PC = 32'h0000_0000
) (
    input  logic        clk,
    input  logic        rst,

    output logic [31:0] m_axi_awaddr,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,
    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,
    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready,

    output logic [31:0] m_axi_araddr,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,
    input  logic [31:0] m_axi_rdata,
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready
);

    localparam logic [3:0] ST_RESET          = 4'd0;
    localparam logic [3:0] ST_IF_ADDR        = 4'd1;
    localparam logic [3:0] ST_IF_DATA        = 4'd2;
    localparam logic [3:0] ST_ID             = 4'd3;
    localparam logic [3:0] ST_EX             = 4'd4;
    localparam logic [3:0] ST_MEM_LOAD_ADDR  = 4'd5;
    localparam logic [3:0] ST_MEM_LOAD_DATA  = 4'd6;
    localparam logic [3:0] ST_MEM_STORE_REQ  = 4'd7;
    localparam logic [3:0] ST_MEM_STORE_RESP = 4'd8;
    localparam logic [3:0] ST_WB             = 4'd9;
    localparam logic [3:0] ST_TRAP           = 4'd10;

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

    localparam logic [6:0] FUNCT7_ALT  = 7'b0100000;

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

    logic [3:0] state;

    logic [31:0] pc;
    logic [31:0] if_instr;
    logic [31:0] id_instr;
    logic [31:0] id_pc;

    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_u;
    logic [31:0] imm_j;
    logic        is_lui;
    logic        is_auipc;
    logic        is_jal;
    logic        is_jalr;
    logic        is_branch;
    logic        is_load;
    logic        is_store;
    logic        is_op_imm;
    logic        is_op;
    logic        illegal;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        rd_we;
    logic [4:0]  rd_waddr;
    logic [31:0] rd_wdata;

    logic [31:0] ex_result;
    logic [31:0] ex_store_data;
    logic [31:0] ex_pc_plus4;
    logic [4:0]  ex_rd;
    logic        ex_reg_write;
    logic        ex_is_load;
    logic        ex_is_store;
    logic [2:0]  ex_funct3;
    logic [1:0]  ex_wb_sel;
    logic        branch_taken;
    logic [31:0] branch_target;

    logic [31:0] load_word;
    logic [31:0] load_data;
    logic        aw_done;
    logic        w_done;
    logic        suppress_pc_advance;

    logic [31:0] alu_b;
    logic [3:0]  alu_op;
    logic [31:0] alu_result;
    logic        ex_eq;
    logic        ex_lt;
    logic        ex_ltu;
    logic [31:0] load_shifted;
    logic [31:0] store_shifted;
    logic [3:0]  store_wstrb;
    logic [31:0] wb_mux_data;

    logic unused_h_stall_if;
    logic unused_h_stall_id;
    logic unused_h_flush_if_id;
    logic unused_h_flush_id_ex;

    tinycpu_if_stage #(
        .RESET_PC(RESET_PC)
    ) if_stage_i (
        .clk           (clk),
        .rst           (rst),
        .advance       ((state == ST_WB) && !suppress_pc_advance),
        .redirect_valid(branch_taken),
        .redirect_pc   (branch_target),
        .pc            (pc)
    );

    tinycpu_decode decode_i (
        .instr    (id_instr),
        .opcode   (opcode),
        .funct3   (funct3),
        .funct7   (funct7),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .imm_i    (imm_i),
        .imm_s    (imm_s),
        .imm_b    (imm_b),
        .imm_u    (imm_u),
        .imm_j    (imm_j),
        .is_lui   (is_lui),
        .is_auipc (is_auipc),
        .is_jal   (is_jal),
        .is_jalr  (is_jalr),
        .is_branch(is_branch),
        .is_load  (is_load),
        .is_store (is_store),
        .is_op_imm(is_op_imm),
        .is_op    (is_op),
        .illegal  (illegal)
    );

    tinycpu_regfile regfile_i (
        .clk      (clk),
        .rst      (rst),
        .rs1_addr (rs1),
        .rs1_rdata(rs1_data),
        .rs2_addr (rs2),
        .rs2_rdata(rs2_data),
        .rd_we    (rd_we),
        .rd_addr  (rd_waddr),
        .rd_wdata (rd_wdata)
    );

    assign alu_b = (is_op || is_branch) ? rs2_data :
                   (is_store ? imm_s : imm_i);

    always @* begin
        alu_op = ALU_ADD;

        if (is_op || is_op_imm) begin
            case (funct3)
                FUNCT3_ADDI_SL: begin
                    alu_op = (is_op && (funct7 == FUNCT7_ALT)) ? ALU_SUB : ALU_ADD;
                end
                FUNCT3_SLL: begin
                    alu_op = ALU_SLL;
                end
                FUNCT3_SLT: begin
                    alu_op = ALU_SLT;
                end
                FUNCT3_SLTU: begin
                    alu_op = ALU_SLTU;
                end
                FUNCT3_XOR: begin
                    alu_op = ALU_XOR;
                end
                FUNCT3_SHIFT_R: begin
                    alu_op = (funct7 == FUNCT7_ALT) ? ALU_SRA : ALU_SRL;
                end
                FUNCT3_OR: begin
                    alu_op = ALU_OR;
                end
                FUNCT3_AND: begin
                    alu_op = ALU_AND;
                end
                default: begin
                    alu_op = ALU_ADD;
                end
            endcase
        end
    end

    tinycpu_ex_stage ex_stage_i (
        .a     (rs1_data),
        .b     (alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .eq    (ex_eq)
    );

    tinycpu_wb_stage wb_stage_i (
        .alu_result(ex_result),
        .load_data (load_data),
        .pc_plus4  (ex_pc_plus4),
        .wb_sel    (ex_wb_sel),
        .wb_data   (wb_mux_data)
    );

    tinycpu_hazard hazard_i (
        .id_valid     (state == ST_ID),
        .id_rs1       (rs1),
        .id_rs2       (rs2),
        .ex_valid     (state == ST_EX),
        .ex_is_load   (ex_is_load),
        .ex_rd        (ex_rd),
        .branch_taken (branch_taken),
        .stall_if     (unused_h_stall_if),
        .stall_id     (unused_h_stall_id),
        .flush_if_id  (unused_h_flush_if_id),
        .flush_id_ex  (unused_h_flush_id_ex)
    );

    always @* begin
        branch_taken  = 1'b0;
        branch_target = id_pc + 32'd4;
        ex_lt         = $signed(rs1_data) < $signed(rs2_data);
        ex_ltu        = rs1_data < rs2_data;

        if (is_branch) begin
            case (funct3)
                FUNCT3_BEQ:  branch_taken = ex_eq;
                FUNCT3_BNE:  branch_taken = !ex_eq;
                FUNCT3_BLT:  branch_taken = ex_lt;
                FUNCT3_BGE:  branch_taken = !ex_lt;
                FUNCT3_BLTU: branch_taken = ex_ltu;
                FUNCT3_BGEU: branch_taken = !ex_ltu;
                default:     branch_taken = 1'b0;
            endcase
            branch_target = id_pc + imm_b;
        end else if (is_jal) begin
            branch_taken  = 1'b1;
            branch_target = id_pc + imm_j;
        end else if (is_jalr) begin
            branch_taken  = 1'b1;
            branch_target = (rs1_data + imm_i) & 32'hFFFF_FFFE;
        end
    end

    always @* begin
        rd_we    = (state == ST_WB) && ex_reg_write;
        rd_waddr = ex_rd;
        rd_wdata = wb_mux_data;
    end

    always @* begin
        load_shifted = load_word >> {ex_result[1:0], 3'b000};
        case (ex_funct3)
            FUNCT3_LB:  load_data = {{24{load_shifted[7]}}, load_shifted[7:0]};
            FUNCT3_LH:  load_data = {{16{load_shifted[15]}}, load_shifted[15:0]};
            FUNCT3_LW:  load_data = load_word;
            FUNCT3_LBU: load_data = {24'b0, load_shifted[7:0]};
            FUNCT3_LHU: load_data = {16'b0, load_shifted[15:0]};
            default:    load_data = 32'h0000_0000;
        endcase
    end

    always @* begin
        store_shifted = 32'h0000_0000;
        store_wstrb   = 4'b0000;

        case (ex_funct3)
            FUNCT3_SB: begin
                store_shifted = {4{ex_store_data[7:0]}} << {ex_result[1:0], 3'b000};
                store_wstrb   = 4'b0001 << ex_result[1:0];
            end
            FUNCT3_SH: begin
                store_shifted = {2{ex_store_data[15:0]}} << {ex_result[1:0], 3'b000};
                store_wstrb   = 4'b0011 << ex_result[1:0];
            end
            FUNCT3_SW: begin
                store_shifted = ex_store_data;
                store_wstrb   = 4'b1111;
            end
            default: begin
                store_shifted = 32'h0000_0000;
                store_wstrb   = 4'b0000;
            end
        endcase
    end

    always @* begin
        m_axi_araddr  = 32'h0000_0000;
        m_axi_arvalid = 1'b0;
        m_axi_rready  = 1'b0;

        m_axi_awaddr  = 32'h0000_0000;
        m_axi_awvalid = 1'b0;
        m_axi_wdata   = 32'h0000_0000;
        m_axi_wstrb   = 4'b1111;
        m_axi_wvalid  = 1'b0;
        m_axi_bready  = 1'b0;

        case (state)
            ST_IF_ADDR: begin
                m_axi_araddr  = pc;
                m_axi_arvalid = 1'b1;
            end

            ST_IF_DATA: begin
                m_axi_rready = 1'b1;
            end

            ST_MEM_LOAD_ADDR: begin
                m_axi_araddr  = {ex_result[31:2], 2'b00};
                m_axi_arvalid = 1'b1;
            end

            ST_MEM_LOAD_DATA: begin
                m_axi_rready = 1'b1;
            end

            ST_MEM_STORE_REQ: begin
                m_axi_awaddr  = {ex_result[31:2], 2'b00};
                m_axi_awvalid = !aw_done;
                m_axi_wdata   = store_shifted;
                m_axi_wstrb   = store_wstrb;
                m_axi_wvalid  = !w_done;
            end

            ST_MEM_STORE_RESP: begin
                m_axi_bready = 1'b1;
            end

            default: begin
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state         <= ST_RESET;
            if_instr      <= 32'h0000_0013;
            id_instr      <= 32'h0000_0013;
            id_pc         <= RESET_PC;
            ex_result     <= 32'h0000_0000;
            ex_store_data <= 32'h0000_0000;
            ex_pc_plus4   <= 32'h0000_0004;
            ex_rd         <= 5'd0;
            ex_reg_write  <= 1'b0;
            ex_is_load    <= 1'b0;
            ex_is_store   <= 1'b0;
            ex_funct3     <= 3'b000;
            ex_wb_sel     <= WB_ALU;
            load_word     <= 32'h0000_0000;
            aw_done       <= 1'b0;
            w_done        <= 1'b0;
            suppress_pc_advance <= 1'b0;
        end else begin
            case (state)
                ST_RESET: begin
                    state <= ST_IF_ADDR;
                end

                ST_IF_ADDR: begin
                    if (m_axi_arready) begin
                        state <= ST_IF_DATA;
                    end
                end

                ST_IF_DATA: begin
                    if (m_axi_rvalid) begin
                        if_instr <= m_axi_rdata;
                        id_instr <= m_axi_rdata;
                        id_pc    <= pc;
                        state    <= ST_ID;
                    end
                end

                ST_ID: begin
                    if (illegal) begin
                        state <= ST_TRAP;
                    end else begin
                        state <= ST_EX;
                    end
                end

                ST_EX: begin
                    ex_pc_plus4   <= id_pc + 32'd4;
                    ex_rd         <= rd;
                    ex_reg_write  <= is_lui || is_auipc || is_op_imm || is_op || is_load || is_jal || is_jalr;
                    ex_is_load    <= is_load;
                    ex_is_store   <= is_store;
                    ex_funct3     <= funct3;
                    ex_store_data <= rs2_data;
                    ex_wb_sel     <= (is_load ? WB_MEM : ((is_jal || is_jalr) ? WB_PC4 : WB_ALU));

                    if (is_lui) begin
                        ex_result <= imm_u;
                    end else if (is_auipc) begin
                        ex_result <= id_pc + imm_u;
                    end else begin
                        ex_result <= alu_result;
                    end

                    if (is_load) begin
                        state <= ST_MEM_LOAD_ADDR;
                    end else if (is_store) begin
                        aw_done <= 1'b0;
                        w_done  <= 1'b0;
                        state   <= ST_MEM_STORE_REQ;
                    end else begin
                        suppress_pc_advance <= branch_taken;
                        state <= ST_WB;
                    end
                end

                ST_MEM_LOAD_ADDR: begin
                    if (m_axi_arready) begin
                        state <= ST_MEM_LOAD_DATA;
                    end
                end

                ST_MEM_LOAD_DATA: begin
                    if (m_axi_rvalid) begin
                        load_word <= m_axi_rdata;
                        state     <= ST_WB;
                    end
                end

                ST_MEM_STORE_REQ: begin
                    if (m_axi_awready) begin
                        aw_done <= 1'b1;
                    end
                    if (m_axi_wready) begin
                        w_done <= 1'b1;
                    end
                    if ((aw_done || m_axi_awready) && (w_done || m_axi_wready)) begin
                        state <= ST_MEM_STORE_RESP;
                    end
                end

                ST_MEM_STORE_RESP: begin
                    if (m_axi_bvalid) begin
                        aw_done <= 1'b0;
                        w_done  <= 1'b0;
                        state   <= ST_WB;
                    end
                end

                ST_WB: begin
                    suppress_pc_advance <= 1'b0;
                    state <= ST_IF_ADDR;
                end

                ST_TRAP: begin
                    state <= ST_TRAP;
                end

                default: begin
                    state <= ST_TRAP;
                end
            endcase
        end
    end

    wire unused_responses = ^{m_axi_bresp, m_axi_rresp, if_instr, ex_is_store,
                              unused_h_stall_if,
                              unused_h_stall_id, unused_h_flush_if_id, unused_h_flush_id_ex};

endmodule
