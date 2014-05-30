/**
 * Copyright 2014 Kevin Townsend
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
`timescale 1ns/1ps
module std_fifo_tb;

reg rst, clk;
reg push, pop;
reg [7:0] d;
wire [7:0] q;
wire full, empty;
wire [3:0] count;
wire almost_empty;
wire almost_full;

std_fifo dut(
    rst,
    clk,
    push,
    pop,
    d,
    q,
    full,
    empty,
    count,
    almost_empty,
    almost_full);
integer i;

initial begin
    $display("starting testbench");
    rst = 1;
    push = 0; pop = 0;
    d = 0;

    #101 rst = 0;
    $display("time: %d", $time);
    #10 if(empty != 1) begin
        $display("test1:failed");
    end else begin
        $display("test1:passed");
    end
    #10 push <=1;
    d <= 1;
    if(empty == 0)
        $display("test2:failed");
    if(full == 1)
        $display("test2:failed full high");
    for(i = 2; i < 64; i = i + 1) begin
        #10 push <=1;
        d <= i;
        if(empty == 1) begin
            $display("test3:failed empty high, round %d", i);
        end
        if(full == 1)
            $display("test3:failed full high");
    end
    #10 push <= 1;
    d <= 64;
    if(empty == 1)
        $display("error");
    if(full == 1)
        $display("error");
    #10 if(full == 1)
        $display("test4:passed");
    else
        $display("test4:error");
    push <= 0;
    pop <= 1;
    for(i = 1; i < 65; i = i + 1) begin
        #10 if(q != i) begin
            $display("ERROR:");
        end

    end
    pop <= 0;
    #10 
    if(empty != 1)
        $display("ERROR:");
    else
        $display("test5:passed");
    if(full != 0)
        $display("ERROR:");
    #100 $finish;

    //TODO: check empty
end

initial begin
    clk = 1;
    forever #5 clk=~clk;
end
initial
     $monitor("At time %t, value ", $time);
endmodule
