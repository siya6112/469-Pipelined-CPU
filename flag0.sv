`timescale 1ns/10ps
module flag0(result, zero); 
	input logic [63:0] result; 
	output logic zero; 
	
	logic [15:0] sixteen; 
	logic [3:0] four; 
	logic temp0;
	
	genvar i; 
	generate 
		for(i = 0; i < 64; i += 4) begin : each16or
			or #(0.05) (sixteen[i / 4], result[i], result[i + 1], result[i + 2], result[i + 3]); 
		end
		
		for(i = 0; i < 16; i += 4) begin : each4or
			or #(0.05) (four[i / 4], sixteen[i], sixteen[i + 1], sixteen[i + 2], sixteen[i + 3]);
		end 
		
		or #(0.05) (temp0, four[0], four[1], four[2], four[3]); 
	endgenerate 
	
	not #(0.05) (zero, temp0); 

endmodule 