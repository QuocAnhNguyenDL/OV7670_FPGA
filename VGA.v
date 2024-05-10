module VGA
(  	
	//global clock
	input					clk,			
	input					rst_n,     		
	
	//vga interface	
	output				vga_blank,			
	output				vga_hs,	    	
	output				vga_vs,	    		
	output	[15:0]	vga_rgb,		
	
	//user interface
	output				vga_request,	//vga data request
	output				vga_framesync,	//vga frame sync
	input		[15:0]	vga_data		//vga data
);	  


//-------------------------------------
vga_controller vga
(
	//global clock
	.clk				(clk),		
	.rst_n			(rst_n), 
	 
	 //vga interface	 
	.vga_blank		(vga_blank),
	.vga_hs			(vga_hs),		
	.vga_vs			(vga_vs),		
	.vga_rgb			(vga_rgb),	

	
	//user interface
	.vga_request	(vga_request),
	.vga_framesync	(vga_framesync),
	.vga_data		(vga_data)
);

endmodule
