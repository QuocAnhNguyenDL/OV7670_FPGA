module Filter
(
	input[15:0] VGAD,
	input [1:0] select,
	
	output reg[9:0] R,
	output reg[9:0] G,
	output reg[9:0] B
);

localparam grayscale_filer = 2'b01;
localparam negative_filter = 2'b10;

wire [5:0] avg = (VGAD[15:11] + VGAD[10:5] + VGAD[4:0])/3;

always @(*)
begin
	
	if(select == grayscale_filer)
	begin
		R = {avg,4'b0000};		
		G = {avg,4'b0000};
		B = {avg,4'b0000};
	end
	
	else if(select == negative_filter)
	begin
		R = 1023 - {VGAD[15:11],5'b00000};		
		G = 1023 - {VGAD[10:5],4'b0000};
		B = 1023 - {VGAD[4:0],5'b00000};
	end
	
	else
	begin
		R = {VGAD[15:11],5'b00000};		
		G = {VGAD[10:5],4'b0000};
		B = {VGAD[4:0],5'b00000};
	end
end

endmodule