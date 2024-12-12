`timescale 1ns/10ps
module bypass(Din, Dout); 
	input logic Din; 
	output logic Dout; 
	
	assign Dout = Din; 
endmodule 