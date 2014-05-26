module cross_bar(rst, clk, wr_en, d, full, valid, q, stall, almost_full);
    parameter WIDTH = 8;
    parameter IN_PORTS = 8;
    parameter OUT_PORTS = IN_PORTS;
    parameter FIFO_DEPTH = 32;
    parameter IN_PORTS_ADDR_WIDTH = log2(IN_PORTS-1);
    parameter OUT_PORTS_ADDR_WIDTH = log2(OUT_PORTS-1);
    parameter OUT_PORT_ADDR_LSB = 0;
    parameter ALMOST_FULL_THRESHOLD = 1;
    input rst;
    input clk;
    input [0:IN_PORTS-1] wr_en;
    input [WIDTH*IN_PORTS - 1:0]d;
    output reg [0:IN_PORTS-1] full;
    output [0:OUT_PORTS-1] valid;
    output reg [WIDTH*OUT_PORTS-1:0] q;
    input [0:OUT_PORTS-1]stall;
    output reg [0:IN_PORTS-1] almost_full;
    reg [WIDTH-1:0]d_internal [0:IN_PORTS-1];
    wire [WIDTH-1:0] q_internal [0:OUT_PORTS-1];

    //TODO: internal d and q
    integer i, j;
    always @* begin
        for(i = 0; i < IN_PORTS; i = i + 1)
            for(j = 0; j < WIDTH; j = j + 1)
                d_internal[i][j] = d[(IN_PORTS - i - 1)*WIDTH + j];
    end
    always @* begin
        for(i = 0; i < OUT_PORTS; i = i + 1)
            for(j = 0; j < WIDTH; j = j + 1)
                q[(OUT_PORTS - i - 1) * WIDTH+ j] = q_internal[i][j];
    end
    reg [0:IN_PORTS-1]wr_en_internal[0:OUT_PORTS-1];
    wire [0:IN_PORTS-1]full_internal[0:OUT_PORTS-1];
    reg [0:OUT_PORTS-1]full_internal_t[0:IN_PORTS-1];
    wire [0:IN_PORTS-1]almost_full_internal[0:OUT_PORTS-1];
    reg [0:OUT_PORTS-1]almost_full_internal_t[0:IN_PORTS-1];
    always @* begin
        for(i = 0; i < OUT_PORTS; i = i + 1)
            wr_en_internal[i] = 'H0;
        for(i = 0; i < IN_PORTS; i = i + 1)
            if(wr_en[i])
                wr_en_internal[d_internal[i][OUT_PORTS_ADDR_WIDTH+OUT_PORT_ADDR_LSB-1:OUT_PORT_ADDR_LSB]][i] = 1'b1;
    end
    always @* begin
        for(i = 0; i < OUT_PORTS; i = i + 1)
            for(j = 0; j < IN_PORTS; j = j + 1)
                full_internal_t[j][i] = full_internal[i][j];
        for(i = 0; i < IN_PORTS; i = i + 1)
            full[i] = |full_internal_t[i];
    end

    always @* begin
        for(i = 0; i < OUT_PORTS; i = i + 1)
            for(j = 0; j < IN_PORTS; j = j + 1)
                almost_full_internal_t[j][i] = almost_full_internal[i][j];
        for(i = 0; i < IN_PORTS; i = i + 1)
            almost_full[i] = |almost_full_internal_t[i];
    end

    genvar out_lane;
    generate
        for(out_lane = 0; out_lane < OUT_PORTS; out_lane = out_lane + 1) begin: gen_arbiter
            arbiter #(WIDTH, IN_PORTS, FIFO_DEPTH, ALMOST_FULL_THRESHOLD) arb(rst, clk, wr_en_internal[out_lane], d, full_internal[out_lane], q_internal[out_lane], stall[out_lane], valid[out_lane], almost_full_internal[out_lane]);
        end
    endgenerate
    //DEBUG
    always @(posedge clk) begin
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            if(wr_en[i])
                //$display("cross_bar_write: %d, %d", i, d_internal[i]);
            if(valid[i]) begin
                //$display("cross_bar push: %d, %d", i, q_internal[i]);
             //   $display("continued: %H", q);
            end
            //$display("dump: %H %H %H %H %H %H", wr_en_internal[i], d, full_internal[i], q_internal[i], stall[i], valid[i]);
        end
    end
    `include "log2.vh"
endmodule
