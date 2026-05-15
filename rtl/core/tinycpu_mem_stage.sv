// Memory stage AXI-Lite request descriptor helper.
module tinycpu_mem_stage (
    input  logic        load,
    input  logic        store,
    input  logic [2:0]  funct3,
    input  logic [31:0] addr,
    input  logic [31:0] store_data,
    output logic        req_read,
    output logic        req_write,
    output logic [31:0] req_addr,
    output logic [31:0] req_wdata,
    output logic [3:0]  req_wstrb
);

    localparam logic [2:0] FUNCT3_SB = 3'b000;
    localparam logic [2:0] FUNCT3_SH = 3'b001;
    localparam logic [2:0] FUNCT3_SW = 3'b010;

    assign req_read  = load;
    assign req_write = store;
    assign req_addr  = {addr[31:2], 2'b00};

    always @* begin
        req_wdata = 32'h0000_0000;
        req_wstrb = 4'b0000;

        case (funct3)
            FUNCT3_SB: begin
                req_wdata = {4{store_data[7:0]}} << {addr[1:0], 3'b000};
                req_wstrb = 4'b0001 << addr[1:0];
            end
            FUNCT3_SH: begin
                req_wdata = {2{store_data[15:0]}} << {addr[1:0], 3'b000};
                req_wstrb = 4'b0011 << addr[1:0];
            end
            FUNCT3_SW: begin
                req_wdata = store_data;
                req_wstrb = 4'b1111;
            end
            default: begin
                req_wdata = 32'h0000_0000;
                req_wstrb = 4'b0000;
            end
        endcase
    end

endmodule
