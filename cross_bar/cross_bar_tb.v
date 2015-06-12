module cross_bar_tb;
    reg rst, clk;
    reg [0:7] wr_en;
    reg [63:0] d;
    wire [0:7] full;
    wire [0:7] valid;
    wire [63:0] q;
    reg [0:7] stall;
    wire [0:7] almost_full;
    cross_bar #(8, 8)dut(rst, clk, wr_en, d, full, valid, q, stall, almost_full);

    wire [7:0] internal_q [0:7];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    integer i, j, tmp;
    integer i2;


    initial begin
        rst = 1;
        wr_en = 0;
        d = 0;
        stall = 0;
        #31 rst = 0;
        #10 for(i = 0; i < 1; i = i + 1) begin
            wr_en = 0;
            d = d + 1;
            for(j = 0; j < 1; j = j + 1) begin
                if(!full[j])
                    wr_en[j] = 1;
            end
            #10 ;
        end
        wr_en = 0;
        d = 0;
        stall = 0;

        #200 $finish;
    end

    always @(posedge clk) begin
        for(i2 = 0; i2 < 8; i2 = i2 + 1) begin
            if(valid[i2])
                $display("valid: port:%d, time:%d, data:%b", i2, $time, q);
        end
    end
endmodule
