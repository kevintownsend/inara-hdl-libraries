module simple_ram(clk, wr_en, d, addr, q);
    parameter WIDTH = 64;
    parameter ADDR_WIDTH = 8;
    parameter DEPTH = 1<<ADDR_WIDTH;
    input clk;
    input wr_en;
    input [WIDTH-1:0] d;
    input [ADDR_WIDTH-1:0] addr;
    output [WIDTH-1:0] q;

    reg [WIDTH-1:0] ram [0:DEPTH-1];
    reg [WIDTH-1:0] r_q;
    
    always @(posedge clk) begin
        if(wr_en)
            ram[addr] <= d;
        r_q <= ram[addr];
    end
    assign q = r_q;
endmodule
