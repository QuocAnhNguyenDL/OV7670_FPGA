`timescale 1ns / 1ps
module sdram_ctrl(
				clk,rst_n,
				sdram_wr_req,sdram_rd_req,
				sdwr_byte,sdrd_byte,
				sdram_wr_ack,sdram_rd_ack,
				sdram_init_done,
				init_state,work_state,cnt_clk,sys_r_wn
			);
input clk;				
input rst_n;		

input sdram_wr_req;			
input sdram_rd_req;			
input[8:0] sdwr_byte;		
input[8:0] sdrd_byte;		
output sdram_wr_ack;		
output sdram_rd_ack;		

output	sdram_init_done;		

output[3:0] init_state;	
output[3:0] work_state;	
output[8:0] cnt_clk;	
output sys_r_wn;		

wire done_200us;		
wire sdram_busy;		
reg sdram_ref_req;		
wire sdram_ref_ack;		

`include "sdram_para.v"		

parameter		TRP_CLK		= 9'd4,
				TRFC_CLK	= 9'd6,
				TMRD_CLK	= 9'd6,
				TRCD_CLK	= 9'd2,
				TCL_CLK		= 9'd3,		
				TDAL_CLK	= 9'd3;		

reg[14:0] cnt_200us; 
always @ (posedge clk or negedge rst_n) 
	if(!rst_n) cnt_200us <= 15'd0;
	else if(cnt_200us < 15'd20_000) cnt_200us <= cnt_200us+1'b1;	

assign done_200us = (cnt_200us == 15'd20_000);

reg[3:0] init_state_r;	

always @ (posedge clk or negedge rst_n)
	if(!rst_n) init_state_r <= `I_NOP;
	else 
		case (init_state_r)
				`I_NOP: 	init_state_r <= done_200us ? `I_PRE:`I_NOP;		
				`I_PRE: 	init_state_r <= `I_TRP;		
				`I_TRP: 	init_state_r <= (`end_trp) ? `I_AR1:`I_TRP;			
				`I_AR1: 	init_state_r <= `I_TRF1;	
				`I_TRF1:	init_state_r <= (`end_trfc) ? `I_AR2:`I_TRF1;			
				`I_AR2: 	init_state_r <= `I_TRF2; 	
				`I_TRF2:	init_state_r <= (`end_trfc) ? `I_MRS:`I_TRF2; 		
				`I_MRS:		init_state_r <= `I_TMRD;
				`I_TMRD:	init_state_r <= (`end_tmrd) ? `I_DONE:`I_TMRD;	
				`I_DONE:	init_state_r <= `I_DONE;		
				default: init_state_r <= `I_NOP;
				endcase


assign init_state = init_state_r;
assign sdram_init_done = (init_state_r == `I_DONE);		
//------------------------------------------------------------------------------	 
reg[10:0] cnt_15us;	
always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt_15us <= 11'd0;
	else if(cnt_15us < 11'd1499) cnt_15us <= cnt_15us+1'b1;
	else cnt_15us <= 11'd0;	

always @ (posedge clk or negedge rst_n)
	if(!rst_n) sdram_ref_req <= 1'b0;
	else if(cnt_15us == 11'd1498) sdram_ref_req <= 1'b1;	
	else if(sdram_ref_ack) sdram_ref_req <= 1'b0;		

reg[3:0] work_state_r;	
reg sys_r_wn;			

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		work_state_r <= `W_IDLE;
	else
		begin
		case (work_state_r)
		`W_IDLE:	if(sdram_ref_req & sdram_init_done) 
						begin
						work_state_r <= `W_AR; 		
						sys_r_wn <= 1'b1;
						end 		
					else if(sdram_wr_req & sdram_init_done) 
						begin
						work_state_r <= `W_ACTIVE;	
						sys_r_wn <= 1'b0;	
						end											
					else if(sdram_rd_req && sdram_init_done) 
						begin
						work_state_r <= `W_ACTIVE;	
						sys_r_wn <= 1'b1;	
						end
					else 
						begin 
						work_state_r <= `W_IDLE;
						sys_r_wn <= 1'b1;
						end
		/*************************************************************/
		`W_ACTIVE: 	if(TRCD_CLK == 0)
						 if(sys_r_wn) work_state_r <= `W_READ;
						 else work_state_r <= `W_WRITE;
					else work_state_r <= `W_TRCD;
		`W_TRCD:	 if(`end_trcd)
						 if(sys_r_wn) work_state_r <= `W_READ;
						 else work_state_r <= `W_WRITE;
					else work_state_r <= `W_TRCD;
					
		/*************************************************************/
		`W_READ:	work_state_r <= `W_CL;	
		`W_CL:		work_state_r <= (`end_tcl) ? `W_RD:`W_CL;	
		`W_RD:		work_state_r <= (`end_tread) ? `W_IDLE:`W_RD;	
		`W_RWAIT:	work_state_r <= (`end_trwait) ? `W_IDLE:`W_RWAIT;
		
		/*************************************************************/
		`W_WRITE:	work_state_r <= `W_WD;
		`W_WD:		work_state_r <= (`end_twrite) ? `W_TDAL:`W_WD;
		`W_TDAL:	work_state_r <= (`end_tdal) ? `W_IDLE:`W_TDAL;
		
		/*************************************************************/
		`W_AR:		work_state_r <= `W_TRFC; 
		`W_TRFC:	work_state_r <= (`end_trfc) ? `W_IDLE:`W_TRFC;
		/*************************************************************/
		default: 	work_state_r <= `W_IDLE;
		endcase
		end
end

assign work_state = work_state_r;		
assign sdram_ref_ack = (work_state_r == `W_AR);		

assign sdram_wr_ack = 	((work_state == `W_TRCD) & ~sys_r_wn) | 
						(work_state == `W_WRITE)|
						((work_state == `W_WD) & (cnt_clk_r < sdwr_byte -2'd2));		
assign sdram_rd_ack = 	(work_state_r == `W_RD) & 
						(cnt_clk_r >= 9'd1) & (cnt_clk_r < sdrd_byte + 2'd1);		

reg[8:0] cnt_clk_r;
reg cnt_rst_n;	

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) cnt_clk_r <= 9'd0;		
	else if(!cnt_rst_n) cnt_clk_r <= 9'd0;
	else cnt_clk_r <= cnt_clk_r+1'b1;		
	
assign cnt_clk = cnt_clk_r;		

always @ (init_state_r or work_state_r or cnt_clk_r or sdwr_byte or sdrd_byte) begin
	case (init_state_r)
	    	`I_NOP:	cnt_rst_n <= 1'b0;
	   		`I_PRE:	cnt_rst_n <= 1'b1;	
	   		`I_TRP:	cnt_rst_n <= (`end_trp) ? 1'b0:1'b1;	
	    	`I_AR1,`I_AR2:
	         		cnt_rst_n <= 1'b1;			
	    	`I_TRF1,`I_TRF2:
	         		cnt_rst_n <= (`end_trfc) ? 1'b0:1'b1;	
			`I_MRS:	cnt_rst_n <= 1'b1;			
			`I_TMRD:	cnt_rst_n <= (`end_tmrd) ? 1'b0:1'b1;	
		   	`I_DONE:
				begin
				case (work_state_r)
				`W_IDLE:	cnt_rst_n <= 1'b0;
				`W_ACTIVE: 	cnt_rst_n <= 1'b1;
				`W_TRCD:	cnt_rst_n <= (`end_trcd) ? 1'b0:1'b1;
				`W_CL:		cnt_rst_n <= (`end_tcl) ? 1'b0:1'b1;
				`W_RD:		cnt_rst_n <= (`end_tread) ? 1'b0:1'b1;
				`W_RWAIT:	cnt_rst_n <= (`end_trwait) ? 1'b0:1'b1;
				`W_WD:		cnt_rst_n <= (`end_twrite) ? 1'b0:1'b1;
				`W_TDAL:	cnt_rst_n <= (`end_tdal) ? 1'b0:1'b1;
				`W_TRFC:	cnt_rst_n <= (`end_trfc) ? 1'b0:1'b1;
				default: cnt_rst_n <= 1'b0;
				endcase
				end
		default: cnt_rst_n <= 1'b0;
		endcase
end

endmodule
