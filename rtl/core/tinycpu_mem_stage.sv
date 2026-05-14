// Memory stage AXI-Lite request descriptor helper.
module tinycpu_mem_stage (
    input  logic        load,
    input  logic        store,
    input  logic [31:0] addr,
    input  logic [31:0] store_data,
    output logic        req_read,
    output logic        req_write,
    output logic [31:0] req_addr,
    output logic [31:0] req_wdata,
    output logic [3:0]  req_wstrb
);

    assign req_read  = load;
    assign req_write = store;
    assign req_addr  = addr;
    assign req_wdata = store_data;
    assign req_wstrb = 4'b1111;

endmodule
