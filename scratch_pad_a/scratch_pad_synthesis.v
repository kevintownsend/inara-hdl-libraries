module scratch_pad_synthesis(clk, in, out, sel);
    parameter PORTS = 8;
    parameter WIDTH = 64;
    parameter FRAGMENT_DEPTH = 512;
    parameter REORDER_DEPTH = 32;
    parameter FIFO_DEPTH = 32;
    parameter REORDER_BITS = log2(REORDER_DEPTH-1) + 1;
    parameter DEPTH = FRAGMENT_DEPTH * PORTS;
    parameter ADDR_WIDTH = log2(DEPTH-1);
    parameter PORTS_ADDR_WIDTH = log2(PORTS-1);
    input clk, in, sel;
    output reg out;

    reg rst;
    reg [0:PORTS-1] rd_en;
    reg [0:PORTS-1] wr_en;
    reg [WIDTH*PORTS-1:0] d;
    wire [WIDTH*PORTS-1:0] q;
    reg [ADDR_WIDTH*PORTS-1:0] addr;
    wire [0:PORTS-1] full;
    reg [0:PORTS-1]stall;
    wire [0:PORTS-1]valid;
    scratch_pad #(PORTS, WIDTH) dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);

    always @(posedge clk) begin
        rst <= in;
        rd_en[0] <= rst;
        rd_en[1:PORTS - 1] <= rd_en[0:PORTS - 2];
        wr_en[0] <= rd_en[PORTS - 1];
        wr_en[1:PORTS - 1] <= wr_en[0:PORTS - 2];
        d[0] <= wr_en[PORTS - 1];
        d[WIDTH * PORTS - 1:1] <= d[WIDTH * PORTS - 2:0];
        addr[0] <= d[WIDTH * PORTS - 1];
        addr[PORTS * ADDR_WIDTH - 1:1] <= addr[PORTS * ADDR_WIDTH - 2:0];
        stall[0] <= addr[PORTS * ADDR_WIDTH - 1];
        stall[1:PORTS - 1] <= stall[0:PORTS - 2];
    end
    reg [0:WIDTH * PORTS + 2 * PORTS - 1] output_shift;
    always @(posedge clk) begin
        if(sel == 1) begin
            output_shift[0:PORTS * WIDTH - 1] <= q;
            output_shift[PORTS * WIDTH +: PORTS] <= full;
            output_shift[PORTS * WIDTH + PORTS +: PORTS] <= valid;
        end else begin
            output_shift[1:PORTS * WIDTH + 2 * PORTS - 1] <= output_shift[0:PORTS * WIDTH + 2 * PORTS - 2];
            out <= output_shift[PORTS * WIDTH + 2 * PORTS - 1];
        end

    end
    `include "common.vh"
endmodule
