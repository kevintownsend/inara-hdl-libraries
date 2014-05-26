module arbiter(rst, clk, push, d, full, q, stall, valid, almost_full);
    parameter WIDTH = 8;
    parameter PORTS = 8;
    parameter FIFO_DEPTH = 32;
    parameter ALMOST_FULL_THRESHOLD = 1;
    parameter PORTS_ADDR_WIDTH = log2(PORTS-1);
    parameter FIFO_DEPTH_ADDR_WIDTH = log2(FIFO_DEPTH-1);
    
    input rst;
    input clk;
    input [0:PORTS-1]push;
    input [WIDTH*PORTS-1:0] d;
    output [0:PORTS-1]full;
    output [WIDTH-1:0] q;
    input stall;
    output valid;
    output [0:PORTS-1] almost_full;

    //TODO: std_fifos
    wire [0:PORTS-1]almost_empty;
    reg [0:PORTS-1]pop;
    wire [0:PORTS-1]empty;
    wire [FIFO_DEPTH_ADDR_WIDTH:0] count[0:PORTS-1];
    wire [WIDTH-1:0] fifo_q[0:PORTS-1];
    reg [WIDTH-1:0]fifo_d[0:PORTS-1];
    integer i, j;
    always @* begin
        for(i = 0; i < PORTS; i = i + 1) begin
            for(j = 0; j < WIDTH; j = j + 1) begin
                fifo_d[i][j] = d[(PORTS - i - 1) * WIDTH + j];
            end
        end
    end

    genvar lane;
    generate
        for(lane = 0; lane < PORTS; lane = lane + 1) begin: fifo_generate
            std_fifo #(.DEPTH(FIFO_DEPTH), .WIDTH(WIDTH), .ALMOST_FULL_COUNT(ALMOST_FULL_THRESHOLD)) fifo(rst, clk, push[lane], pop[lane], fifo_d[lane], fifo_q[lane], full[lane], empty[lane], count[lane], almost_empty[lane], almost_full[lane]);
        end
    endgenerate

    reg [PORTS_ADDR_WIDTH-1:0] processing, next_processing, prev_processing;
    always @* begin
        pop = 0;
        next_processing = processing;
        if(!empty[processing])
            pop[processing] = 1;
        if(almost_empty[processing])
            next_processing = processing + 1;
        if(next_processing == PORTS)
            next_processing = 0;
        if(rst)
            next_processing = 0;
    end

    always @(posedge clk) begin
        processing <= next_processing;
        prev_processing <= processing;
    end

    //TODO: stall
    reg r_valid, r_valid2;
    reg [WIDTH-1:0] r_q;
    always @(posedge clk) begin
        r_q = fifo_q[prev_processing];
        r_valid <= |pop;
        r_valid2 <= r_valid;
    end


    assign q = r_q;
    assign valid = r_valid2;
    always @(posedge clk) begin
        //$display("empty: %H", empty);
    end

    `include "log2.vh"
endmodule
