`timescale 1ns/10ps
module datapathPC(clk, reset, instruction, pcVal, BrTaken, UncondBr); 
	input clk, reset, BrTaken, UncondBr;
	input	[31:0] instruction;
	output [63:0] pcVal;
	
	logic [63:0] nextPC, shift2, nextPC1, nextPC0, pcVal_br;
	logic negative1, zero1, overflow1, carry_out1;
	logic negative0, zero0, overflow0, carry_out0;

	// PC LOGIC AND FETCHING INSTRUCIONS: 
	
	// SignExtend CondAddr19 and BrAddr26 and select either one with selector as UncondBr. 
	mux2_1_64 signExt (.d0({{45{instruction[23]}}, instruction[23:5]}), .d1({{38{instruction[25]}}, instruction[25:0]}), .select(UncondBr), .out(shift2));
	
	// clocking the previous PC
	
	register incase_br (.WriteData(pcVal), .regEnable(1'b1), .dataOut(pcVal_br), .clk);
	
	// Get Adder output for PC = PC + SE(Br) * 4 -----> Save it into nextPC1
	alu PCnextBr (.A(pcVal_br), .B({shift2[61:0], 2'b00}), .cntrl(3'b010), .result(nextPC1), .negative(negative1), .zero(zero1), .overflow(overflow1), .carry_out(carry_out1)); 
	
	// Get Adder output for PC = PC + 4 ----> Save to into nextPC0
	alu PCnext4 (.A(pcVal), .B(64'd4), .cntrl(3'b010), .result(nextPC0), .negative(negative0), .zero(zero0), .overflow(overflow0), .carry_out(carry_out0)); 
	
	// Select between nextPC1 and nextPC0 depending on BrTaken signal ----> whether branch is taken or not
	mux2_1_64 assignPCnext (.d0(nextPC0), .d1(nextPC1), .select(BrTaken), .out(nextPC));  
//	
//	// maintain nextPC if it is a branch type intruction 
//	
//	register PC_delay (.WriteData(nextPC), .regEnable(delay), .dataOut(pcVal), .clk);
	
	// Initiate PC as 0 nextPC based on reset
	genvar i; 
	generate 
		for(i = 0; i < 64; i++) begin : eachFlip
			D_FF flipPC (.q(pcVal[i]), .d(nextPC[i]), .reset, .clk);
		end
	endgenerate 
endmodule 