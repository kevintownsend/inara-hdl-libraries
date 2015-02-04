`timescale 1ns/1ps
//TODO: create gold model
module linked_fifo_tb;

    reg rst, clk;
    reg push;
    reg [2:0] push_fifo;
    reg pop;
    reg [2:0] pop_fifo;
    reg [7:0] d;
    wire [7:0] q;
    wire empty;
    wire full;
    wire [3*8-1:0] count;
    //TODO: add free

    linked_fifo dut(rst, clk, push, push_fifo, pop, pop_fifo, d, q, empty, full, count);

    integer timeout;
    integer i;
    task print_linked_info;
    begin
        $display("linked_ram:");
        for(i = 0; i < 16; i = i + 1)
            $display("%d : %d", i, dut.linked_ram[i]);
        $display("r_beg:");
        for(i = 0; i < 8; i = i + 1)
            $display("%d : %d", i, dut.r_beg[i]);
        $display("r_end:");
        for(i = 0; i < 8; i = i + 1)
            $display("%d : %d", i, dut.r_end[i]);
    end
    endtask
    initial begin
        clk <= 0;
        forever #5 clk=~clk;
    end
    initial begin
        rst <= 1;
        push <= 0;
        push_fifo <= 0;
        pop <= 0;
        pop_fifo <= 0;
        d <= 0;
        #101 rst <= 0;
        #1000 push <= 1;
        d <= 5;
        #10 push <= 0;
        #10 push <= 1;
        d <= 6;
        #10 push <= 0;
        #30 pop <= 1;
        #20 pop <= 0;
        #100 push <= 1;
        push_fifo <= 1;
        d <= 1;
        #10 push <= 0;
        timeout = 0;
        #10 push <= 1;
        //TODO: display everything
        #10 push <= 0;
        $display("conituous push");
        while(!full && timeout != 64) begin
            push <= 1;
            #10;
            timeout = timeout+1;
        end
        $display("conituous push end");
        push <= 0;
        push_fifo <= 1;
        d <= 1;
        #10 push <= 0;
        timeout = 0;
        $display("conituous push");
        while(!full && timeout != 8) begin
            push <= 1;
            #10;
            timeout = timeout+1;
        end
        $display("conituous push end");
        timeout = 0;
        while(timeout != 8*64) begin
            pop_fifo = pop_fifo + 1;
            #1;
            if(!empty)
                pop = 1;
            else
                pop = 0;
            #9 timeout = timeout + 1;
        end
        timeout = 0;
        while(timeout != 1000*1000) begin
            pop_fifo = $random;
            push_fifo = $random;
            d = $random;
            #1 if(!full)
                push = $random;
            else
                push = 0;
            if(!empty)
                pop = $random;
            else
                pop = 0;
            #9 timeout = timeout + 1;
        end
        #100 $display($random);
        $finish;
    end

    reg [6:0] linked_ram_delay [0:2**6 - 1];
    reg [3:0] r_beg_delay [0:7];
    reg [3:0] r_end_delay [0:7];
    reg pop_delay;
    reg push_delay;
    reg full_delay;
    reg empty_delay;
    always @(posedge clk) begin
        pop_delay <= pop;
        push_delay <= push;
        full_delay <= full;
        empty_delay <= empty;
        for(i = 0; i < 2**6; i = i + 1)
            linked_ram_delay[i] = dut.linked_ram[i];
        for(i = 0; i < 8; i = i + 1)
            r_beg_delay[i] = dut.r_beg[i];
        for(i = 0; i < 8; i = i + 1)
            r_end_delay[i] = dut.r_end[i];
    end
    always @(posedge clk) begin
        if(dut.error == 1) begin
            $display("ERROR:");
            $display("delayed:");
            $display("pop_delay: %H", pop_delay);
            $display("push_delay: %H", push_delay);
            $display("full_delay: %H", full_delay);
            $display("empty_delay: %H", empty_delay);
            $display("current:");
            print_linked_info();
            
            $finish;
        end
    end
endmodule
