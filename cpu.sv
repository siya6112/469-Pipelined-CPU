`timescale 1ns/10ps
module cpu(clk, reset);
	input logic clk, reset;
	
	logic [31:0] instruction, pip_instruction, instruction_temp;
	logic [63:0] pcVal, pc_val_pip;
	logic Reg2Loc, ALUsrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, shift, direction, math, srcType, BrTaken_f, UncondBr_f;
	logic [1:0] fwdr1, fwdr2;
	logic [2:0] ALUop;
	logic negative, zero, overflow, carry_out, zero_br, fwd_math; 
	logic [4:0] Rd_e, Rn_r, Rd_m, Rd_r, Ab, Rm_r; 
	
//	logic Reg2Loc_f, ALUsrc_f, MemToReg_f, RegWrite_f, MemWrite_f, shift_f, direction_f, math_f, srcType_f, fwdr1_f;
//	logic [2:0] ALUop_f;
	
	// Delaying branch signals 
	
//	D_FF BrTakenDel (.q(BrTaken_f), .d(BrTaken), .reset, .clk);
//	D_FF UncondBrDel (.q(UncondBr_f), .d(UncondBr), .reset, .clk);
	
	// Fetch PC (64-bit addr)
	
	datapathPC getPC (.clk, .reset, .instruction(pip_instruction), .pcVal, .BrTaken, .UncondBr); 
	
//	// PIPLINING - Instruction 
//	register pipInstr (.WriteData(pcVal), .regEnable(1), .dataOut(pc_val_pip), .clk);
	
	// Fetch instruction based on PC
	instructmem getInstr (.address(pcVal), .instruction, .clk);
	
	genvar i; 
	generate 
		for (i = 0; i < 32; i++) begin : eachInstrPip
			D_FF InstrPip (.q(pip_instruction[i]), .d(instruction[i]), .reset, .clk);
//			mux2_1 chooseInstr (.d0(pip_instruction[i]), .d1(instruction_temp[i]), .select(BrTaken_f), .out(instruction[i]));
		end
	endgenerate 
	
//	// Set the control logic for each instruction 
//	
//	control cntrl (.clk, .instruction, .Reg2Loc(Reg2Loc_f), .ALUsrc(ALUsrc_f), .MemToReg(MemToReg_f), .RegWrite(RegWrite_f), .MemWrite(MemWrite_f), .BrTaken, .UncondBr, .ALUop(ALUop_f), .shift(shift_f), .direction(direction_f), .math(math_f), .srcType(srcType_f), .negative, .zero, .overflow, .carry_out, .fwdr1, .Rd_e, .Rn_r, .Rd_m, .Rd_r, .fwdr2, .Rm_r, .delay);
	control cntrl (.clk, .instruction(pip_instruction), .Reg2Loc, .ALUsrc, .MemToReg, .RegWrite, .MemWrite, .BrTaken, .UncondBr, .ALUop, .shift, .direction, .math, .srcType, .negative, .zero, .overflow, .carry_out, .fwdr1, .Rd_e, .Rn_r, .Rd_m, .Rd_r, .fwdr2, .Ab, .zero_br, .Rm_r, .fwd_math);
//	
//	// pipeline ALL cntrl signals going into the datapath 
//	
//	D_FF pip_r2l (.q(Reg2Loc), .d(Reg2Loc_f), .reset, .clk);
//	D_FF pip_alusrc (.q(ALUsrc), .d(ALUsrc_f), .reset, .clk);
//	D_FF pip_m2r (.q(MemToReg), .d(MemToReg_f), .reset, .clk);
//	D_FF pip_regwr (.q(RegWrite), .d(RegWrite_f), .reset, .clk);
//	D_FF pip_memwr (.q(MemWrite), .d(MemWrite_f), .reset, .clk);
//	D_FF pip_shift (.q(shift), .d(shift_f), .reset, .clk);
//	D_FF pip_dir (.q(direction), .d(direction_f), .reset, .clk);
//	D_FF pip_math (.q(math), .d(math_f), .reset, .clk);
//	D_FF pip_srctype (.q(srcType), .d(srcType_f), .reset, .clk);
////	D_FF pip_fwdr1 (.q(fwdr1), .d(fwdr1_f), .reset, .clk);
	
//	genvar f; 
//	generate 
//		for(f = 0; f < 3; f++) begin : eachaluopbit
//			D_FF pip_aluOp (.q(ALUop[f]), .d(ALUop_f[f]), .reset, .clk); 
//		end
//	endgenerate 
	
	// Set the datapath logic for each instruction 
	
	datapath data (.clk, .reset, .instruction(pip_instruction), .Reg2Loc, .ALUsrc, .MemToReg, .RegWrite, .MemWrite, .ALUop, .shift, .direction, .math, .srcType, .negative, .zero, .overflow, .carry_out, .Rd_e, .Rn_r, .fwdr1, .Rd_m, .Rd_r, .Ab, .fwdr2, .zero_br, .Rm_r, .fwd_math); 
endmodule 