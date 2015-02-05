module multistage_interconnect_network_tb;
    reg clk;
    reg [0:15] push;
    reg [16*64-1:0] d_in;
    wire [0:15] valid;
    wire [16*64-1:0] d_out;
    reg [3:0] control;
    multistage_interconnect_network dut(clk, push, d_in, valid, d_out, control);

    integer i;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        push = 0;
        d_in = 0;
        control = 0;
        #101 push = {16{1'b1}};
        for(i = 0; i < 16; i = i + 1)
            d_in[64*(16-i)-1 -: 64] = i;
        #10 push = 0;
        #1000 $finish;
    end

    always @(posedge clk) begin
        for(i = 0; i < 16; i = i + 1)
            if(valid[i])
                $display("Port %d, value: %d, time: %d", i, d_out[(16-i)*64-1 -: 64], $time);
    end
endmodule
