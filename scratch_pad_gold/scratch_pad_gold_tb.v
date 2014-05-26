module scratch_pad_gold_tb;
    `include "log2.vh"
    `define PORTS 16
    `define WIDTH 64
    `define DEPTH `PORTS*512
    `define ADDR_WIDTH log2(`DEPTH-1)
    reg rst, clk;
    reg [0:`PORTS-1] rd_en, wr_en;
    reg [`PORTS*`WIDTH-1:0] d;
    wire [`PORTS*`WIDTH-1:0] q;
    reg [`PORTS*`ADDR_WIDTH-1:0] addr;
    reg [0:`PORTS-1] stall;
    wire [0:`PORTS - 1] valid, full;
    

    scratch_pad_gold #(`PORTS, `WIDTH) dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    
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
        #100 wr_en[0] = 1;
        d[`PORTS*`WIDTH-1 -: `WIDTH] = 42;
        #10 wr_en = 0;
        #100 rd_en[0] = 1;
        #10 rd_en = 0;
        #100 $finish;

    end
    initial #10000 $finish;
    integer i;
    always @(posedge clk) begin
        for(i = 0; i < 8; i = i + 1)
            if(valid[i])
                $display("read output: %d", q[`PORTS*`WIDTH-1 -: `WIDTH ]);
        for(i = 0; i < 8; i = i + 1) begin
            if(rd_en[i] || wr_en[i])
                $display("using address: %d", addr[`PORTS*`ADDR_WIDTH-1 -: `ADDR_WIDTH ]);
            if(wr_en[i])
                $display("writing: %d", d[`PORTS*`WIDTH - 1 -: `WIDTH]);
        end
    end
    always @(posedge clk) begin
    end
endmodule
