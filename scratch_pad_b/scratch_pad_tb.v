module scratch_pad_tb;
    `include "log2.vh"
    `define PORTS 16
    `define WIDTH 64
    `define DEPTH PORTS*512
    `define ADDR_WIDTH log2(DEPTH-1)
    reg rst, clk;
    reg [0:7] rd_en, wr_en;
    reg [8*64-1:0] d;
    wire [8*64-1:0] q;
    reg [8*12-1:0] addr;
    reg [0:7] stall;
    wire [0:7] valid, full;
    

    scratch_pad dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    
    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end
    initial begin
        $monitor(valid[0]);
        rst = 1;
        rd_en = 0;
        wr_en = 0;
        d = 0;
        addr = 0;
        stall = 0;
        #101 rst = 0;
        #1000 wr_en[0] = 1;
        d[8*64-1:7*64] = 42;
        #10 wr_en = 0;
        #100 rd_en[0] = 1;
        #10 rd_en = 0;

    end
    initial #10000 $finish;
    integer i;
    always @(posedge clk) begin
        for(i = 0; i < 8; i = i + 1)
            if(valid[i])
                $display("WOOT: %d", q[8*64-1:7*64]);
    end
endmodule
