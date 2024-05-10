`timescale 1ns / 1ps
module sdram_wr_data(
					clk,rst_n,
					sdram_data,
					sys_data_in,sys_data_out,
					work_state,cnt_clk
				);
input clk;		
input rst_n;	
	
inout[15:0] sdram_data;		

input[15:0] sys_data_in;	
output[15:0] sys_data_out;	

input[3:0] work_state;	
input[8:0] cnt_clk;		

`include "sdram_para.v"		

reg[15:0] sdr_din;
reg sdr_dlink;		

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) sdr_din <= 16'd0;	
	else if((work_state == `W_WRITE) | (work_state == `W_WD)) sdr_din <= sys_data_in;	

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) sdr_dlink <= 1'b0;
   else if((work_state == `W_WRITE) | (work_state == `W_WD)) sdr_dlink <= 1'b1;
	else sdr_dlink <= 1'b0;

assign sdram_data = sdr_dlink ? sdr_din:16'hzzzz;


reg[15:0] sdr_dout;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) sdr_dout <= 16'd0;	
	else if((work_state == `W_RD)/* & (cnt_clk > 9'd0) & (cnt_clk < 9'd10)*/) sdr_dout <= sdram_data;	

assign sys_data_out = sdr_dout;

//------------------------------------------------------------------------------

endmodule
