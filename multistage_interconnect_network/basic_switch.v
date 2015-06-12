module basic_switch(left_in, right_in, left_out, right_out, select);
    parameter WIDTH = 64;
    input [WIDTH-1:0] left_in, right_in;
    output [WIDTH-1:0] left_out, right_out;
    input select;

    assign left_out = select ? right_in : left_in;
    assign right_out = select ? left_in : right_in;
endmodule
