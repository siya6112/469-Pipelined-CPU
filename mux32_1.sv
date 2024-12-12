`timescale 1ns/10ps
module mux32_1(Din, Dout, s);
	input logic [31:0] Din;
	input logic [4:0] s;
	output logic Dout; 
	
	logic [15:0] outSixteen; 
	logic [7:0] outEight;
	logic [3:0] outFour;
	logic [1:0] outTwo;
	
	genvar i; 
	
	generate 
		for(i = 0; i < 32; i += 2) begin : each16
			mux2_1 out16 (.d0(Din[i]), .d1(Din[i + 1]), .select(s[0]), .out(outSixteen[i / 2]));
		end
		
		for(i = 0; i < 16; i += 2) begin : each8
			mux2_1 out8 (.d0(outSixteen[i]), .d1(outSixteen[i + 1]), .select(s[1]), .out(outEight[i / 2]));
		end 
		
		for(i = 0; i < 8; i += 2) begin : each4
			mux2_1 out4 (.d0(outEight[i]), .d1(outEight[i + 1]), .select(s[2]), .out(outFour[i / 2]));
		end
		
		for(i = 0; i < 4; i += 2) begin : each2
			mux2_1 out2 (.d0(outFour[i]), .d1(outFour[i + 1]), .select(s[3]), .out(outTwo[i / 2]));
		end
		
		mux2_1 out (.d0(outTwo[0]), .d1(outTwo[1]), .select(s[4]), .out(Dout));
	endgenerate 
endmodule 