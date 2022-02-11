`timescale 1ns/1ns

module cross_bar_tb();

reg         PCLK;
reg         PRESETN;

reg         master_1_req;
reg         master_1_cmd;
reg [31:0]  master_1_addr;
reg [31:0]  master_1_wdata;
wire        master_1_ack;
wire [31:0] master_1_rdata;

reg         master_2_req;
reg         master_2_cmd;
reg [31:0]  master_2_addr;
reg [31:0]  master_2_wdata;
wire        master_2_ack;
wire [31:0] master_2_rdata;

wire         slave_1_req;
wire         slave_1_cmd;
wire [31:0]  slave_1_addr;
wire [31:0]  slave_1_wdata;
reg          slave_1_ack;
reg [31:0]   slave_1_rdata;

wire         slave_2_req;
wire         slave_2_cmd;
wire [31:0]  slave_2_addr;
wire [31:0]  slave_2_wdata;
reg          slave_2_ack;
reg [31:0]   slave_2_rdata;

cross_bar cross_bar_0(
    .PCLK           (PCLK           ),
    .PRESETN        (PRESETN        ),
    .master_1_req   (master_1_req   ),
    .master_1_cmd   (master_1_cmd   ),
    .master_1_addr  (master_1_addr  ),
    .master_1_wdata (master_1_wdata ),
    .master_1_ack   (master_1_ack   ),
    .master_1_rdata (master_1_rdata ),
    .master_2_req   (master_2_req   ),
    .master_2_cmd   (master_2_cmd   ),
    .master_2_addr  (master_2_addr  ),
    .master_2_wdata (master_2_wdata ),
    .master_2_ack   (master_2_ack   ),
    .master_2_rdata (master_2_rdata ),
    .slave_1_ack    (slave_1_ack    ),
    .slave_1_rdata  (slave_1_rdata  ),
    .slave_1_req    (slave_1_req    ),
    .slave_1_cmd    (slave_1_cmd    ),
    .slave_1_addr   (slave_1_addr   ),
    .slave_1_wdata  (slave_1_wdata  ),
    .slave_2_ack    (slave_2_ack    ),
    .slave_2_rdata  (slave_2_rdata  ),
    .slave_2_req    (slave_2_req    ),
    .slave_2_cmd    (slave_2_cmd    ),
    .slave_2_addr   (slave_2_addr   ),
    .slave_2_wdata  (slave_2_wdata  )
);

parameter CLK = 10;
parameter DELAY = CLK*10;


initial
begin
    PCLK = 0;
    forever #(CLK/2) PCLK = !PCLK;
end

parameter TEST_NUMBER = 10;

integer master_1_rd_err_cnt;
integer master_1_wr_err_cnt;

integer master_2_rd_err_cnt;
integer master_2_wr_err_cnt; 

integer i;
integer slave_sel;
integer cmd_sel;
reg[31:0] addr;
integer wdata;
integer rdata;
integer trans_num;
initial begin
    PRESETN = 0;
    master_1_rd_err_cnt = 0;
    master_1_wr_err_cnt = 0;
    master_2_rd_err_cnt = 0;
    master_2_wr_err_cnt = 0;

    master_1_req = 0;
    master_1_cmd = 0;
    master_1_addr = 0;
    master_1_wdata = 0;
    master_2_req = 0;
    master_2_cmd = 0;
    master_2_addr = 0;
    master_2_wdata = 0;
    slave_1_ack = 0;
    slave_1_rdata = 0;
    slave_2_ack = 0;
    slave_2_rdata = 0;

    #CLK;
    PRESETN = 1;
    #(DELAY);

    $monitor("master 1 rd error counter: %d, time; %t", master_1_rd_err_cnt, $time);
    $monitor("master 1 wr error counter: %d, time; %t", master_1_wr_err_cnt, $time);
    $monitor("master 2 rd error counter: %d, time; %t", master_2_rd_err_cnt, $time);
    $monitor("master 2 wr error counter: %d, time; %t", master_2_wr_err_cnt, $time);

    // master 1 test
    for(i = 0; i < TEST_NUMBER; i = i+1) begin
        slave_sel = $urandom % 2;
        cmd_sel = $urandom % 2;
        addr[31] = slave_sel;
        addr[30:0] = $urandom;
        trans_num = (1+$urandom%5);
        if(cmd_sel) begin // write
            wdata = $urandom;
            master_1_write(addr, wdata, trans_num);
        end
        else begin
            master_1_read(addr, rdata, trans_num);
        end
    end
    #(5*DELAY);

    // master 2 test
    for(i = 0; i < TEST_NUMBER; i = i+1) begin
        slave_sel = $urandom % 2;
        cmd_sel = $urandom % 2;
        addr[31] = slave_sel;
        addr[30:0] = $urandom;
        trans_num = (1+$urandom%5);
        if(cmd_sel) begin // write
            wdata = $urandom;
            master_2_write(addr, wdata, trans_num);
        end
        else begin
            master_2_read(addr, rdata, trans_num);
        end
    end
    #(5*DELAY);

    // slave 1 test
    for(i = 0; i < TEST_NUMBER; i = i+1) begin
        fork
            begin // master 1
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_1_write(($urandom & 32'h7fff_ffff), wdata, (1+$urandom%5));
                end
                else begin
                    master_1_read(($urandom & 32'h7fff_ffff), rdata, (1+$urandom%5));
                end

            end

            begin // master 2
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_2_write(($urandom & 32'h7fff_ffff), wdata, (1+$urandom%5));
                end
                else begin
                    master_2_read(($urandom & 32'h7fff_ffff), rdata, (1+$urandom%5));
                end
            end
        join
    end
    #(5*DELAY);

    // slave 2 test
    for(i = 0; i < TEST_NUMBER; i = i+1) begin
        fork
            begin // master 1
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_1_write(($urandom | 32'h8000_0000), wdata, (1+$urandom%5));
                end
                else begin
                    master_1_read(($urandom | 32'h8000_0000), rdata, (1+$urandom%5));
                end

            end

            begin // master 2
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_2_write(($urandom | 32'h8000_0000), wdata, (1+$urandom%5));
                end
                else begin
                    master_2_read(($urandom | 32'h8000_0000), rdata, (1+$urandom%5));
                end
            end
        join
    end
    #(5*DELAY);

    // full random test
    for(i = 0; i < TEST_NUMBER; i = i+1) begin
        fork
            begin // master 1
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_1_write($urandom, wdata, (1+$urandom%5));
                end
                else begin
                    master_1_read($urandom, rdata, (1+$urandom%5));
                end

            end

            begin // master 2
                if($urandom % 2) begin // write
                    wdata = $urandom;
                    master_2_write($urandom, wdata, (1+$urandom%5));
                end
                else begin
                    master_2_read($urandom, rdata, (1+$urandom%5));
                end
            end
        join
    end
    #(5*DELAY);


    #DELAY;
    $stop;
end

//slave 1
integer ack1_delay;
reg [31:0] slave_1_memory;
always@(posedge slave_1_req) begin
    ack1_delay = 1;
    repeat(ack1_delay)
    @(posedge PCLK);
    slave_1_ack = 1;
    if(slave_1_cmd) begin // write
        slave_1_memory = slave_1_wdata;
        @(posedge PCLK);
        slave_1_ack = 0;
    end 
    else begin // read
        @(posedge PCLK);
        slave_1_ack = 0;
        slave_1_rdata = slave_1_addr;
    end
end

//slave 2
integer ack2_delay;
reg [31:0] slave_2_memory;
always@(posedge slave_2_req) begin
    ack2_delay = 1 + $urandom % 4;
    repeat(ack2_delay)
    @(posedge PCLK);
    slave_2_ack = 1;
    if(slave_2_cmd) begin // write
        slave_2_memory = slave_2_wdata;
        @(posedge PCLK);
        slave_2_ack = 0;
    end
    else begin // read
        @(posedge PCLK);
        slave_2_ack = 0;
        slave_2_rdata = slave_2_addr;
    end
end


task automatic master_1_read;
    input [31:0] ADDR;
    inout [31:0] DATA;
    input [31:0] transact_num;
    integer i;
    begin
        @(posedge PCLK);
        master_1_req = 1;
        master_1_cmd = 0;
        master_1_addr = ADDR;

        for(i = 0; i < transact_num; i = i+1) begin
            @(posedge master_1_ack);
            @(posedge PCLK);
            if(i == transact_num-1) master_1_req = 0;
            #1;
            if(master_1_rdata != master_1_addr) 
                master_1_rd_err_cnt = master_1_rd_err_cnt + 1;
            
            master_1_addr[30:0] = master_1_addr[30:0] + 1;
        end
    end
endtask

task automatic master_1_write;
    input [31:0] ADDR;
    inout [31:0] DATA;
    input [31:0] transact_num;
    integer i;
    begin
        @(posedge PCLK);
        master_1_req = 1;
        master_1_cmd = 1;
        master_1_addr = ADDR;
        master_1_wdata = DATA;

        for(i = 0; i < transact_num; i = i+1) begin
            @(posedge master_1_ack);
            @(posedge PCLK);
            if(master_1_wdata != (ADDR[31] ? slave_2_memory : slave_1_memory)) 
                master_1_wr_err_cnt = master_1_wr_err_cnt + 1;
            
            master_1_addr[30:0] = master_1_addr[30:0] + 1;
            master_1_wdata = $urandom;
        end
        master_1_req = 0;
    end
endtask

task automatic master_2_read;
    input [31:0] ADDR;
    inout [31:0] DATA;
    input [31:0] transact_num;
    integer i;
    begin
        @(posedge PCLK);
        master_2_req = 1;
        master_2_cmd = 0;
        master_2_addr = ADDR;

        for(i = 0; i < transact_num; i = i+1) begin
            @(posedge master_2_ack);
            @(posedge PCLK);
            if(i == transact_num-1) master_2_req = 0;
            #1;
            if(master_2_rdata != master_2_addr) 
                master_2_rd_err_cnt = master_2_rd_err_cnt + 1;
            
            master_2_addr[30:0] = master_2_addr[30:0] + 1;
        end
    end
endtask

task automatic master_2_write;
    input [31:0] ADDR;
    inout [31:0] DATA;
    input [31:0] transact_num;
    integer i;
    begin
        @(posedge PCLK);
        master_2_req = 1;
        master_2_cmd = 1;
        master_2_addr = ADDR;
        master_2_wdata = DATA;

        for(i = 0; i < transact_num; i = i+1) begin
            @(posedge master_2_ack);
            @(posedge PCLK);
            if(master_2_wdata != (ADDR[31] ? slave_2_memory : slave_1_memory)) 
                master_2_wr_err_cnt = master_2_wr_err_cnt + 1;
            
            master_2_addr[30:0] = master_2_addr[30:0] + 1;
            master_2_wdata = $urandom;
        end
        master_2_req = 0;
    end
endtask



endmodule