module multistage_interconnect_network(clk, push, d_in, valid, d_out, control);
    parameter WIDTH = 64;
    parameter IN_PORTS = 16;
    parameter PIPELINE_STAGES = 5;
    parameter OUT_PORTS = IN_PORTS;
    parameter ADDR_WIDTH_PORTS = log2(OUT_PORTS-1); //TODO: max
    input clk;
    input [0:IN_PORTS-1] push;
    input [IN_PORTS*WIDTH-1:0] d_in;
    output [0:OUT_PORTS-1] valid;
    output [OUT_PORTS*WIDTH-1:0] d_out;
    input [ADDR_WIDTH_PORTS-1:0] control;
    `include "log2.vh"
    integer i, j;
    genvar g, g2;
    reg [WIDTH:0] input_stage[0:IN_PORTS-1];
    wire [WIDTH:0] stage [0:ADDR_WIDTH_PORTS-1][0:IN_PORTS-1];
    always @*
        for(i = 0; i < IN_PORTS; i = i + 1) begin
            input_stage[i][0] = push[i];
            input_stage[i][WIDTH -:WIDTH] = d_in[(WIDTH)*(IN_PORTS-i)-1 -: WIDTH];
        end
    
    generate for(g = 0; g < IN_PORTS/2; g = g + 1) begin: generate_start
        basic_switch #(WIDTH+1) sw(input_stage[g*2], input_stage[g*2+1], stage[0][g*2], stage[0][g*2+1], control[ADDR_WIDTH_PORTS-1]);
        //basic_switch #(WIDTH+1) sw(input_stage[g*2], input_stage[g*2+1], stage[0][g*2], stage[0][g*2+1], control[ADDR_WIDTH_PORTS-1]);
    end
        for(g = 1; g < ADDR_WIDTH_PORTS; g = g + 1) begin: generate_stage
            for(g2 = 0; g2 < IN_PORTS/2; g2 = g2 + 1) begin: generate_switch
                basic_switch #(WIDTH+1) sw(stage[g-1][g2*2], stage[g-1][(g2^(1<<(ADDR_WIDTH_PORTS-2)))*2+1], stage[g][g2*2], stage[g][g2*2+1], control[ADDR_WIDTH_PORTS-g-1]);
            end
        end
    endgenerate
    reg [WIDTH:0] output_pipeline [0:PIPELINE_STAGES-1][0:OUT_PORTS-1];


    always @(posedge clk)begin
        for(i = 0; i < OUT_PORTS; i = i + 1)
            output_pipeline[0][i] <= stage[ADDR_WIDTH_PORTS-1][i];
        for(i = 1; i < PIPELINE_STAGES; i = i + 1) begin
            for(j = 0; j < OUT_PORTS; j = j + 1) begin
                output_pipeline[i][j] <= output_pipeline[i-1][j];
            end
        end
    end

    generate for(g=0; g < OUT_PORTS; g = g + 1) begin: generate_output
        assign valid[g] = output_pipeline[PIPELINE_STAGES-1][g][0];
        assign d_out[WIDTH*(OUT_PORTS-g)-1 -:WIDTH] = output_pipeline[PIPELINE_STAGES-1][g][WIDTH -: WIDTH];
    end
    endgenerate
    
    //DEBUG
    always @(posedge clk) begin
        if(push)
            for(i = 0; i < ADDR_WIDTH_PORTS; i = i + 1)
                for(j = 0; j < OUT_PORTS; j = j + 1)
                    $display("stages: %d, %d, %b", i, j, stage[i][j]);
    end
endmodule
