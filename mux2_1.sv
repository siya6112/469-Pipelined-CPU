`timescale 1ns/10ps
module mux2_1(d0, d1, select, out); 
	input logic d0, d1, select; 
	output logic out; 
	logic a, b, notselect; 
	
	
	not #(0.05) (notselect, select);
	and #(0.05) (a, d0, notselect);
	and #(0.05) (b, d1, select);
	or #(0.05) (out, a, b);

endmodule 