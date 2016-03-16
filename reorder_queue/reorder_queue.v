module reorder_queue(rst, clk, increment, index_tag, full, wr_en, d, q, valid, stall);
    parameter WIDTH = 64;
    parameter DEPTH = 64;
    parameter D_INDEX_LOCATION = 0;
    parameter ADDR_DEPTH_WIDTH = log2(DEPTH-1);
    input rst, clk;
    input increment;
    output [ADDR_DEPTH_WIDTH:0] index_tag;
    output full;
    input wr_en;
    input [WIDTH-1:0] d;
    output reg [WIDTH-1:0] q;
    output reg valid;
    input stall;
    `include "log2.vh"

    reg r_rst;
    always @(posedge clk)
        r_rst <= rst;

    reg [ADDR_DEPTH_WIDTH:0] beg_ptr, end_ptr;

    reg [WIDTH-1:0] ram [0:DEPTH-1];
    reg [0:DEPTH-1] occupency_array;

    reg state, next_state;
    `define RESET_STATE 1
    `define STEADY_STATE 0
    reg occupency_array_wr_en, occupency_array_d;
    wire occupency_array_q;
    reg [ADDR_DEPTH_WIDTH-1:0] occupency_array_addr_a;
    wire [ADDR_DEPTH_WIDTH-1:0] occupency_array_addr_b;
    assign occupency_array_addr_b = beg_ptr;
    always @(posedge clk) begin
        if(occupency_array_wr_en)
            occupency_array[occupency_array_addr_a] <= occupency_array_d;
    end
    assign occupency_array_q = occupency_array[occupency_array_addr_b];

    always @(posedge clk) begin
        if(wr_en)
            ram[d[ADDR_DEPTH_WIDTH+D_INDEX_LOCATION-1:D_INDEX_LOCATION]] <= d;
        q <= ram[beg_ptr[ADDR_DEPTH_WIDTH-1:0]];
    end

    //TODO: use beg_ptr as part of reset

    always @(posedge clk) begin
        valid <= 0;
        if(state == `RESET_STATE)begin
            if(r_rst)
                end_ptr <= 1;
            else if(end_ptr == 0)
                state <= `STEADY_STATE;
            else
                end_ptr <= end_ptr + 1;
            beg_ptr <= 0;
        end else if(state == `STEADY_STATE) begin
            if(increment)
                end_ptr <= end_ptr + 1;
            if(beg_ptr[ADDR_DEPTH_WIDTH] == occupency_array_q && !stall) begin
                valid <= 1;
                beg_ptr <= beg_ptr + 1;
            end
        end
        if(r_rst)
            state <= `RESET_STATE;
    end

    always @* begin
        if(state == `RESET_STATE)begin
            occupency_array_d = 1;
            occupency_array_addr_a = end_ptr;
            occupency_array_wr_en = 1;
        end else if(state == `STEADY_STATE) begin
            occupency_array_d = d[D_INDEX_LOCATION+ADDR_DEPTH_WIDTH];
            occupency_array_addr_a = d[D_INDEX_LOCATION+ADDR_DEPTH_WIDTH-1:D_INDEX_LOCATION];
            occupency_array_wr_en = wr_en;
        end else begin
            occupency_array_d = 1;
            occupency_array_addr_a = end_ptr;
            occupency_array_wr_en = 0;
        end
    end
    assign index_tag = end_ptr;
    assign full = (beg_ptr[ADDR_DEPTH_WIDTH-1:0] == end_ptr[ADDR_DEPTH_WIDTH-1:0]) && (beg_ptr[ADDR_DEPTH_WIDTH] != end_ptr[ADDR_DEPTH_WIDTH]);
    //TODO: raise error if full and increment
    always @(posedge clk) begin
        if(full) begin
            //$display("WARNING: %d, %m is full", $time);
        end
        if(full && increment) begin
            $display("ERROR: %d, %m OVERFLOW", $time);
            //$finish;
        end
    end
endmodule
