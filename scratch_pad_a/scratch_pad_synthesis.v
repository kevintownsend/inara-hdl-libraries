module scratch_pad_synthesis(clk, in, out, sel);
    input clk, in, sel;
    output out;
    reg rst;
    reg [15:0] rd_en;
    reg [15:0] wr_en;
    reg [16*64-1:0] d;
    wire [16*64-1:0] q;
    reg [16*12-1:0] addr;
    reg [15:0] stall;
    wire [15:0] valid;
    wire [15:0] full;
    scratch_pad dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    //TODO: parameters
endmodule
