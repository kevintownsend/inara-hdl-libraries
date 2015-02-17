module scratch_pad_tb;
    //TODO: clean up code, fewer display statements
    `include "log2.vh"
    `include "abs.vh"
    `include "constants.vh"
    `define PORTS 64
    //TODO: track down why WIDTH=8 does not work
    `define WIDTH 16
    `define FRAGMENT_DEPTH 512
    `define DEPTH `PORTS*`FRAGMENT_DEPTH
    `define ADDR_WIDTH log2(`DEPTH-1)
    `define ADDR_TEST_MAX `FRAGMENT_DEPTH * 2
    `define REORDER_DEPTH 32
    reg rst, clk;
    reg [0:`PORTS-1] rd_en, wr_en;
    reg [`PORTS*`WIDTH-1:0] d;
    wire [`PORTS*`WIDTH-1:0] q;
    reg [`PORTS*`ADDR_WIDTH-1:0] addr;
    reg [0:`PORTS-1] stall;
    wire [0:`PORTS - 1] valid, full;
    //TODO: ports and addresses not lining up
    
    scratch_pad #(`PORTS, `WIDTH, `FRAGMENT_DEPTH, `REORDER_DEPTH) dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    
    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    wire [`PORTS*`WIDTH-1:0] gold_q;
    wire [0:`PORTS -1] gold_valid;
    wire [0:`PORTS -1] gold_full;
    scratch_pad_gold #(`PORTS, `WIDTH) gold_model(rst, clk, rd_en, wr_en, d, gold_q, addr, stall, gold_valid, gold_full);
    integer begin_ptr [0:`PORTS];
    integer end_ptr [0:`PORTS];
    reg [`WIDTH-1:0] fifo_data [0:`PORTS][0:100000];
    integer i, j;
    initial begin
        for(i = 0; i < `PORTS; i = i + 1) begin
            begin_ptr[i] = 0;
            end_ptr[i] = 0;
        end
    end

    integer si;
    integer tmp;
    integer start_time;
    integer data_sent [0:`PORTS-1];
    integer data_to_send [0:`PORTS-1];
    integer max_data_sent;
    integer first_finish, all_finish;
    reg [`ADDR_WIDTH-1:0] addr_iterator;
    integer ignore_full;
    initial begin
        //$monitor(valid[0]);
        $display("beginning");
        ignore_full = 1;
        rst = 1;
        rd_en = 0;
        wr_en = 0;
        d = 0;
        addr = 0;
        stall = 0;
        #1001 rst = 0;
        #20000 wr_en[0] = 1;
        $display("first write");
        ignore_full = 0;
        d[`PORTS*`WIDTH-1 -: `WIDTH] = 42;
        #10 wr_en = 0;
        #100 rd_en[0] = 1;
        $display("first read");
        #10 rd_en = 0;
        #1000;
        $display("second write");
        wr_en[0] = 1;
        d[`PORTS*`WIDTH-1 -: `WIDTH] = 0;
        #10 wr_en = 0;
        #100;
        rd_en[0] = 1;
        $display("second read");
        #10 rd_en[0] = 0;
        #1000;
        //initial random data
        $display("writing initial data");
        for(addr_iterator = 0; addr_iterator < `ADDR_TEST_MAX; addr_iterator = addr_iterator + 1) begin
            wr_en[0] = 1;
            d[`PORTS * `WIDTH - 1 -: `WIDTH] = abs($random);
            addr[`PORTS * `ADDR_WIDTH - 1 -: `ADDR_WIDTH] = addr_iterator;

            #10;
        end
        wr_en[0] = 0;
        #1000;
        $display("reading initial data. time: %d", $time);
        for(si = 0; si < `ADDR_TEST_MAX; si = si + 1) begin
            rd_en[0] = 0;
            while(full[0]) begin
                #10;
            end
            rd_en[0] = 1;
            //d[`PORTS * `WIDTH - 1 -: `WIDTH] = si;
            addr[`PORTS * `ADDR_WIDTH - 1 -: `ADDR_WIDTH] = si;
            #10;
        end
        rd_en[0] = 0;
        #1000;
        /*
        //random data
        $display("randrom data");
        si = 0;
        for(si = 0; si < 10; si = si + 1) begin
            for(i = 0; i < `PORTS; i = i + 1) begin
                tmp = abs($random) % 3;
                if(tmp == 0) begin
                    wr_en[i] = 1;
                    rd_en[i] = 0;
                end else if(tmp == 1) begin
                    wr_en[i] = 0;
                    rd_en[i] = 1;
                end else if(tmp == 2) begin
                    wr_en = 0;
                    rd_en = 0;
                end
                d[(`PORTS-i)*`WIDTH - 1 -: `WIDTH] = abs($random);
                addr[(`PORTS-i)*`ADDR_WIDTH-1 -: `ADDR_WIDTH] = abs($random) % `ADDR_TEST_MAX;
            end
            #10;
        end
        #10 rd_en = 0;
        wr_en = 0;
        d = 0;
        addr = 0;
        stall = 0;
        #1000;
        */
        //stress test write at two ports.
        /*
        $display("stress testing writing at port 0 and 1");
        $display("start time: %d",$time);
        start_time=$time;
        for(si=0; si<1000; si=si+1) begin
            if(!full[0]) begin
                wr_en[0]=1;
                d[`PORTS*`WIDTH-1 -: `WIDTH]=42;
                addr[`PORTS*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=0;
            end else begin
                wr_en[0]=0;
            end
            if(!full[1]) begin
                wr_en[1]=1;
                d[(`PORTS-1)*`WIDTH-1 -: `WIDTH]=42;
                addr[(`PORTS-1)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=0;
            end else begin
                wr_en[1]=0;
            end
            #10;
        end
        wr_en=0;
        $display("end time: %d",$time);
        #1000;
        //stress test read at single port.
        $display("stress testing reading at port 0 and 1");
        $display("start time: %d",$time);
        start_time=$time;
        for(si=0; si<1000; si=si+1) begin
            if(!full[0]) begin
                rd_en[0]=1;
                d[`PORTS*`WIDTH-1 -: `WIDTH]=42;
                addr[`PORTS*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=0;
            end else begin
                rd_en[0]=0;
            end
            if(!full[1]) begin
                rd_en[1]=1;
                d[(`PORTS-1)*`WIDTH-1 -: `WIDTH]=42;
                addr[(`PORTS-1)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=0;
            end else begin
                rd_en[1]=0;
            end
            #10;
        end
        rd_en=0;
        $display("end time: %d",$time);
        //TODO: stress test all ports sequencial write
        #1000;
        $display("stress testing writing all ports");
        $display("start time: %d",$time);
        start_time=$time;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    wr_en[i]=1;
                    d[(`PORTS-i)*`WIDTH-1 -: `WIDTH]=42;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=data_sent[i];
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    wr_en[i]=0;
                end
            end
            #10;
        end
        wr_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end
        */
        //TODO: stress test all ports sequencial read
        #10000;
        $display("stress testing writing all ports");
        $display("start time: %d",$time);
        start_time=$time;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        $display("starting to send");
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    rd_en[i]=1;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=data_sent[i];
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    rd_en[i]=0;
                end
            end
            #10;
        end
        $display("stopped sending");
        rd_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end
        /*
        //TODO: stress test all ports random write
        #1000;
        $display("stress testing writing all ports");
        $display("start time: %d",$time);
        start_time=$time;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    wr_en[i]=1;
                    d[(`PORTS-i)*`WIDTH-1 -: `WIDTH]=42;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=data_sent[i];
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    wr_en[i]=0;
                end
            end
            #10;
        end
        wr_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end
        */
        //TODO: stress test all ports random read
        #10000;
        $display("stress testing writing all ports");
        $display("start time: %d",$time);
        start_time=$time;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        $display("starting to send");
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    rd_en[i]=1;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=abs($random) % `ADDR_TEST_MAX;
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    rd_en[i]=0;
                end
            end
            #10;
        end
        $display("stopped sending");
        rd_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end

        //TODO: stress test all ports random read
        #10000;
        $display("stress testing worst case reading, all ports");
        $display("start time: %d", $time);
        start_time=$time;
        j=0;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        max_data_sent = 0;
        $display("starting to send");
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    rd_en[i]=1;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=(j*`PORTS) % `ADDR_TEST_MAX;
                    j = j + 1;
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    rd_en[i]=0;
                end
                if(data_sent[i] > max_data_sent)
                    max_data_sent = data_sent[i];
            end
            #10;
            if(max_data_sent > 32) begin
                $display("trigger hit:");
            end
                //for(i=0;i<`PORTS;i=i+1)begin
                //    $display("data sent from port %d: %d", i, data_sent[i]);
                //end
                //TODO: assert only reads on port 0;
                //TODO: look at arbiters
                for(i=1;i<`PORTS;i=i+1)begin
                    //$display("debug: %b", dut.send_cross_bar_stage_data[i][1:0]);
                    if((dut.send_cross_bar_stage_data[i][0] != 0) && i != 0) begin
                        $display("valid on wrong port");
                        $finish;
                    end
                end
                if(dut.send_cross_bar_stage_data[0][0] == 1 && dut.send_cross_bar_stage_data[0][1] != 0) begin
                    $display("valid but not...");
                    $finish;
                end
        end
        $display("stopped sending");
        rd_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end

        //TODO: stress test all ports random read
        #10000;
        $display("stress testing reading all ports");
        $display("start time: %d",$time);
        start_time=$time;
        for(i=0;i<`PORTS;i=i+1)begin
            data_sent[i]=0;
            data_to_send[i]=1000;
        end
        $display("starting to send");
        for(si=0; si<1000; si=si+1) begin
            for(i=0;i<`PORTS;i=i+1)begin
                if(!full[i]) begin
                    rd_en[i]=1;
                    addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH]=i;
                    data_sent[i]=data_sent[i]+1;
                end else begin
                    rd_en[i]=0;
                end
            end
            #10;
        end
        $display("stopped sending");
        rd_en=0;
        $display("end time: %d",$time);
        $display("total time: %d", ($time-start_time));
        for(i=0;i<`PORTS;i=i+1)begin
            $display("data sent from port %d: %d", i, data_sent[i]);
        end

        //TODO: check state with sequential read.

        //TODO: stress test all ports random read write

        #10000 $display("No ERRORS");
        $finish;
    end

    initial begin
        #1000000 $display("ERROR: watchdog reached");
        $finish;
    end
    always @(posedge clk) begin
        if(`DEBUG) begin
            $display("debug on");
            for(i = 0; i < `PORTS; i = i + 1)
                if(valid[i])
                    $display("i:%d read output: %H", i, q[`PORTS*`WIDTH-1 -: `WIDTH ]);
            for(i = 0; i < `PORTS; i = i + 1) begin
                if(rd_en[i] || wr_en[i])
                    $display("i:%d using address: %H", i, addr[`PORTS*`ADDR_WIDTH-1 -: `ADDR_WIDTH ]);
                if(wr_en[i])
                    $display("i:%d writing: %H", i, d[`PORTS*`WIDTH - 1 -: `WIDTH]);
            end
        end
    end
    always @(posedge clk) begin
        for(i=0;i<`PORTS;i=i+1) begin
            if(full[i]&&!ignore_full)begin
                //$display("%d full at port %d",$time, i);
                //$finish;
            end
        end
        for(i = 0; i < `PORTS; i = i + 1) begin
            if(gold_valid[i]) begin
                //$display("gold valid: port: %d data: %H time: %d", i, gold_q[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
                fifo_data[i][begin_ptr[i]] = gold_q[(`PORTS-i)*`WIDTH - 1 -: `WIDTH];
                begin_ptr[i] = begin_ptr[i] + 1;
            end
        end
        /*
        for(i = 0; i< `PORTS; i=i+1)begin
            if(rd_en[i])begin
                $display("Read data: port: %d addr: %H data: %H time: %d", i, addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH], d[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
            end
            if(wr_en[i])begin
                $display("Write data: port: %d addr: %H data: %H time: %d", i, addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH], d[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
            end
        end
        */
        for(i = 0; i < `PORTS; i = i + 1) begin
            if(valid[i]) begin
                //$display("valid %d", i);
                if(fifo_data[i][end_ptr[i]] ==q[(`PORTS-i)*`WIDTH - 1 -: `WIDTH] ) begin
                    //$display("Woot match %d", i);
                    //$finish;
                end else begin
                    $display("ERROR: no match %d", i);
                    $display("%d: port %d, fifo %d, q %d", $time, i, fifo_data[i][end_ptr[i]], q[(`PORTS-i)*`WIDTH-1 -: `WIDTH]);
                    $display("end_ptr: %H", end_ptr[i]);
                    $display("beg_ptr: %H", begin_ptr[i]);
                    $finish;
                end
                end_ptr[i] = end_ptr[i] + 1;
            end
        end
    end
endmodule
