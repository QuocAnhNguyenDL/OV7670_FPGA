`timescale 1ns / 1ps
module sdram_cmd(
				clk,rst_n,
				sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,sdram_ba,sdram_addr,
				sys_wraddr,sys_rdaddr,sdwr_byte,sdrd_byte,
				init_state,work_state,sys_r_wn,cnt_clk
			);
input clk;					
input rst_n;				
output sdram_cke;			
output sdram_cs_n;			
output sdram_ras_n;			
output sdram_cas_n;			
output sdram_we_n;			
output[1:0] sdram_ba;		
output[11:0] sdram_addr;	
input[21:0] sys_wraddr;		
input[21:0] sys_rdaddr;		
input[8:0] sdwr_byte;		
input[8:0] sdrd_byte;		
	
input[3:0] init_state;		
input[3:0] work_state;		
input sys_r_wn;			
input[8:0] cnt_clk;		


`include "sdram_para.v"		

//-------------------------------------------------------------------------------
reg[4:0] sdram_cmd_r;	
reg[1:0] sdram_ba_r;
reg[11:0] sdram_addr_r;

assign {sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd_r;
assign sdram_ba = sdram_ba_r;
assign sdram_addr = sdram_addr_r;

//-------------------------------------------------------------------------------
wire[21:0] sys_addr;	
assign sys_addr = sys_r_wn ? sys_rdaddr:sys_wraddr;		
	
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			sdram_cmd_r <= `CMD_INIT;
			sdram_ba_r <= 2'b11;
			sdram_addr_r <= 12'hfff;
		end
	else
		case (init_state)
				`I_NOP,`I_TRP,`I_TRF1,`I_TRF2,`I_TMRD: begin
						sdram_cmd_r <= `CMD_NOP;
						sdram_ba_r <= 2'b11;
						sdram_addr_r <= 12'hfff;	
					end
				`I_PRE: begin
						sdram_cmd_r <= `CMD_PRGE;
						sdram_ba_r <= 2'b11;
						sdram_addr_r <= 12'hfff;
					end 
				`I_AR1,`I_AR2: begin
						sdram_cmd_r <= `CMD_A_REF;
						sdram_ba_r <= 2'b11;
						sdram_addr_r <= 12'hfff;						
					end 			 	
				`I_MRS: begin	
						sdram_cmd_r <= `CMD_LMR;
						sdram_ba_r <= 2'b00;	
						sdram_addr_r <= {
                            2'b00,			
                            1'b0,			
                            2'b00,			
                            3'b011,			
                            1'b0,			
                            3'b111			
								};
					end	
				`I_DONE:
					case (work_state)
							`W_IDLE,`W_TRCD,`W_CL,`W_TRFC,`W_TDAL: begin
									sdram_cmd_r <= `CMD_NOP;
									sdram_ba_r <= 2'b11;
									sdram_addr_r <= 12'hfff;
								end
							`W_ACTIVE: begin
									sdram_cmd_r <= `CMD_ACTIVE;
									sdram_ba_r <= sys_addr[21:20];	
									sdram_addr_r <= sys_addr[19:8];	
								end
							`W_READ: begin
									sdram_cmd_r <= `CMD_READ;
									sdram_ba_r <= sys_addr[21:20];	
									sdram_addr_r <= {
													4'b0100,		
													sys_addr[7:0]	
												};
								end
							`W_RD: begin
									if(`end_rdburst) sdram_cmd_r <= `CMD_B_STOP;
									else begin
										sdram_cmd_r <= `CMD_NOP;
										sdram_ba_r <= 2'b11;
										sdram_addr_r <= 12'hfff;								
									end
								end								
							`W_WRITE: begin
									sdram_cmd_r <= `CMD_WRITE;
									sdram_ba_r <= sys_addr[21:20];	
									sdram_addr_r <= {
													4'b0100,		
													sys_addr[7:0]	
												};
								end		
							`W_WD: begin
									if(`end_wrburst) sdram_cmd_r <= `CMD_B_STOP;
									else begin
										sdram_cmd_r <= `CMD_NOP;
										sdram_ba_r <= 2'b11;
										sdram_addr_r <= 12'hfff;								
									end
								end													
							`W_AR: begin
									sdram_cmd_r <= `CMD_A_REF;
									sdram_ba_r <= 2'b11;
									sdram_addr_r <= 12'hfff;	
								end
							default: begin
									sdram_cmd_r <= `CMD_NOP;
									sdram_ba_r <= 2'b11;
									sdram_addr_r <= 12'hfff;	
								end
						endcase
				default: begin
							sdram_cmd_r <= `CMD_NOP;
							sdram_ba_r <= 2'b11;
							sdram_addr_r <= 12'hfff;	
						end
			endcase
end

endmodule

