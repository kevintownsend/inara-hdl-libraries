module scratch_pad(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    parameter PORTS = 8;
    parameter WIDTH = 64;
    parameter FRAGMENT_DEPTH = 512;
    parameter REORDER_DEPTH = 32;
    parameter FIFO_DEPTH = REORDER_DEPTH;
    parameter REORDER_BITS = log2(REORDER_DEPTH-1) + 1;
    parameter DEPTH = FRAGMENT_DEPTH * PORTS;
    parameter ADDR_WIDTH = log2(DEPTH-1);
    parameter PORTS_ADDR_WIDTH = log2(PORTS-1);
    input rst;
    input clk;
    input [0:PORTS-1] rd_en;
    input [0:PORTS-1] wr_en;
    input [WIDTH*PORTS-1:0] d;
    output reg [WIDTH*PORTS-1:0] q;
    input [ADDR_WIDTH*PORTS-1:0] addr;
    output [0:PORTS-1] full;
    input [0:PORTS-1]stall;
    output [0:PORTS-1]valid;
    `include "log2.vh"
    `include "constants.vh"
    integer i, j;
    //TODO: debug internal stalling issue

    //TODO: stall logic
    reg [0:PORTS-1] r_full;
    wire [0:PORTS-1] reorder_full, send_cross_bar_full, recv_cross_bar_full;
    wire [0:PORTS-1] send_cross_bar_almost_full, recv_cross_bar_almost_full;
//    always @(posedge clk) begin
//        r_full <= reorder_full | send_cross_bar_almost_full;
//    end
    always @* begin
        r_full = reorder_full | send_cross_bar_almost_full;
    end
    assign full = r_full;
    always @(posedge clk) begin
        for(i=0;i<PORTS;i=i+1) begin
            if(send_cross_bar_full[i]) begin
                $display("WARNING: %d:%m send cross bar full port %d", $time, i);
                //$finish;
            end
        end
        /*
        for(i=0;i<PORTS;i=i+1) begin
            if(send_cross_bar_almost_full[i]) begin
                $display("WARNING: %d:%m send cross bar almost full port %d", $time, i);
                $display("full signal: %b", full);
                //$finish;
            end
        end
        for(i=0;i<PORTS;i=i+1) begin
            if(reorder_full[i] && $time > 3000) begin
                $display("WARNING: %d:%m reorder full port %d", $time, i);
                $finish;
            end
        end
        */
    end
    //input
    reg [WIDTH+ADDR_WIDTH-1:0] send_input_stage_data [0:PORTS-1];
    always @*
        for(i = 0; i < PORTS; i = i + 1) begin
            for(j = 0; j < ADDR_WIDTH; j = j + 1)
                send_input_stage_data[i][j] = addr[(PORTS-i-1)*(ADDR_WIDTH)+j];
            for(j = 0; j < WIDTH; j = j + 1)
                send_input_stage_data[i][j+ADDR_WIDTH] = d[(PORTS-i-1)*(WIDTH)+j];
        end
    //output 
    wire [WIDTH+REORDER_BITS-1:0] recv_reorder_stage_data [0:PORTS-1];
    always @*
        for(i = 0; i < PORTS; i = i + 1)
            for(j = 0; j < WIDTH; j = j + 1)
                q[(PORTS-i-1)*WIDTH+j] = recv_reorder_stage_data[i][j+REORDER_BITS];

    //reorder
    genvar g;
    reg [2+ADDR_WIDTH+WIDTH-1:0] send_reorder_stage_data[0:PORTS-1];
    reg [0:PORTS-1] send_reorder_stage_data_valid;
    reg [PORTS*(ADDR_WIDTH+WIDTH+1)-1:0] send_reorder_stage_data_1d;
    always @*
        for(i = 0; i < PORTS; i = i + 1)begin
            send_reorder_stage_data_valid[i] = send_reorder_stage_data[i][0];
            for(j = 0; j < (2+ADDR_WIDTH+WIDTH-1); j = j + 1)
                send_reorder_stage_data_1d[(1+ADDR_WIDTH+WIDTH)*(PORTS-i-1) + j] = send_reorder_stage_data[i][j+1];
        end
    reg [WIDTH+REORDER_BITS+PORTS_ADDR_WIDTH+1-1:0]recv_cross_bar_stage_data[0:PORTS-1];
    wire [REORDER_BITS-1:0] index_tag [0:PORTS-1];
    generate for(g = 0; g < PORTS; g = g + 1) begin: generate_reorder
        reorder_queue #(WIDTH+REORDER_BITS, REORDER_DEPTH) rq(rst, clk, rd_en[g], index_tag[g], reorder_full[g], recv_cross_bar_stage_data[g][0], recv_cross_bar_stage_data[g][WIDTH+REORDER_BITS+PORTS_ADDR_WIDTH+1-1:1+PORTS_ADDR_WIDTH], recv_reorder_stage_data[g], valid[g], stall[g]);
    end
    endgenerate
    always @(posedge clk)begin
        for(i = 0; i < PORTS; i = i + 1)begin
            send_reorder_stage_data[i][0] <= rd_en[i] || wr_en[i];
            send_reorder_stage_data[i][1] <= wr_en[i];
            send_reorder_stage_data[i][ADDR_WIDTH+WIDTH+1:2] <= send_input_stage_data[i];
            if(rd_en[i])
                send_reorder_stage_data[i][2+REORDER_BITS+ADDR_WIDTH+PORTS_ADDR_WIDTH-1:ADDR_WIDTH+2] <= {index_tag[i], i[PORTS_ADDR_WIDTH-1:0]};
        end
    end

    //cross_bar send to memory
    reg [2+ADDR_WIDTH+WIDTH-1:0] send_cross_bar_stage_data[0:PORTS-1];
    wire [PORTS*(1+ADDR_WIDTH+WIDTH)-1:0] send_cross_bar_stage_data_1d;
    wire [0:PORTS-1] send_cross_bar_stage_data_valid;
    always @*
        for(i = 0; i < PORTS; i = i + 1) begin
            send_cross_bar_stage_data[i][0] = send_cross_bar_stage_data_valid[i];
            for(j = 0; j < (2+ADDR_WIDTH+WIDTH-1); j = j + 1)
                send_cross_bar_stage_data[i][j+1] = send_cross_bar_stage_data_1d[(1+ADDR_WIDTH+WIDTH)*(PORTS-i-1)+j];
        end
    //TODO: overflow possibility
    //TODO: memory stalls
    wire [PORTS-1:0]stall_tmp;
    assign stall_tmp = 0;
    cross_bar #(1+ADDR_WIDTH+WIDTH, PORTS, PORTS, FIFO_DEPTH, PORTS_ADDR_WIDTH, PORTS_ADDR_WIDTH, 1, 2)send_cross_bar(rst, clk, send_reorder_stage_data_valid, send_reorder_stage_data_1d, send_cross_bar_full, send_cross_bar_stage_data_valid, send_cross_bar_stage_data_1d, recv_cross_bar_almost_full, send_cross_bar_almost_full);

    always @(posedge clk) begin
        if(|send_reorder_stage_data_valid) begin
            //$display("send_crossbar: %H %H %H %H", send_reorder_stage_data_valid, send_reorder_stage_data_1d, send_cross_bar_stage_data_valid, send_cross_bar_stage_data_1d);
        end
        for(i = 0; i < PORTS; i = i + 1) begin
            if(send_reorder_stage_data_valid[i]) begin
                //send_reoder_stage_data_1d[(1+ADDR_WIDTH
            end
        end
    end
    //cross_bar recv from memory
    wire [1+REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH-1:0] recv_memory_stage_data[0:PORTS-1];
    reg [0:PORTS-1]recv_memory_stage_data_valid;
    reg [(REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH)*PORTS-1:0] recv_memory_stage_data_1d;
    wire [0:PORTS-1]recv_cross_bar_stage_data_valid;
    wire [(REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH)*PORTS-1:0] recv_cross_bar_stage_data_1d;
    always @*
        for(i = 0; i < PORTS; i = i + 1) begin
            recv_memory_stage_data_valid[i] = recv_memory_stage_data[i][0];
            for(j = 0; j < (REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH); j = j + 1)
                recv_memory_stage_data_1d[(REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH)*(PORTS-i-1)+j] = recv_memory_stage_data[i][j+1];
        end

    always @*
        for(i = 0; i < PORTS; i = i + 1) begin
            recv_cross_bar_stage_data[i] = 0;
            recv_cross_bar_stage_data[i][0] = recv_cross_bar_stage_data_valid[i];
            for(j = 0; j < (WIDTH+REORDER_BITS+PORTS_ADDR_WIDTH); j = j + 1)
                recv_cross_bar_stage_data[i][j+1] = recv_cross_bar_stage_data_1d[(REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH)*(PORTS-i-1) + j];
        end
    cross_bar #(REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH, PORTS, PORTS, FIFO_DEPTH, PORTS_ADDR_WIDTH, PORTS_ADDR_WIDTH, 0, 4)recv_cross_bar(rst, clk, recv_memory_stage_data_valid, recv_memory_stage_data_1d, recv_cross_bar_full, recv_cross_bar_stage_data_valid, recv_cross_bar_stage_data_1d, stall_tmp, recv_cross_bar_almost_full);

    always @(posedge clk) begin
        //$display("revicrossbar: %H %H %H %H", recv_memory_stage_data_valid, recv_memory_stage_data_1d, recv_cross_bar_stage_data_valid, recv_cross_bar_stage_data_1d);
    end

    //memory 
    generate for(g=0; g < PORTS; g = g + 1) begin: generate_memory_fragment
        simple_ram #(WIDTH, ADDR_WIDTH- PORTS_ADDR_WIDTH) scratch_memory_fragment(clk, &send_cross_bar_stage_data[g][1:0], send_cross_bar_stage_data[g][2+ADDR_WIDTH+WIDTH-1:ADDR_WIDTH+2], send_cross_bar_stage_data[g][2+ADDR_WIDTH-1:2+PORTS_ADDR_WIDTH], recv_memory_stage_data[g][REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH:REORDER_BITS+PORTS_ADDR_WIDTH+1]);
    end
    endgenerate
    //TODO: heavy debugging

    reg [REORDER_BITS+1+PORTS_ADDR_WIDTH-1:0]recv_memory_stage_data_register [0:PORTS-1];
    always @(posedge clk) begin
        for(i = 0; i < PORTS; i = i + 1) begin
            recv_memory_stage_data_register[i] <= {send_cross_bar_stage_data[i][PORTS_ADDR_WIDTH+REORDER_BITS+2+ADDR_WIDTH-1:ADDR_WIDTH+2], send_cross_bar_stage_data_valid[i] && !send_cross_bar_stage_data[i][1]};
        end
    end
    generate for(g=0; g < PORTS; g = g + 1) begin: generate_recv_memory_stage_data
        assign recv_memory_stage_data[g][REORDER_BITS+PORTS_ADDR_WIDTH:0] = recv_memory_stage_data_register[g];
    end
    endgenerate

    //DEBUG
    /*
    always @(posedge clk) begin
        //input
        for(i=0;i<PORTS;i=i+1) begin
            if(rd_en[i]||wr_en[i]) begin
                $display("%d:%m send input stage, port %d, read %H, write %H, addr %d, data %d", $time, i, rd_en[i], wr_en[i], send_input_stage_data[i][ADDR_WIDTH-1:0], send_input_stage_data[i][ADDR_WIDTH+WIDTH-1 -:WIDTH]);
            end
        end
        //TODO: reorder
        for(i=0;i<PORTS;i=i+1) begin
            if(send_reorder_stage_data[i][0]) begin
                $display("%d:%m send reorder stage, port %d, read %H, write %H, addr %d, data %d", $time, i, ~send_reorder_stage_data[i][1], send_reorder_stage_data[i][1], send_reorder_stage_data[i][2+ADDR_WIDTH-1 -:ADDR_WIDTH], send_reorder_stage_data[i][2+ADDR_WIDTH+WIDTH-1 -:WIDTH]);
            end
        end
        //TODO: crossbar
        for(i=0;i<PORTS;i=i+1) begin
            if(send_cross_bar_stage_data_valid[i]) begin
                $display("%d:%m send crossbar stage, port %d, read %H, write %H, addr %d, data %d", $time, i, ~send_cross_bar_stage_data[i][1], send_cross_bar_stage_data[i][1], send_cross_bar_stage_data[i][2+ADDR_WIDTH-1 -:ADDR_WIDTH], send_cross_bar_stage_data[i][2+ADDR_WIDTH+WIDTH-1 -:WIDTH]);
            end
        end
        //TODO: ram
        for(i=0;i<PORTS;i=i+1) begin
            if(recv_memory_stage_data_valid[i]) begin
                $display("%d:%m recv memory stage, port %d, return port %H, reorder %H, data %d", $time, i, recv_memory_stage_data[i][PORTS_ADDR_WIDTH:1], recv_memory_stage_data[i][REORDER_BITS+PORTS_ADDR_WIDTH -:REORDER_BITS], recv_memory_stage_data[i][WIDTH+REORDER_BITS+PORTS_ADDR_WIDTH -:WIDTH]);
            end
        end
        //TODO: crossbar
        for(i=0;i<PORTS;i=i+1) begin
            if(recv_cross_bar_stage_data_valid[i]) begin
                $display("%d:%m recv crossbar stage, port %d, %d, reorder %H, data %d", $time, i, recv_cross_bar_stage_data[i][PORTS_ADDR_WIDTH:1], recv_cross_bar_stage_data[i][REORDER_BITS+PORTS_ADDR_WIDTH -:REORDER_BITS], recv_cross_bar_stage_data[i][WIDTH+REORDER_BITS+PORTS_ADDR_WIDTH -:WIDTH]);
            end
        end
        //TODO: reorder
        for(i=0;i<PORTS;i=i+1) begin
            if(valid[i])begin
                $display("%d:%m recv reorder stage, port %d, reorder %d, data %d", $time, i, recv_reorder_stage_data[i][REORDER_BITS-1:0], recv_reorder_stage_data[i][WIDTH+REORDER_BITS-1 -:WIDTH] );
            end
        end
        //TODO: output
    end
    always @(posedge clk) begin
        if(`DEBUG) begin
            for(i = 0; i < PORTS; i = i + 1) begin
                if(|send_cross_bar_stage_data[i][1:0]) begin
                    $display("ram info: i: %H write: %H data: %H addr: %H data_out: %H", i, &send_cross_bar_stage_data[i][1:0], send_cross_bar_stage_data[i][2+ADDR_WIDTH+WIDTH-1:ADDR_WIDTH+2], send_cross_bar_stage_data[i][2+ADDR_WIDTH-1:2+PORTS_ADDR_WIDTH], recv_memory_stage_data[i][REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH:REORDER_BITS+PORTS_ADDR_WIDTH+1]);
                end
            end
        end
    end
    always @(posedge clk) begin
        if(`DEBUG) begin
            //$display("input stage data: %b %b %b", send_reorder_stage_data[0], wr_en[0], rd_en[0]);
            for(i = 0; i < PORTS; i = i + 1) begin
                if(rd_en[i]) begin
                    $display("reading enabled: %H", index_tag[i]);
                end
            end
            for(i = 0; i < PORTS; i = i + 1) begin
                //$display("send_cross_bar_stage_data_valid[%d]: %d", i, send_cross_bar_stage_data_valid[i]);
                if(|send_cross_bar_stage_data[i][1:0]) begin
                    $display("send crossbar stage data: %H %H %H", send_cross_bar_stage_data[i][1:0], send_cross_bar_stage_data[i][ADDR_WIDTH+1:2], send_cross_bar_stage_data[i][WIDTH+ADDR_WIDTH+1:ADDR_WIDTH+2]);
                    $display("DEBUG: %H, %H", send_cross_bar_stage_data_valid, send_cross_bar_stage_data_1d);
                end
            end
            if(|send_reorder_stage_data[0][1:0]) begin
                $display("input stage data: %H %H %H", send_reorder_stage_data[0][1:0], send_reorder_stage_data[0][ADDR_WIDTH+1:2], send_reorder_stage_data[0][WIDTH+ADDR_WIDTH+1:ADDR_WIDTH+2]);
                $display("DEBUG: %H, %H", send_reorder_stage_data_valid, send_reorder_stage_data_1d);
            end
            if(|send_cross_bar_stage_data_valid) begin
                $display("cross_bar valid data");
            end
            if(|send_reorder_stage_data_valid) begin
                $display("reorder valid data");
            end
            //$display("DEBUG: %H", send_cross_bar_stage_data_valid);
            for(i = 0; i < PORTS; i = i + 1) begin
                if(recv_memory_stage_data_valid[i]) begin
                    $display("Read data coming back: ");
                end
            end
            for(i = 0; i < PORTS; i = i + 1) begin
                if(recv_cross_bar_stage_data_valid[i]) begin
                    $display("cross bar data coming back: ");
                end
            end
            for(i = 0; i < PORTS; i = i + 1) begin
                if(recv_cross_bar_stage_data[i][0]) begin
                    $display("reorder value recieved from cross_bar: %H, %H", recv_cross_bar_stage_data[i][REORDER_BITS:1], recv_cross_bar_stage_data[i][WIDTH+REORDER_BITS:REORDER_BITS+1]);
                end
            end
            for(i = 0; i < PORTS; i = i + 1) begin
                if(valid[i]) begin
                    $display("valid data: %H, %H", i, recv_reorder_stage_data[i]);
                end
            end
            for(i = 0; i < PORTS; i = i + 1) begin
                if(recv_memory_stage_data[i][0])
                    $display("memory read port: %H, value: %H", i, recv_memory_stage_data[i][REORDER_BITS+WIDTH+PORTS_ADDR_WIDTH -: WIDTH]);
            end
            //$display("send_reorder_stage_data: %H", send_reorder_stage_data[0][1:0]);
        end
    end
    always @(posedge clk) begin
        for(i=0;i<PORTS;i=i+1) begin
            if(rd_en[i])
                $display("%m: Request from port %d for address %H", i, send_input_stage_data[i][ADDR_WIDTH-1:0]);
            if(wr_en[i])
                $display("%m: Push from port %d for address %H", i, send_input_stage_data[i][ADDR_WIDTH-1:0]);
        end
    end
    */
endmodule
