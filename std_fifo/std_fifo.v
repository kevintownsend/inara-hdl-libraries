module std_fifo(rst, clk, push, pop, d, q, full, empty, count, almost_empty, almost_full);
    parameter WIDTH = 8;
    parameter DEPTH = 6;
    parameter DEPTH_ADDR_WIDTH = log2(DEPTH-1);
    parameter ALMOST_EMPTY_COUNT = 1;
    parameter ALMOST_FULL_COUNT = 1;
    input rst;
    input clk;
    input push;
    input pop;
    input [WIDTH-1:0] d;
    output [WIDTH-1:0] q;
    output full;
    output empty;
    output [DEPTH_ADDR_WIDTH:0]count;
    output almost_empty;
    output almost_full;

    reg [WIDTH-1:0] r_q;
    reg [DEPTH_ADDR_WIDTH:0] r_end;
    reg [DEPTH_ADDR_WIDTH:0] r_beg;

    reg [WIDTH-1:0] ram [DEPTH-1:0];
    always @(posedge clk) begin
        if(rst) begin
            r_end <= 0;
            r_beg <= 0;
        end else begin
            r_q <= ram[r_end[DEPTH_ADDR_WIDTH-1:0]];
            if(pop)
                r_end <= r_end + 1;
            if(push) begin
                r_beg <= r_beg + 1;
                ram[r_beg[DEPTH_ADDR_WIDTH-1:0]] <= d;
            end
        end
    end
    assign q = r_q;
    assign empty = (r_end == r_beg);
    assign full = (r_end[DEPTH_ADDR_WIDTH-1:0] == r_beg[DEPTH_ADDR_WIDTH-1:0]) && (r_end[DEPTH_ADDR_WIDTH] != r_beg[DEPTH_ADDR_WIDTH]);
    assign count = r_beg - r_end;
    assign almost_empty = (count < (1+ALMOST_EMPTY_COUNT));
    assign almost_full = (count > (DEPTH-1-ALMOST_FULL_COUNT));

    always @(posedge clk) begin
        if(full && push) begin
            $display("ERROR: Overflow at %m");
            $finish;
        end
        if(empty && pop) begin
            $display("ERROR: underflow at %m");
            $finish;
        end
    end

    `include "log2.vh"
endmodule
