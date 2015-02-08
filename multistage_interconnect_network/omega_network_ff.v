module omega_network_ff(clk, push, d_in, valid, d_out, control);
    parameter WIDTH = 8;
    parameter IN_PORTS = 8;
    parameter OUT_PORTS = IN_PORTS;
    parameter ADDR_WIDTH_PORTS = log2(OUT_PORTS-1);

    input clk;
    input [0:IN_PORTS-1] push;
    input [IN_PORTS*WIDTH-1:0] d_in;
    output [0:OUT_PORTS-1] valid;
    output [OUT_PORTS*WIDTH-1:0] d_out;
    input [ADDR_WIDTH_PORTS-1:0] control;

    genvar g1, g2;

    wire [WIDTH:0] stage [0:ADDR_WIDTH_PORTS][0:IN_PORTS-1];

    generate
        for(g1 = 0; g1 < IN_PORTS; g1 = g1 + 1) begin: generate_start
            assign stage[0][g1][0] = push[g1];
            assign stage[0][g1][WIDTH:1] = d_in[(g1+1)*WIDTH-1 -:WIDTH];
        end
        for(g1 = 0; g1 < ADDR_WIDTH_PORTS; g1 = g1 + 1) begin: generate_stage
            for(g2 = 0; g2 < IN_PORTS/2; g2 = g2 + 1) begin: generate_switch
                basic_switch_ff #(WIDTH+1) sw(stage[g1][g2], stage[g1][g2+IN_PORTS/2], stage[g1+1][g2*2], stage[g1+1][g2*2+1], control[ADDR_WIDTH_PORTS-1-g1]);
            end
        end
        for(g1 = 0; g1 < IN_PORTS; g1 = g1 + 1) begin: generate_end
            assign valid[g1] = stage[ADDR_WIDTH_PORTS][g1][0];
            assign d_out[(g1+1)*WIDTH-1 -:WIDTH] = stage[ADDR_WIDTH_PORTS][g1][WIDTH:1];
        end
    endgenerate

    `include "log2.vh"
endmodule
