`timescale 1ns/10ps
module sub(Cout, A, B, S, Cin); 
	input logic A, B, Cin; 
	output logic Cout, S; 
	
	logic x, y, z, temp, NB;
	
	not #(0.05) (NB, B); 
	
	and #(0.05) (x, A, NB); 
	and #(0.05) (y, A, Cin);
	and #(0.05) (z, NB, Cin); 
	
	or #(0.05) (temp, x, y); 
	
	or #(0.05) (Cout, temp, z); 
	
	logic temp2; 
	
	xor #(0.05) (temp2, A, NB); 
	xor #(0.05) (S, temp2, Cin);

endmodule 