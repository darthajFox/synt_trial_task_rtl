
module cross_bar
(    
    input           PCLK,
    input           PRESETN,

    // masters i/o
    input               master_1_req,
    input               master_1_cmd,
    input [31:0]        master_1_addr,
    input [31:0]        master_1_wdata,
    output reg          master_1_ack,
    output reg [31:0]   master_1_rdata,

    input               master_2_req,
    input               master_2_cmd,
    input [31:0]        master_2_addr,
    input [31:0]        master_2_wdata,
    output reg          master_2_ack,
    output reg [31:0]   master_2_rdata,

    // slaves i/o
    input               slave_1_ack,
    input [31:0]        slave_1_rdata,
    output reg          slave_1_req,
    output reg          slave_1_cmd,
    output reg [31:0]   slave_1_addr,
    output reg [31:0]   slave_1_wdata,

    input               slave_2_ack,
    input [31:0]        slave_2_rdata,
    output reg          slave_2_req,
    output reg          slave_2_cmd,
    output reg [31:0]   slave_2_addr,
    output reg [31:0]   slave_2_wdata
);

reg slave_1_arbitr;
reg slave_2_arbitr;

wire slave_1_arbitr_req = (!master_1_addr[31] & master_1_req) && (!master_2_addr[31] & master_2_req);
wire slave_2_arbitr_req = (master_1_addr[31] & master_1_req) && (master_2_addr[31] & master_2_req);

wire slave_1_ask = (!master_1_addr[31] & master_1_req) || (!master_2_addr[31] & master_2_req);
wire slave_2_ask = (master_1_addr[31] & master_1_req) || (master_2_addr[31] & master_2_req);

wire slave_1_master_sel = slave_1_arbitr_req ? slave_1_arbitr : (!master_2_addr[31] & master_2_req);
wire slave_2_master_sel = slave_2_arbitr_req ? slave_2_arbitr : (master_2_addr[31] & master_2_req);

reg slave_1_cmd_r;
reg slave_1_current_master_ID;
reg [2:0] slave_1_state;
reg slave_1_ack_q;

reg slave_2_cmd_r;
reg slave_2_current_master_ID;
reg [2:0] slave_2_state;
reg slave_2_ack_q;

localparam IDLE = 3'b001,
           SET  = 3'b010,
           ACK  = 3'b100;

// slave 1 mux
always@(*) begin
    slave_1_req = 0;
    slave_1_cmd = 0;
    slave_1_addr = 0;
    slave_1_wdata = 0;
    if(slave_1_state == SET) begin
        slave_1_req = slave_1_current_master_ID ? master_2_req : master_1_req;
        slave_1_cmd = slave_1_current_master_ID ? master_2_cmd : master_1_cmd;
        slave_1_addr = slave_1_current_master_ID ? master_2_addr : master_1_addr;
        slave_1_wdata = slave_1_current_master_ID ? master_2_wdata : master_1_wdata;
    end
    else
    if(slave_1_ask & (slave_1_state == IDLE)) begin
        slave_1_req = slave_1_master_sel ? master_2_req : master_1_req;
        slave_1_cmd = slave_1_master_sel ? master_2_cmd : master_1_cmd;
        slave_1_addr = slave_1_master_sel ? master_2_addr : master_1_addr;
        slave_1_wdata = slave_1_master_sel ? master_2_wdata : master_1_wdata;
    end
end

// slave 2
always@(*) begin
    slave_2_req = 0;
    slave_2_cmd = 0;
    slave_2_addr = 0;
    slave_2_wdata = 0;
    if(slave_2_state == SET) begin
        slave_2_req = slave_2_current_master_ID ? master_2_req : master_1_req;
        slave_2_cmd = slave_2_current_master_ID ? master_2_cmd : master_1_cmd;
        slave_2_addr = slave_2_current_master_ID ? master_2_addr : master_1_addr;
        slave_2_wdata = slave_2_current_master_ID ? master_2_wdata : master_1_wdata;
    end
    else
    if(slave_2_ask & (slave_2_state == IDLE)) begin
        slave_2_req = slave_2_master_sel ? master_2_req : master_1_req;
        slave_2_cmd = slave_2_master_sel ? master_2_cmd : master_1_cmd;
        slave_2_addr = slave_2_master_sel ? master_2_addr : master_1_addr;
        slave_2_wdata = slave_2_master_sel ? master_2_wdata : master_1_wdata;
    end
end

always@(posedge PCLK) begin
    if(!PRESETN) begin
        master_1_ack <= 0;
        master_2_ack <= 0;
        slave_1_ack_q <= 0;
        slave_2_ack_q <= 0;
        slave_1_arbitr <= 0;
        slave_2_arbitr <= 0;
        slave_1_state <= IDLE;
        slave_2_state <= IDLE;
    end
    else begin
        master_1_ack <= 0;
        master_2_ack <= 0;

        slave_1_ack_q <= slave_1_ack;
        slave_2_ack_q <= slave_2_ack;
        
        case(slave_1_state)
            IDLE:begin
                if(slave_1_ask) begin
                    if(slave_1_arbitr_req)
                        slave_1_arbitr <= !slave_1_arbitr;
                    slave_1_current_master_ID <= slave_1_master_sel;
                    slave_1_cmd_r <= slave_1_cmd;
                    slave_1_state <= SET;
                end
            end
            SET:begin
                if(!slave_1_ack_q && slave_1_ack) begin
                    if(slave_1_current_master_ID) 
                        master_2_ack <= 1'b1;
                    else
                        master_1_ack <= 1'b1;
                    slave_1_state <= ACK;
                end
                else 
                if(!slave_1_ask) begin
                    slave_1_state <= IDLE;
                end
            end
            ACK:begin
                if(!slave_1_cmd_r)
                    if(slave_1_current_master_ID) 
                        master_2_rdata <= slave_1_rdata;
                    else
                        master_1_rdata <= slave_1_rdata;
                slave_1_state <= IDLE;
            end
        endcase

        case(slave_2_state)
            IDLE:begin
                if(slave_2_ask) begin
                    if(slave_2_arbitr_req)
                        slave_2_arbitr <= !slave_2_arbitr;
                    slave_2_current_master_ID <= slave_2_master_sel;
                    slave_2_cmd_r <= slave_2_cmd;
                    slave_2_state <= SET;
                end
            end
            SET:begin
                if(!slave_2_ack_q && slave_2_ack) begin
                    if(slave_2_current_master_ID) 
                        master_2_ack <= 1'b1;
                    else
                        master_1_ack <= 1'b1;
                    slave_2_state <= ACK;
                end
                else 
                if(!slave_2_ask) begin
                    slave_2_state <= IDLE;
                end
            end
            ACK:begin
                if(!slave_2_cmd_r)
                    if(slave_2_current_master_ID) 
                        master_2_rdata <= slave_2_rdata;
                    else
                        master_1_rdata <= slave_2_rdata;
                slave_2_state <= IDLE;
            end
        endcase
    end
end

endmodule