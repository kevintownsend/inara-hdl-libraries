module scratch_pad_tb;
    `include "log2.vh"
    `include "abs.vh"
    `include "constants.vh"
    `define PORTS 16
    `define WIDTH 64
    `define DEPTH `PORTS*512
    `define ADDR_WIDTH log2(`DEPTH-1)
    `define ADDR_TEST_MAX 16
    reg rst, clk;
    reg [0:`PORTS-1] rd_en, wr_en;
    reg [`PORTS*`WIDTH-1:0] d;
    wire [`PORTS*`WIDTH-1:0] q;
    reg [`PORTS*`ADDR_WIDTH-1:0] addr;
    reg [0:`PORTS-1] stall;
    wire [0:`PORTS - 1] valid, full;
    
    scratch_pad #(`PORTS, `WIDTH) dut(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    
    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    //TODO: gold scratchpad
    wire [`PORTS*`WIDTH-1:0] gold_q;
    wire [0:`PORTS -1] gold_valid;
    wire [0:`PORTS -1] gold_full;
    scratch_pad_gold #(`PORTS, `WIDTH) gold_model(rst, clk, rd_en, wr_en, d, gold_q, addr, stall, gold_valid, gold_full);
    //TODO: fifos
    integer begin_ptr [0:`PORTS];
    integer end_ptr [0:`PORTS];
    reg [`WIDTH-1:0] fifo_data [0:`PORTS][0:10000];
    integer i;
    initial begin
        for(i = 0; i < `PORTS; i = i + 1) begin
            begin_ptr[i] = 0;
            end_ptr[i] = 0;
        end
    end

    integer si;
    integer tmp;
    reg [`ADDR_WIDTH-1:0] addr_iterator;
    integer ignore_full;
    initial begin
        //$monitor(valid[0]);
        ignore_full = 1;
        rst = 1;
        rd_en = 0;
        wr_en = 0;
        d = 0;
        addr = 0;
        stall = 0;
        #1001 rst = 0;
        #1000 wr_en[0] = 1;
        ignore_full = 0;
        d[`PORTS*`WIDTH-1 -: `WIDTH] = 42;
        #10 wr_en = 0;
        #100 rd_en[0] = 1;
        #10 rd_en = 0;
        #1000;
        wr_en[0] = 1;
        d[`PORTS*`WIDTH-1 -: `WIDTH] = 0;
        #10 wr_en = 0;
        #100;
        rd_en[0] = 1;
        #10 rd_en[0] = 0;
        #1000;
        //initial random data
        $display("writing initial data");
        for(addr_iterator = 0; addr_iterator < `ADDR_TEST_MAX; addr_iterator = addr_iterator + 1) begin
            wr_en[0] = 1;
            d[`PORTS * `WIDTH - 1 -: `WIDTH] = addr_iterator;
            addr[`PORTS * `ADDR_WIDTH - 1 -: `ADDR_WIDTH] = addr_iterator;

            #10;
        end
        wr_en[0] = 0;
        #1000;
        $display("reading initial data. time: %d", $time);
        for(si = 0; si < `ADDR_TEST_MAX; si = si + 1) begin
            rd_en[0] = 1;
            //d[`PORTS * `WIDTH - 1 -: `WIDTH] = si;
            addr[`PORTS * `ADDR_WIDTH - 1 -: `ADDR_WIDTH] = si;
            #10;
        end
        rd_en[0] = 0;
        #1000;
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
        //stress test write at two ports.
        $display("stress testing writing at port 0 and 1");
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
        #1000;
        //stress test read at single port.
        $display("stress testing reading at port 0 and 1");
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

        #10000 $finish;
    end

    initial #100000 $finish;
    always @(posedge clk) begin
        if(`DEBUG) begin
            for(i = 0; i < 8; i = i + 1)
                if(valid[i])
                    $display("i:%d read output: %H", i, q[`PORTS*`WIDTH-1 -: `WIDTH ]);
            for(i = 0; i < 8; i = i + 1) begin
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
                $display("%d full at port %d",$time, i);
                //$finish;
            end
        end
        for(i = 0; i < `PORTS; i = i + 1) begin
            if(gold_valid[i]) begin
                $display("gold valid: port: %d data: %H time: %d", i, gold_q[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
                fifo_data[i][begin_ptr[i]] = gold_q[(`PORTS-i)*`WIDTH - 1 -: `WIDTH];
                begin_ptr[i] = begin_ptr[i] + 1;
            end
        end
        for(i = 0; i< `PORTS; i=i+1)begin
            if(rd_en[i])begin
                $display("Read data: port: %d addr: %H data: %H time: %d", i, addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH], d[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
            end
            if(wr_en[i])begin
                $display("Write data: port: %d addr: %H data: %H time: %d", i, addr[(`PORTS-i)*`ADDR_WIDTH-1 -:`ADDR_WIDTH], d[(`PORTS-i)*`WIDTH-1 -:`WIDTH], $time);
            end
        end
        for(i = 0; i < `PORTS; i = i + 1) begin
            if(valid[i]) begin
                $display("valid %d", i);
                if(fifo_data[i][end_ptr[i]] ==q[(`PORTS-i)*`WIDTH - 1 -: `WIDTH] ) begin
                    $display("Woot match %d", i);
                    //$finish;
                end else begin
                    $display("ERROR: no match %d", i);
                    $display("%d: port %d, fifo %d, q %d", $time, i, fifo_data[i][end_ptr[i]], q[(`PORTS-i)*`WIDTH-1 -: `WIDTH]);
                    $display("end_ptr: %H", end_ptr[i]);
                    $display("beg_ptr: %H", begin_ptr[i]);
                    $finish;
                end
                end_ptr[i] = end_ptr[i] + 1;
                //TODO: loop for 10000
            end
        end
    end
endmodule