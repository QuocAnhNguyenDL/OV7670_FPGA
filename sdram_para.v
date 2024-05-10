`timescale 1ns / 1ps
//------------------------------------------------------------------------------
`define		W_IDLE		 4'd0		
`define		W_ACTIVE	 4'd1		
`define		W_TRCD		 4'd2		
/*************************************************************/
`define		W_READ		 4'd3		
`define		W_CL		 4'd4		
`define		W_RD		 4'd5		
`define		W_RWAIT		 4'd6		
/*************************************************************/
`define		W_WRITE		 4'd7		
`define		W_WD		 4'd8		
`define		W_TDAL		 4'd9		
/*************************************************************/
`define		W_AR		 4'd10		
`define		W_TRFC		 4'd11		


`define		I_NOP	 	4'd0		
`define		I_PRE 	 	4'd1		
`define		I_TRP 	 	4'd2		
`define		I_AR1 	 	4'd3		
`define		I_TRF1	 	4'd4		
`define		I_AR2 	 	4'd5		
`define		I_TRF2 	 	4'd6		
`define		I_MRS	 	4'd7		
`define		I_TMRD	 	4'd8		
`define		I_DONE	 	4'd9		

`define	end_trp			cnt_clk_r	== TRP_CLK
`define	end_trfc		cnt_clk_r	== TRFC_CLK
`define	end_tmrd		cnt_clk_r	== TMRD_CLK
`define	end_trcd		cnt_clk_r	== TRCD_CLK-1
`define end_tcl			cnt_clk_r   == TCL_CLK-1
`define end_rdburst		cnt_clk		== sdrd_byte-4
`define	end_tread		cnt_clk_r	== sdrd_byte+2
`define end_wrburst		cnt_clk		== sdwr_byte-1
`define	end_twrite		cnt_clk_r	== sdwr_byte-1
`define	end_tdal		cnt_clk_r	== TDAL_CLK	
`define	end_trwait		cnt_clk_r	== TRP_CLK

`define		CMD_INIT 	 5'b01111	
`define		CMD_NOP		 5'b10111	// NOP COMMAND
`define		CMD_ACTIVE	 5'b10011	// ACTIVE COMMAND
`define		CMD_READ	 5'b10101	// READ COMMADN
`define		CMD_WRITE	 5'b10100	// WRITE COMMAND
`define		CMD_B_STOP	 5'b10110	// BURST STOP
`define		CMD_PRGE	 5'b10010	// PRECHARGE
`define		CMD_A_REF	 5'b10001	// AOTO REFRESH
`define		CMD_LMR		 5'b10000	// LODE MODE REGISTER


//endmodule
