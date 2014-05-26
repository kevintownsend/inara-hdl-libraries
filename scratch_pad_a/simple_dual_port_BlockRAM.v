module simple_dual_port_BlockRAM(clk, wr_en, d, addr_a, addr_b, q_a, q_b);
    parameter WIDTH = 64;
    parameter ADDR_WIDTH = 8;
    parameter DEPTH = 1<<ADDR_WIDTH;
    input clk;
    input wr_en;
    input [WIDTH-1:0] d;
    input [ADDR_WIDTH-1:0] addr_a;
    input [ADDR_WIDTH-1:0] addr_b;
    output [WIDTH-1:0] q_a;
    output [WIDTH-1:0] q_b;

    reg [WIDTH-1:0] ram [0:DEPTH-1];
    reg [WIDTH-1:0] r_q_a;
    reg [WIDTH-1:0] r_q_b;
    
    always @(posedge clk) begin
        if(wr_en)
            ram[addr_a] <= d;
        r_q_a <= ram[addr_a];
        r_q_b <= ram[addr_b];
    end
    assign q_a = r_q_a;
    assign q_b = r_q_b;

endmodule
