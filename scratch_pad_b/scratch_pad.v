module scratch_pad(rst, clk, rd_en, wr_en, d, q, addr, stall, valid, full);
    parameter PORTS = 8;
    parameter WIDTH = 64;
    parameter FRAGMENT_DEPTH = 512;
    parameter REORDER_DEPTH = 32;
    parameter REORDER_BITS = log2(REORDER_DEPTH-1) + 1;
    parameter FIFO_DEPTH = REORDER_DEPTH;
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

    integer i, j;

    //TODO: stall logic
    reg [0:PORTS-1] r_full;
    wire [0:PORTS-1] reorder_full, send_buffer_full, recv_min_full;
    wire [0:PORTS-1] send_buffer_almost_full, recv_min_almost_full;

    wire [0:PORTS-1]linked_fifo_full;
    wire [0:PORTS-1]linked_fifo_almost_full;
    always @* begin
        r_full = reorder_full | linked_fifo_almost_full;
    end
    assign full = r_full;

    always @(posedge clk) begin
        /*
        for(i=0;i<PORTS;i=i+1) begin
            if(linked_fifo_full[i]) begin
                $display("WARNING: %d:%m send cross bar full port %d", $time, i);
                $display("full: %b", full);
                $display("rd_en: %b", rd_en);
                $display("wr_en: %b", wr_en);
                //$finish;
            end
        end
        for(i=0;i<PORTS;i=i+1) begin
            if(full[i] && (rd_en[i] || wr_en[i])) begin
                $display("ERROR: %d:%m OVERFLOW port %d", $time, i);
                $finish;
            end
        end
        for(i=0;i<PORTS;i=i+1) begin
            if(send_buffer_almost_full[i]) begin
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
    //{data, address, memory port}
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

    //TODO: reorder queue
    genvar g;
    //{data, address, memory port,
    reg [2+ADDR_WIDTH+WIDTH-1:0] send_reorder_stage_data[0:PORTS-1];
    reg [0:PORTS-1] send_reorder_stage_data_valid;
    reg [0:PORTS-1] send_reorder_stage_data_write;
    reg [PORTS_ADDR_WIDTH-1:0] send_reorder_stage_data_addr_low[0:PORTS-1];
    reg [ADDR_WIDTH-PORTS_ADDR_WIDTH-1:0] send_reorder_stage_data_addr_high[0:PORTS-1];
    reg [WIDTH-1:0] send_reorder_stage_data_data[0:PORTS-1];
    always @*
        for(i = 0; i < PORTS; i = i + 1)begin
            send_reorder_stage_data_valid[i] = send_reorder_stage_data[i][0];
            send_reorder_stage_data_write[i] = send_reorder_stage_data[i][1];
            send_reorder_stage_data_addr_low[i] = send_reorder_stage_data[i][PORTS_ADDR_WIDTH+1:2];
            send_reorder_stage_data_addr_high[i] = send_reorder_stage_data[i][ADDR_WIDTH+1:PORTS_ADDR_WIDTH+2];
            send_reorder_stage_data_data[i] = send_reorder_stage_data[i][WIDTH+ADDR_WIDTH+1: ADDR_WIDTH+2];
        end
    reg [WIDTH+REORDER_BITS-1:0]recv_min_stage_data[0:PORTS-1];
    wire [0:PORTS-1] recv_min_stage_valid;
    wire [REORDER_BITS-1:0] index_tag [0:PORTS-1];
    generate for(g = 0; g < PORTS; g = g + 1) begin: generate_reorder
        reorder_queue #(WIDTH+REORDER_BITS, REORDER_DEPTH) rq(rst, clk, rd_en[g], index_tag[g], reorder_full[g], recv_min_stage_valid[g], recv_min_stage_data[g], recv_reorder_stage_data[g], valid[g], stall[g]);
    end
    endgenerate
    /*
    always @(posedge clk) begin
        if(generate_reorder[0].rq.wr_en) begin
            $display("reorder end: %d", generate_reorder[0].rq.end_ptr);
            $display("reorder begin: %d", generate_reorder[0].rq.beg_ptr);
            $display("occupy_array: %b", generate_reorder[0].rq.occupency_array);
            $display("occupency_array_d: %b", generate_reorder[0].rq.occupency_array_d);
            $display("occupency_array_addr_a: %d", generate_reorder[0].rq.occupency_array_addr_a);
            $display("wr_en: %b", generate_reorder[0].rq.wr_en);
        end
    end
    */
    always @(posedge clk)begin
        for(i = 0; i < PORTS; i = i + 1)begin
            send_reorder_stage_data[i][0] <= rd_en[i] || wr_en[i];
            send_reorder_stage_data[i][1] <= wr_en[i];
            send_reorder_stage_data[i][ADDR_WIDTH+WIDTH+1:2] <= send_input_stage_data[i];
            if(rd_en[i])
                send_reorder_stage_data[i][2+REORDER_BITS+ADDR_WIDTH+PORTS_ADDR_WIDTH-1:ADDR_WIDTH+2] <= {index_tag[i], i[PORTS_ADDR_WIDTH-1:0]};
        end
    end

    //TODO: buffer
    wire [0:PORTS-1]linked_fifo_empty;
    assign send_buffer_almost_full = linked_fifo_full; //TODO: fix
    reg [0:PORTS-1]linked_fifo_pop[0:1];
    reg [PORTS_ADDR_WIDTH-1:0] request_routing [0:PORTS-1];
    wire [WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH:0] send_buffer_stage_data[0:PORTS-1];
    generate for(g = 0; g < PORTS; g = g + 1) begin: generate_buffer
        linked_list_fifo #(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1, FIFO_DEPTH, PORTS) lf(rst, clk, send_reorder_stage_data_valid[g], send_reorder_stage_data_addr_low[g], linked_fifo_pop[0][g], request_routing[g],{send_reorder_stage_data_data[g], send_reorder_stage_data_addr_high[g], send_reorder_stage_data_write[g]}, send_buffer_stage_data[g],linked_fifo_empty[g],linked_fifo_full[g],,linked_fifo_almost_full[g], );
    end
    endgenerate

    reg [PORTS_ADDR_WIDTH-1:0] rr_counter;
    reg [PORTS_ADDR_WIDTH-1:0] rr_counter_fat[0:PORTS - 1];
    reg [PORTS_ADDR_WIDTH-1:0] counter_pipeline[0:2*2*PORTS_ADDR_WIDTH];
    always @(posedge clk) begin
        if(rst) begin
            rr_counter <= 0;
        end else
            rr_counter <= rr_counter + 1;
        counter_pipeline[0] <= rr_counter;
        for(i = 0; i < 2*2*PORTS_ADDR_WIDTH; i = i + 1)
            counter_pipeline[i+1] <= counter_pipeline[i];
    end
    always @(posedge clk) begin
        for(i = 0; i < PORTS; i = i + 1) begin
            request_routing[i] <= i ^ rr_counter;
        end
    end
    always @*
        linked_fifo_pop[0] = ~linked_fifo_empty;
    always @(posedge clk)
        linked_fifo_pop[1] <= linked_fifo_pop[0];
    //TODO: request MIN
    reg [PORTS*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1)-1:0]send_buffer_stage_data_1d;
    always @* for(i = 0; i < PORTS; i = i + 1)
        send_buffer_stage_data_1d[(i+1)*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1) - 1 -: WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1] = send_buffer_stage_data[i];
    wire [PORTS*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1)-1:0]send_min_stage_data_1d;
    reg [0:PORTS-1] send_min_stage_write;
    reg [ADDR_WIDTH-PORTS_ADDR_WIDTH-1:0] send_min_stage_addr[0:PORTS-1];
    reg [WIDTH-1:0] send_min_stage_data[0:PORTS-1];
    wire [0:PORTS-1] request_min_valid;
    always @* for(i = 0; i < PORTS; i = i + 1) begin
        send_min_stage_write[i] = send_min_stage_data_1d[i*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1)];
        send_min_stage_addr[i] = send_min_stage_data_1d[i*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1)+ADDR_WIDTH-PORTS_ADDR_WIDTH -: ADDR_WIDTH-PORTS_ADDR_WIDTH];
        send_min_stage_data[i] = send_min_stage_data_1d[(i+1)*(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1)-1 -: WIDTH];
    end
    reg[PORTS_ADDR_WIDTH-1:0]request_min_control;
    always @* for(i = 0; i < PORTS_ADDR_WIDTH; i = i + 1)
        request_min_control[PORTS_ADDR_WIDTH-i-1] = counter_pipeline[1+2*i][PORTS_ADDR_WIDTH-i-1];
    omega_network_ff #(WIDTH+ADDR_WIDTH-PORTS_ADDR_WIDTH+1,PORTS)request_min(clk,linked_fifo_pop[1],send_buffer_stage_data_1d, request_min_valid, send_min_stage_data_1d, request_min_control);
    //TODO: RAMs
    wire [WIDTH-1:0] recv_memory_stage_data[0:PORTS-1];
    reg [0:PORTS-1]recv_memory_stage_valid;
    generate for(g = 0; g < PORTS; g = g + 1) begin: banks
        simple_ram #(WIDTH, FRAGMENT_DEPTH) bank(clk, send_min_stage_write[g] && request_min_valid[g], send_min_stage_data[g], send_min_stage_addr[g], recv_memory_stage_data[g]);
    end
    endgenerate
    always @(posedge clk)
        recv_memory_stage_valid <= request_min_valid & ~send_min_stage_write;
    reg [REORDER_BITS-1:0]recv_memory_stage_reorder[0:PORTS-1];
    always @(posedge clk) for(i = 0; i < PORTS; i = i + 1) begin
        recv_memory_stage_reorder[i] <= send_min_stage_data[i][REORDER_BITS+PORTS_ADDR_WIDTH-1:PORTS_ADDR_WIDTH];
    end
    //TODO: response MIN
    wire [PORTS*(WIDTH+REORDER_BITS)-1:0] recv_memory_stage_1d;
    generate for(g = 0; g < PORTS; g = g + 1) begin: memory_stage
        assign recv_memory_stage_1d[(g+1)*(WIDTH+REORDER_BITS)-1 -: WIDTH+REORDER_BITS] = {recv_memory_stage_data[g], recv_memory_stage_reorder[g]};
    end
    endgenerate
    reg [PORTS_ADDR_WIDTH-1:0] recv_min_control;
    always @* for(i = 0; i < PORTS_ADDR_WIDTH; i = i + 1) begin
        recv_min_control[PORTS_ADDR_WIDTH-i-1] = counter_pipeline[2+2*PORTS_ADDR_WIDTH+2*i][PORTS_ADDR_WIDTH-i-1];
    end
    wire [PORTS*(WIDTH+REORDER_BITS)-1:0]recv_min_stage_data_1d;
    omega_network_ff #(WIDTH+REORDER_BITS,PORTS) response_min(clk, recv_memory_stage_valid, recv_memory_stage_1d, recv_min_stage_valid, recv_min_stage_data_1d, recv_min_control);
    always @* for(i = 0; i < PORTS; i = i + 1) begin
        recv_min_stage_data[i] = recv_min_stage_data_1d[(i+1)*(WIDTH+REORDER_BITS)-1 -: WIDTH+REORDER_BITS];
    end

    /*
    always @(posedge clk) begin
        if(linked_fifo_pop[0] != 0) begin
            $display("linked_fifo_pop: %b", linked_fifo_pop[0]);
        end
        if(request_min_valid != 0) begin
            $display("request_min_valid: %b", request_min_valid);
            $display("send_min_stage_write: %b", send_min_stage_write);
            $display("send_min_stage_addr: %d", send_min_stage_addr[0]);
            $display("send_min_stage_data: %d", send_min_stage_data[0]);
        end
        if(recv_memory_stage_valid != 0) begin
            $display("recv_memory_stage_valid: %b", recv_memory_stage_valid);
            $display("reorder: %d", recv_memory_stage_reorder[0]);
        end
        if(recv_min_stage_valid != 0) begin
            $display("recv_min_valid: %b", recv_min_stage_valid);
            $display("data: %b", recv_min_stage_data[0][WIDTH+REORDER_BITS-1:REORDER_BITS]);
            $display("reorder: %H", recv_min_stage_data[0][REORDER_BITS-1:0]);
        end
        if(valid != 0) begin
            $display("valid: %b", valid);
        end
    end
    */
    `include "log2.vh"
    `include "constants.vh"
endmodule
