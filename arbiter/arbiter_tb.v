module arbiter_tb;

    reg rst, clk;
    reg [0:7] push;
    reg [63:0] d;
    wire [0:7] full;
    wire [0:7] almost_full;
    wire [7:0] q;
    reg stall;
    wire valid;

    //TODO: fix
    arbiter dut(rst, clk, push, d, full, q, stall, valid, almost_full);
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    integer i;
    initial begin
        rst = 1;
        push = 0;
        d = 0;
        stall = 0;
        #101 rst = 0;
        #50
        for(i = 0; i < 8; i = i + 1) begin
            #10 push[0] = 1;
            d[63:56] = i;
        end
        #10 push[0] = 0;


        #100 $finish;
    end

    always @(posedge clk) begin
        if(valid)
            $display("valid: %d %d", q, $time);

    end

endmodule
