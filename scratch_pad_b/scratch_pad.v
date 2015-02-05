module scratch_pad(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    parameter PORTS = 8;
    parameter WIDTH = 64;
    parameter FRAGMENT_DEPTH = 512;
    parameter DEPTH = FRAGMENT_DEPTH * PORTS;
    parameter ADDR_WIDTH = log2(DEPTH-1);
    parameter PORTS_ADDR_WIDTH = log2(PORTS-1);
    input rst;
    input clk;
    input [0:PORTS-1] rd_en;
    input [0:PORTS-1] wr_en;
    input [WIDTH*PORTS-1:0] d;
    output reg [WIDTH*PORTS-1:0] q;
    input [ADDR_WIDTH*PORTS-1:0] addr;
    output [0:PORTS-1] full;
    input [0:PORTS-1]stall;
    output [0:PORTS-1]valid;
    `include "log2.vh"

endmodule
