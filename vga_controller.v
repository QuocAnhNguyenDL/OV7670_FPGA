module vga_controller
(  	
	//global clock
	input			clk,			//system clock
	input			rst_n,     		//sync reset
	
	//vga interface
	output			vga_dclk,   	//vga pixel clock
	output			vga_blank,		//vga blank
	output			vga_sync,		//vga sync
	output			vga_hs,	    	//vga horizontal sync
	output			vga_vs,	    	//vga vertical sync
	output			vga_en,			//vga display enable
	output	[15:0]	vga_rgb,		//vga display data

	//user interface
	output			vga_request,	//vga data request
	output			vga_framesync,	//vga frame sync
	output	[10:0]	vga_xpos,		//vga horizontal coordinate
	output	[10:0]	vga_ypos,		//vga vertical coordinate
	input	[15:0]	vga_data		//vga data
);	 

parameter H_SYNC = 96;		parameter V_SYNC = 2;
parameter H_BACK = 48;		parameter V_BACK = 33;
parameter H_DISP = 640;		parameter V_DISP = 480;
parameter H_FRONT = 16;		parameter V_FRONT = 10;
parameter H_TOTAL = 800;	parameter V_TOTAL = 525;

reg [10:0] hcnt; 
reg [10:0] vcnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		hcnt <= 10'b0;
		vcnt <= 10'b0;
	end
	else begin
		if (hcnt == H_TOTAL - 1) begin
			hcnt <= 10'b0;
			vcnt <= (vcnt == V_TOTAL - 1) ? 10'b0 : vcnt + 1'b1;
		end
		else begin
			hcnt <= hcnt + 1'b1;
		end
	end
end

assign vga_hs = ~(hcnt < H_SYNC);
assign vga_vs = ~(vcnt < V_SYNC);

//------------------------------------------
assign	vga_dclk = ~clk;
assign	vga_blank = vga_hs & vga_vs;		
assign	vga_sync = 1'b0;
assign	vga_en		=	(hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP) &&
						(vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP) 
						? 1'b1 : 1'b0;
assign	vga_rgb 	= 	vga_en ? vga_data : 16'd0;
assign	vga_framesync = vga_vs;


//------------------------------------------
assign	vga_request	=	(hcnt >= H_SYNC + H_BACK - 1'd1 && hcnt < H_SYNC + H_BACK + H_DISP - 1'd1) &&
						(vcnt >= V_SYNC + V_BACK && vcnt < V_SYNC + V_BACK + V_DISP) 
						? 1'b1 : 1'b0;
assign	vga_xpos	= 	vga_request ? (hcnt - (H_SYNC + H_BACK - 1'b1)) : 11'd0;
assign	vga_ypos	= 	vga_request ? (vcnt - (V_SYNC + V_BACK - 1'b1)) : 11'd0;		

endmodule
