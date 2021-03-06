module basic_switch_ff(clk, left_in, right_in, left_out, right_out, select);
    parameter WIDTH = 64;
    input clk;
    input [WIDTH-1:0] left_in, right_in;
    (* KEEP = "TRUE" *) output reg [WIDTH-1:0] left_out, right_out;
    input select;

    (* KEEP = "TRUE" *) reg [WIDTH-1:0] left_in_r, right_in_r;
    reg select_r;
    always @(posedge clk) begin
        select_r <= select;
        right_in_r <= right_in;
        left_in_r <= left_in;
        left_out <= select_r ? right_in_r : left_in_r;
        right_out <= select_r ? left_in_r : right_in_r;
    end
endmodule
