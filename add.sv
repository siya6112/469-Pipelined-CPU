module add(Cout, A, B, S, Cin); 
	input logic A, B, Cin; 
	output logic Cout, S; 
	
	logic x, y, z, temp;
	
	and(x, A, B); 
	and(y, A, Cin);
	and(z, B, Cin); 
	
	or(temp, x, y); 
	
	or(Cout, temp, z); 
	
	logic temp2; 
	
	xor(temp2, A, B); 
	xor(S, temp2, Cin); 
endmodule 