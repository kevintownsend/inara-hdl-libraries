module omega_network_ff_tb;
    parameter WIDTH = 8;
    parameter IN_PORTS = 8;
    parameter OUT_PORTS = IN_PORTS;
    parameter ADDR_WIDTH_PORTS = log2(OUT_PORTS-1);

    reg clk;
    reg [0:IN_PORTS-1] push;
    reg [IN_PORTS*WIDTH-1:0] d_in;
    wire [0:OUT_PORTS-1] valid;
    wire [OUT_PORTS*WIDTH-1:0] d_out;
    reg [ADDR_WIDTH_PORTS-1:0] control;

    omega_network_ff dut(clk, push, d_in, valid, d_out, control);

    initial begin
        clk = 0;
        forever #5 clk=~clk;
    end
    reg rst;
    integer i, j;
    integer si;
    reg [WIDTH-1:0] d_in_2d [0:IN_PORTS];
    reg [WIDTH-1:0] d_out_2d [0:IN_PORTS];
    always @* begin
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            d_in[(i+1)*WIDTH-1 -: WIDTH] = d_in_2d[i];
            d_out_2d[i] = d_out[(i+1)*WIDTH-1 -: WIDTH];
        end
    end
    reg count_rst;
    reg [ADDR_WIDTH_PORTS-1:0] count[0:2*ADDR_WIDTH_PORTS];
    initial begin
        push = 0;
        rst = 1;
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            d_in_2d[i] = i;
        end
        count_rst = 1;
        //TODO: wait correct amount of time
        #101 rst = 0;
        push = -1;
        #10 push = 0;
        #1000 count_rst = 0;
        #10 push = -1;
        for(si = 0; si < IN_PORTS; si = si + 1) begin
            $display("here");
            #10;
        end
        push = 0;
        #1000 $display("NO ERRORS");
        $finish;
    end
    always @(posedge clk) begin
        for(j = 0; j < ADDR_WIDTH_PORTS; j = j + 1) begin
            control[ADDR_WIDTH_PORTS-j-1] = count[j*2][j];
        end
    end
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0; i < IN_PORTS; i = i + 1) begin
                if(valid[i]) begin
                    $display("port: %d data: %d", i, d_out_2d[i]);
                end
            end
        end
    end


    always @(posedge clk) begin
        if(count_rst)
            count[0] <= 0;
         else
            count[0] <= count[0] + 1;
         for(i = 0; i < 2*ADDR_WIDTH_PORTS; i = i + 1)
            count[i+1] <= count[i];
    end

    `include "log2.vh"
endmodule
