`timescale 1ns/10ps
module mux8_1 (cntrl, outBP, outAdd, outSub, outAnd, outOr, outXor, temp1, temp2, Dout);
	input logic [2:0] cntrl; 
	input logic outBP, outAdd, outSub, outAnd, outOr, outXor, temp1, temp2;
	output logic Dout; 
	
	logic out1, out2; 
	
	mux4_1 firsthalf (.s0(cntrl[0]), .s1(cntrl[1]), .i0(outBP), .i1(temp1), .i2(outAdd), .i3(outSub), .out(out1));
	mux4_1 secondhalf (.s0(cntrl[0]), .s1(cntrl[1]), .i0(outAnd), .i1(outOr), .i2(outXor), .i3(temp2), .out(out2));
	
	mux2_1 finalResult (.d0(out1), .d1(out2), .select(cntrl[2]), .out(Dout));

endmodule 