module scratch_pad_gold(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
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
    output [WIDTH*PORTS-1:0] q;
    input [ADDR_WIDTH*PORTS-1:0] addr;
    output [0:PORTS-1] full;
    input [0:PORTS-1]stall;
    output [0:PORTS-1]valid;
    `include "log2.vh"
    
    wire [ADDR_WIDTH-1:0] addr_2d [0:PORTS-1];
    genvar g;
    generate for(g = 0; g < PORTS; g = g + 1) begin : addr_gen
        assign addr_2d[g] = addr[(PORTS-g)*ADDR_WIDTH-1-:ADDR_WIDTH];
    end
    endgenerate
    wire [WIDTH-1:0] d_2d [0:PORTS-1];
    generate for(g = 0; g < PORTS; g = g + 1) begin : d_gen
        assign d_2d[g] = d[(PORTS-g) * WIDTH - 1-: WIDTH];
    end
    endgenerate
    reg [WIDTH-1:0] ram [0:DEPTH-1];
    integer i;

    reg [WIDTH-1:0] q_2d [0:PORTS-1];
    always @(posedge clk) begin
        for(i = 0; i < PORTS; i = i + 1) begin
            if(wr_en[i]) begin
                ram[addr_2d[i]] <= d_2d[i];
            end
            q_2d[i] <= ram[addr_2d[i]];
        end
    end
    //TODO: generate q
    generate for(g = 0; g < PORTS; g = g + 1) begin : q_gen
        assign q[(g + 1) * WIDTH -1 -: WIDTH] = q_2d[PORTS - 1 - g];
    end
    endgenerate

    assign full = stall;
    reg [0:PORTS-1] valid_r;
    always @(posedge clk) begin
        valid_r <= rd_en;
    end
    assign valid = valid_r;

endmodule
