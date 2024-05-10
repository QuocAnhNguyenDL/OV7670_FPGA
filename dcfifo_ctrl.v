`timescale 1 ns / 1 ns
module dcfifo_ctrl
(
	//global clock
	input				clk_ref,		
	input 				clk_write,		
	input				clk_read,		
	input 				rst_n,			
	
	//burst length
	input		[8:0]	wr_length,		
	input		[8:0]	rd_length,		
	input				wr_load,		
	input		[21:0]	wr_addr,		
	input		[21:0]	wr_max_addr,	
	input				rd_load,		
	input		[21:0]	rd_addr,		
	input		[21:0]	rd_max_addr,	
	
	//wrfifo:  fifo 2 sdram
	input 				wrf_wrreq,		
	input		[15:0] 	wrf_din,		
	output 	reg			sdram_wr_req,	
	input 				sdram_wr_ack,	
	output		[15:0] 	sdram_din,		
	output	reg	[21:0] 	sdram_wraddr,	

	//rdfifo: sdram 2 fifo
	input 				rdf_rdreq,		
	output		[15:0] 	rdf_dout,		
	output 	reg			sdram_rd_req,	
	input 				sdram_rd_ack,	
	input		[15:0] 	sdram_dout,		
	output	reg	[21:0] 	sdram_rdaddr,	
	
	//sdram address control	
	input				sdram_init_done,	
	output	reg			frame_write_done,	
	output	reg			frame_read_done,	
	input 				data_valid
);

//------------------------------------------------
reg	sdram_wr_ackr1, sdram_wr_ackr2;	
reg sdram_rd_ackr1, sdram_rd_ackr2;
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n) 
		begin
		sdram_wr_ackr1 <= 1'b0;
		sdram_wr_ackr2 <= 1'b0;
		sdram_rd_ackr1 <= 1'b0;
		sdram_rd_ackr2 <= 1'b0;
		end
	else 
		begin
		sdram_wr_ackr1 <= sdram_wr_ack;
		sdram_wr_ackr2 <= sdram_wr_ackr1;
		sdram_rd_ackr1 <= sdram_rd_ack;
		sdram_rd_ackr2 <= sdram_rd_ackr1;		
		end
end	
wire write_done = sdram_wr_ackr2 & ~sdram_wr_ackr1;	
wire read_done = sdram_rd_ackr2 & ~sdram_rd_ackr1;	

//------------------------------------------------
reg	wr_load_r1, wr_load_r2;	
reg	rd_load_r1, rd_load_r2;	
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		wr_load_r1 <= 1'b0;
		wr_load_r2 <= 1'b0;
		rd_load_r1 <= 1'b0;
		rd_load_r2 <= 1'b0;
		end
	else
		begin
		wr_load_r1 <= wr_load;
		wr_load_r2 <= wr_load_r1;
		rd_load_r1 <= rd_load;
		rd_load_r2 <= rd_load_r1;
		end
end
wire	wr_load_flag = ~wr_load_r2 & wr_load_r1;	
wire	rd_load_flag = ~rd_load_r2 & rd_load_r1;	
//------------------------------------------------
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		sdram_wraddr <= 22'd0;	
		frame_write_done <= 1'b0;
		end			
	else if(wr_load_flag)						
		begin
		sdram_wraddr <= wr_addr;	
		frame_write_done <= 1'b0;	
		end
	else if(write_done)						
		begin
		if(sdram_wraddr < wr_max_addr - wr_length)
			begin
			sdram_wraddr <= sdram_wraddr + wr_length;
			frame_write_done <= 1'b0;
			end
		else
			begin
			sdram_wraddr <= sdram_wraddr;		
			frame_write_done <= 1'b1;
			end
		end
	else
		begin
		sdram_wraddr <= sdram_wraddr;			
		frame_write_done <= frame_write_done;
		end
end

//------------------------------------------------
always @(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)
		begin
		sdram_rdaddr <= 22'd0;
		frame_read_done <= 0;
		end
	else if(rd_load_flag)						
		begin
		sdram_rdaddr <= rd_addr;
		frame_read_done <= 0;
		end
	else if(~data_valid_r)						
		begin
		sdram_rdaddr <= rd_addr;
		frame_read_done <= 0;
		end
	else if(read_done)							
		begin
		if(sdram_rdaddr < rd_max_addr - rd_length)
			begin
			sdram_rdaddr <= sdram_rdaddr + rd_length;
			frame_read_done <= 0;
			end
		else
			begin
			sdram_rdaddr <= sdram_rdaddr;		
			frame_read_done <= 1;
			end
		end
	else
		begin
		sdram_rdaddr <= sdram_rdaddr;			
		frame_read_done <= frame_read_done;
		end
end

//------------------------------------------------
reg	data_valid_r;
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n) 
		data_valid_r <= 1'b0;
	else 
		data_valid_r <= data_valid;
end

//-------------------------------------
wire	[8:0] 	wrf_use;
wire	[8:0] 	rdf_use;
always@(posedge clk_ref or negedge rst_n)
begin
	if(!rst_n)	
		begin
		sdram_wr_req <= 0;
		sdram_rd_req <= 0;
		end
	else if(sdram_init_done == 1'b1)
		begin						
		if(wrf_use >= wr_length)	
			begin					
			sdram_wr_req <= 1;		
			sdram_rd_req <= 0;		
			end
		else if(rdf_use < rd_length && data_valid_r == 1'b1)
			begin					
			sdram_wr_req <= 0;		
			sdram_rd_req <= 1;		
			end
		else
			begin
			sdram_wr_req <= 0;		
			sdram_rd_req <= 0;		
			end
		end
	else
		begin
		sdram_wr_req <= 0;			
		sdram_rd_req <= 0;			
		end
end
//------------------------------------------------
wrfifo	u_wrfifo
(
	//input 2 fifo
	.wrclk		(clk_write),		
	.wrreq		(wrf_wrreq),		
	.data		(wrf_din),			
	//fifo 2sdram
	.rdclk		(clk_ref),			
	.rdreq		(sdram_wr_ack),		
	.q			(sdram_din),		
	//user port
	.aclr		(~rst_n),			
	.rdusedw	(wrf_use)			
);	

//------------------------------------------------
rdfifo	u_rdfifo
(
	//sdram 2 fifo
	.wrclk		(clk_ref),       	
	.wrreq		(sdram_rd_ack),  	
	.data		(sdram_dout),  		
	//fifo 2 output 
	.rdclk		(clk_read),        	
	.rdreq		(rdf_rdreq),     	
	.q			(rdf_dout),			
	//user port
	.aclr		(~rst_n | ~data_valid_r | rd_load_flag),		
	.wrusedw	(rdf_use)        	
);

endmodule
