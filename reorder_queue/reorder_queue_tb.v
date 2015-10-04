module reorder_queue_tb;
    reg rst, clk;
    reg increment;
    wire [5:0] index_tag;
    wire full;
    reg wr_en;
    reg [7:0] d;
    wire [7:0] q;
    wire valid;
    reg stall;
    
    reorder_queue dut(rst, clk, increment, index_tag, full, wr_en, d, q, valid, stall);
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        increment = 0;
        wr_en = 0;
        d = 0;
        stall = 0;
        #50 rst = 0;
        #1001 while(!full) begin
            increment = 1;
            #10;
        end
        wr_en = 1;
        d = 0;
        #10 wr_en = 0;
        #10 wr_en = 1;
        d = 2;
        #10 wr_en = 1;
        d = 1;
        #10 wr_en = 0;

        increment = 0;
        #100 $finish;
    end

    always @(posedge clk) begin
        if(valid)
            $display("output: q:%d time:%d", q, $time);
    end

    initial #10000 $finish;

endmodule
