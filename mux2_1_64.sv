`timescale 1ns/10ps
module mux2_1_64(d0, d1, select, out); 
	input logic [63:0] d0, d1; 
	input logic select; 
	output logic [63:0] out;
	
	logic [63:0] a, b; 
	logic notselect; 
	
	not #(0.05) (notselect, select);
	
	genvar i; 
	
	generate
		for(i = 0; i < 64; i++) begin : eachgate
			and #(0.05) (a[i], d0[i], notselect);
			and #(0.05) (b[i], d1[i], select);
			or #(0.05) (out[i], a[i], b[i]);
		end 
	endgenerate
endmodule 