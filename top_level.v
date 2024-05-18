module top_level
( 
   //clock
	input CLOCK_50,
	input [17:0] SW,
	
	
	//sdram control
	output			DRAM_CLK,		//sdram clock
	output			DRAM_CKE,		//sdram clock enable
	output			DRAM_CS_N,		//sdram chip select
	output			DRAM_WE_N,		//sdram write enable
	output			DRAM_CAS_N,	//sdram column address strobe
	output			DRAM_RAS_N,	//sdram row address strobe
	output[1:0] 	DRAM_DQM,		//sdram data enable 
	output	   	DRAM_BA_0,		//sdram bank address
	output		   DRAM_BA_1,
	output[11:0]   DRAM_ADDR,		//sdram address
	inout	[15:0]	DRAM_DQ,		//sdram data
	
	//VGA
   output			VGA_HS,			//horizontal sync 
	output			VGA_VS,			//vertical sync
	output         VGA_CLK,
	output	[9:0]	VGA_R,		//VGA data
	output	[9:0]	VGA_G,
	output	[9:0]	VGA_B,
	output         VGA_BLANK,
	
	//CAM
	output		CMOS_SCLK,		//cmos i2c clock
	inout			CMOS_SDAT,		//cmos i2c data
	input			CMOS_VSYNC,		//cmos vsync
	input			CMOS_HREF,		//cmos hsync refrence
	input			CMOS_PCLK,		//cmos pxiel clock
	output		CMOS_XCLK,		//cmos externl clock
	input	[7:0]	CMOS_DB,		//cmos data
	output [17:0] LEDR
);

wire [15:0] VGAD;
wire CLOCK_25;

/*
assign VGA_R = {VGAD[15:11],5'b00000};		
assign VGA_G = {VGAD[10:5],4'b0000};
assign VGA_B = {VGAD[4:0],5'b00000};*/

assign LEDR[15:0] = VGAD;

CAM_SDRAM_VGA top
(
	.CLOCK_50(CLOCK_50),
	
	//cmos interface
	.CMOS_SCLK(CMOS_SCLK),		
	.CMOS_SDAT(CMOS_SDAT),		
	.CMOS_VSYNC(CMOS_VSYNC),		
	.CMOS_HREF(CMOS_HREF),		
	.CMOS_PCLK(CMOS_PCLK),		
	.CMOS_XCLK(CMOS_XCLK),		
	.CMOS_DB(CMOS_DB),		
	
	//sdram control
	.S_CLK(DRAM_CLK),		
	.S_CKE(DRAM_CKE),		
	.S_NCS(DRAM_CS_N),		
	.S_NWE(DRAM_WE_N),		
	.S_NCAS(DRAM_CAS_N),	
	.S_NRAS(DRAM_RAS_N),	
	.S_DQM(DRAM_DQM),		
	.S_BA({DRAM_BA_0,DRAM_BA_1}),		
	.S_A(DRAM_ADDR),		
	.S_DB(DRAM_DQ),		
	
	//VGA port			
	.VGA_HS(VGA_HS),			
	.VGA_VS(VGA_VS),			
	.VGAD(VGAD),
	.VGA_BLANK(VGA_BLANK),
	.VGA_CLK(VGA_CLK)
);

Filter filter
(
	.VGAD(VGAD),
	.select(SW[1:0]),
	
	.R(VGA_R),
	.G(VGA_G),
	.B(VGA_B)
);

endmodule
