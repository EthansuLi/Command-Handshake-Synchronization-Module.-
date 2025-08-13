//***************************************
//COPYRIGHT(C)2025,EthasuLi
//All rights reserved.
//Module Name  : cmd_bus_sync.v
//
//Author       : EthasuLi
//Email        : 13591028146@163.com
//Data         : 2025/8/5
//Version      : V 1.0
//
//Abstract     : 
//Called by    :
//
//****************************************  

module cmd_bus_sync#(
	parameter CMD_WIDTH	= 16;
)
(
	input							src_clk,
	input							src_rst,
	input	[CMD_WIDTH -1:0]		src_cmd,
	input							src_req,
	output							src_ack,
	
	input							dst_clk,
	input							dst_rst,
	output	[CMD_WIDTH -1:0]		dst_cmd,
	output							dst_req,
	input							dst_ack	// dst ready
);

reg [2:0] shift_src_req;
wire	  src_2_dst_req;
reg [2:0] shift_src_ack;
reg		  dst_2_src_ack;

reg state;
localparam CMD_GET = 0;
localparam CMD_SET = 1;

always@(posedge dst_clk or negedge dst_rst) begin
	if(~dst_rst)
		shift_src_req <= 'd0;
	else 
		shift_src_req <= {shift_src_req[1:0],src_req};
end
assign src_2_dst_req = shift_src_req[2];
always@(posedge src_clk or negedge src_rst) begin
	if(~src_rst)
		shift_src_ack <= 'd0;
	else 
		shift_src_ack <= {shift_src_ack[1:0],dst_2_src_ack};
end
assign src_ack = shift_src_ack[2];

always@(posedge dst_clk or negedge dst_rst) begin
	if(~dst_rst) begin 
		state <= CMD_GET;
		dst_cmd <= 'd0;
		dst_req <= 1'b0;
		dst_2_src_ack <= 1'b0;
	end
	else begin
		case(state)
			CMD_GET : begin
				if(src_2_dst_req && ~dst_ack) begin
					dst_req <= 1'b1;
					dst_cmd <= src_cmd;
					dst_2_src_ack <= 1'b1;
					state <= CMD_SET;
				end
			end
			CMD_SET : begin
				if(dst_ack)
					dst_req <= 1'b0;
				if(~src_2_dst_req)
					dst_2_src_ack <= 1'b0;
				if(~dst_2_src_ack && ~dst_req)
					state <= CMD_SET;
			end		
		endcase	
	end
end




endmodule
