module multistage_interconnect_network_synthesis(clk, in, out, sel);
    input clk, in, sel;
    output reg out;
    wire [0:7] push;
    wire [16*64-1:0] d_in;
    wire [0:7] valid; 
    wire [64*16-1:0] d_out;
    wire [3:0] control;

    multistage_interconnect_network dut(clk, push, d_in, valid, d_out, control);

    reg [0:8+16*64+4-1] input_reg;
    reg [0:8+16*64-1] output_reg;
    assign push = input_reg[0:7];
    assign d_in = input_reg[8:8+16*64-1];
    assign control = input_reg[8+16*64:16*64+8+4-1];
    always @(posedge clk) begin
        input_reg[0] <= in;
        input_reg[1:8+16*64+4-1] <= input_reg[0:8+16*64+4-2];
        if(sel) begin
            out <= output_reg[8+16*64-1];
            output_reg[1:8+16*64-1] <= output_reg[0:8+16*64-2];
        end else begin
            output_reg[0:7] <= valid;
            output_reg[8:8+16*64-1] <= d_out;
        end
        
    end
    //TODO: wrapper

endmodule
