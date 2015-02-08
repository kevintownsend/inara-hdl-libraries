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
        forever #5 clk~=clk;
    end
    reg rst;
    integer i;
    reg [WIDTH-1:0] d_in_2d [0:IN_PORTS];
    reg [WIDTH-1:0] d_out_2d [0:IN_PORTS];
    always @* begin
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            d_in[(i+1)*WIDTH-1 -: WIDTH] = d_in_2d[i];
            d_out_2d[i] = d_out[(i+1)*WIDTH-1 -: WIDTH];
        end
    end
    initial begin
        push = 0;
        rst = 1;
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            d_in_2d[i] = i;
        end
        control = 0;
        //TODO: wait correct amount of time
        #101 rst = 0;
        valid = -1;
        #10 valid = 0;
        #1000 $display("NO ERRORS BITCH");
        $finish;
    end
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0; i < IN_PORTS; i = i + 1) begin
                if(valid[i]) begin
                    if(d_out_2d[i] == i) begin
                        $display("woot match");
                    end else begin
                        $display("epic fail");
                    end
                end
            end
        end
        #10;
    end

endmodule
