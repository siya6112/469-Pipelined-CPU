`timescale 1ns/10ps
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out); 
	input logic [63:0] A, B; 
	input logic [2:0] cntrl; 
	output logic [63:0] result; 
	output logic negative, zero, overflow, carry_out; 
	
	logic [63:0] outBP, outAdd, outSub, outAnd, outOr, outXor, temp1, temp2;
	logic [63:0] tempCoutAdd, tempCoutSub;
	logic overflowAdd, overflowSub; 
	
	// running the alu for the first input bit 
	bypass equal1 (.Din(B[0]), .Dout(outBP[0]));
	add adding1 (.Cout(tempCoutAdd[0]), .A(A[0]), .B(B[0]), .S(outAdd[0]), .Cin(1'b0));
	sub subtracting1 (.Cout(tempCoutSub[0]), .A(A[0]), .B(B[0]), .S(outSub[0]), .Cin(1'b1));
	and #(0.05) (outAnd[0], A[0], B[0]);
	or  #(0.05) (outOr[0], A[0], B[0]); 
	xor  #(0.05) (outXor[0], A[0], B[0]);
	
	
	mux8_1 control1 (.cntrl, .outBP(outBP[0]), .outAdd(outAdd[0]), .outSub(outSub[0]), .outAnd(outAnd[0]), .outOr(outOr[0]), .outXor(outXor[0]), .temp1(temp1[0]), .temp2(temp2[0]), .Dout(result[0]));
	
	// running alu for every other bit except the first and last 
	genvar i; 
	generate
		for(i = 1; i < 64; i++) begin : eachInputBit
		
			bypass equal (.Din(B[i]), .Dout(outBP[i]));
			add adding (.Cout(tempCoutAdd[i]), .A(A[i]), .B(B[i]), .S(outAdd[i]), .Cin(tempCoutAdd[i - 1]));
			sub subtracting (.Cout(tempCoutSub[i]), .A(A[i]), .B(B[i]), .S(outSub[i]), .Cin(tempCoutSub[i - 1]));
			and #(0.05) (outAnd[i], A[i], B[i]);
			or #(0.05) (outOr[i], A[i], B[i]); 
			xor #(0.05) (outXor[i], A[i], B[i]);
			
			
			mux8_1 control (.cntrl, .outBP(outBP[i]), .outAdd(outAdd[i]), .outSub(outSub[i]), .outAnd(outAnd[i]), .outOr(outOr[i]), .outXor(outXor[i]), .temp1(temp1[i]), .temp2(temp2[i]), .Dout(result[i]));
	
	
		end
	endgenerate
	
	
//	// running alu for the last bit 
//	bypass equal1 (.Din(B[63]), .Dout(outBP[63]));
//	add adding1 (.Cout(tempCoutAdd[63]), .A(A[63]), .B(B[63]), .S(outAdd[63]), .Cin(tempCoutAdd[62]));
//	sub subtracting1 (.Cout(tempCoutSub[63]), .A(A[63]), .B(B[63]), .S(outSub[63]), .Cin(tempCoutSub[62]));
//	and (outAnd[63], A[63], B[63]);
//	or (outOr[63], A[63], B[63]); 
//	xor (outXor[63], A[63], B[63]);
//	
//	
//	mux8_1 control1 (.cntrl, .outBP(outBP[63])), .outAdd(outAdd[63]), .outSub(outSub[63]), .outAnd(outAnd[63]), .outOr(outOr[63]), .outXor(outXor[0]), .temp1(temp1[63]), .temp2(temp2[63]), .Dout(result[63]));
//	
	
	//setting the flags 
	mux2_1 cout (.d0(tempCoutAdd[63]), .d1(tempCoutSub[63]), .select(cntrl[0]), .out(carry_out));
	
	xor #(0.05) (overflowAdd, tempCoutAdd[63], tempCoutAdd[62]); 
	xor #(0.05) (overflowSub, tempCoutSub[63], tempCoutSub[62]); 
	
	mux2_1 Oflow (.d0(overflowAdd), .d1(overflowSub), .select(cntrl[0]), .out(overflow));
	
	flag0 set0 (.result, .zero); 
	
	assign negative = result[63]; 
	
	
endmodule 