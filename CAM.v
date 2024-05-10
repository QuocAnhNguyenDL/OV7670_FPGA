module CAM
(
	input 		clk_vga,
	input 		sys_rst_n,
	
	input 		sdram_init_done,
	
	output		CMOS_SCLK,		//cmos i2c clock
	inout			CMOS_SDAT,		//cmos i2c data
	input			CMOS_VSYNC,		//cmos vsync
	input			CMOS_HREF,		//cmos hsync refrence
	input			CMOS_PCLK,		//cmos pxiel clock
	output		CMOS_XCLK,		//cmos externl clock
	input	[7:0]	CMOS_DB,			//cmos data
	
	output		CMOS_oCLK,
	output[15:0]		CMOS_oDATA,
	output		CMOS_VALID
);

I2C_AV_Config	u_I2C_AV_Config 
(
	//Global clock
	.iCLK				(clk_vga),		//25MHz
	.iRST_N				(sys_rst_n),	//Global Reset
	
	//I2C Side
	.I2C_SCLK			(CMOS_SCLK),	//I2C CLOCK
	.I2C_SDAT			(CMOS_SDAT),	//I2C DATA
	
	//CMOS Signal
	.Config_Done		(Config_Done),	//I2C Config done
);

wire			frame_valid;		//data valid, or address restart
wire	[7:0]	cmos_fps_data;		//cmos frame rate
CMOS_Capture	u_CMOS_Capture
(
	//Global Clock
	.iCLK					(clk_vga),		//25MHz
	.iRST_N				(sys_rst_n),	//global reset
	
	//I2C Initilize Done
	.Init_Done			(Config_Done & sdram_init_done),	//Init Done
	
	//Sensor Interface
	.CMOS_XCLK			(CMOS_XCLK),		//cmos
	.CMOS_PCLK			(CMOS_PCLK),		//25MHz
	.CMOS_iDATA			(CMOS_DB),    	//CMOS Data
	.CMOS_VSYNC			(CMOS_VSYNC),  	 	//L: Vaild
	.CMOS_HREF			(CMOS_HREF), 		//H: Vaild
	                                    
	//Ouput Sensor Data                 
	.CMOS_oCLK			(CMOS_oCLK),			//Data PCLK
	.CMOS_oDATA			(CMOS_oDATA),  	//16Bits RGB
	.CMOS_VALID			(CMOS_VALID),		//Data Enable
);

endmodule