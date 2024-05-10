module SDRAM_TOP
(
	//global clock
	input					clk_vga,		//vga clock
	input					clk_ref,		//sdram ctrl clock
	input					clk_refout,		//sdram clock output
	input					rst_n,			//global reset

	//sdram control
	output				sdram_clk,		//sdram clock
	output				sdram_cke,		//sdram clock enable
	output				sdram_cs_n,		//sdram chip select
	output				sdram_we_n,		//sdram write enable
	output				sdram_cas_n,	//sdram column address strobe
	output				sdram_ras_n,	//sdram row address strobe
	output				sdram_udqm,		//sdram data enable (H:8)
	output				sdram_ldqm,		//sdram data enable (L:8)
	output	[1 :0]	sdram_ba,		//sdram bank address
	output	[11:0]	sdram_addr,		//sdram address
	inout		[15:0]	sdram_data,		//sdram data
		
	
	//user interface read
	input					clk_write,		//fifo write clock
	input					sys_we,			//fifo write enable
	input		[15:0]	sys_data_in,	//fifo data input
	output				sdram_init_done,//sdram init done
	input					frame_valid,		//frame valid
	
	//user interface write
	input					sys_rd,        		//fifo read enable
	output 	[15:0]	sys_data_out,  		//fifo data output
	input					vga_framesync		//vga frame sync
);


//----------------------------------------------
wire				frame_write_done;	//sdram write frame done
wire				frame_read_done;	//sdram read frame done
wire	[1:0]		wr_bank;			//sdram write bank
wire	[1:0]		rd_bank;			//sdram read bank
wire				wr_load;			//sdram write address reset
wire				rd_load;			//sdram read address reset


sdram_2fifo_top	u_sdram_2fifo_top
(
	//global clock
	.clk_ref				(clk_ref),			//sdram	reference clock
	.clk_refout			(clk_refout),		//sdram clk	input 
	.clk_write			(clk_write),		//fifo data write clock
	.clk_read			(clk_vga),			//fifo data read clock
	.rst_n				(rst_n),			//global reset
	
	//sdram interface
	.sdram_clk			(sdram_clk),		//sdram clock	
	.sdram_cke			(sdram_cke),		//sdram clock enable	
	.sdram_cs_n			(sdram_cs_n),		//sdram chip select	
	.sdram_we_n			(sdram_we_n),		//sdram write enable	
	.sdram_ras_n		(sdram_ras_n),		//sdram column address strobe	
	.sdram_cas_n		(sdram_cas_n),		//sdram row address strobe	
	.sdram_ba			(sdram_ba),			//sdram data enable (H:8)    
	.sdram_addr			(sdram_addr),		//sdram data enable (L:8)	
	.sdram_data			(sdram_data),		//sdram bank address	
	.sdram_udqm			(sdram_udqm),		//sdram address	
	.sdram_ldqm			(sdram_ldqm),		//sdram data
	
	//user interface
	//burst and addr
	.wr_length			(9'd256),			//sdram write burst length
	.rd_length			(9'd256),			//sdram read burst length
	.wr_addr				({wr_bank,20'd0}),			//sdram start write address
	.wr_max_addr		({wr_bank,20'd307200}),		//sdram max write address
	.wr_load				(wr_load),			//sdram write address reset
	.rd_addr				({rd_bank,20'd0}),			//sdram start read address
	.rd_max_addr		({rd_bank,20'd307200}),		//sdram max read address
	.rd_load				(rd_load),			//sdram read address reset
	
	//dcfifo interface
	.sdram_init_done	(sdram_init_done),	//sdram init done
	.frame_write_done	(frame_write_done),	//sdram write one frame
	.frame_read_done	(frame_read_done),	//sdram read one frame
	.sys_we				(sys_we),			//fifo write enable
	.sys_data_in		(sys_data_in),		//fifo data input
	.sys_rd				(sys_rd),			//fifo read enable
	.sys_data_out		(sys_data_out),		//fifo data output
	.data_valid			(vga_framesync)		//system data output enable
);

//-----------------------------
sdbank_switch	u_sdbank_switch
(
	.clk					(clk_vga),
	.rst_n				(rst_n),
	
	.bank_valid			(frame_valid),
	.frame_write_done	(frame_write_done),
	.frame_read_done	(frame_read_done),
	
	.wr_bank				(wr_bank),
	.rd_bank				(rd_bank),
	.wr_load				(wr_load),
	.rd_load				(rd_load)
);

endmodule
