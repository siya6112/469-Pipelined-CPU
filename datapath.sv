`timescale 1ns/10ps
module datapath(
	input logic clk, reset,
	input logic [31:0] instruction,
	input logic Reg2Loc, ALUsrc, MemToReg, RegWrite, MemWrite, shift, direction, math, srcType, fwd_math,
	input logic [1:0] fwdr1, fwdr2,
	input logic [2:0] ALUop,
	output logic negative, zero, overflow, carry_out, zero_br, 
	output logic [4:0] Rd_e, Rd_m, Rd_r, Rm_r,
	output logic [4:0] Ab, Rn_r
	);
	
	logic [4:0] Rd;
	logic [11:0] Imm12;
	logic [5:0] shamt_r;
	logic [8:0] Imm9; 

	assign Rd = instruction[4:0];
	assign Rn_r = instruction[9:5]; 
	assign Rm_r = instruction[20:16];  
	
	assign Imm12 = instruction[21:10];
	assign Imm9 = instruction[20:12]; 
	assign shamt_r = instruction[15:10];
	
	logic [63:0] Da, Db, Dw, tempI, tempALU, result, Dout, tempMem, mult_low, mult_high, shifted, tempMath, result_e;
//	logic [4:0] Ab;
	
	logic RegWrite_e, RegWrite_r; 
	logic ALUsrc_e, MemWrite_e, MemToReg_e, shift_e, direction_e, math_e, fwd_math_e; 
	logic [2:0] ALUop_e; 
	
	logic [4:0] Rn_e, Rm_e;
	logic [5:0] shamt_e;
	
	logic [63:0] Da_e, Db_e, tempI_e, Dw_r;
	
	logic [63:0] fwd_Da, fwd_Db;
	
	
	
	// REGISTER STAGE : 
	
	// creating regfile 
	mux2_1_5 chooseReg (.d0(Rd), .d1(Rm_r), .select(Reg2Loc), .out(Ab));
	regfile registers (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw_r), .ReadRegister1(Rn_r), .ReadRegister2(Ab), .WriteRegister(Rd_r), .RegWrite(RegWrite_r), .clk);
	
	// creating mux with srctype for Itypes 
	mux2_1_64 ifItype (.d0({{55{Imm9[8]}}, Imm9}), .d1({52'b0, Imm12}), .select(srcType), .out(tempI)); 
	
	// PIP - ex cntrl signals: 
	D_FF pip_src (.q(ALUsrc_e), .d(ALUsrc), .reset, .clk);
	D_FF pip_memw (.q(MemWrite_e), .d(MemWrite), .reset, .clk);
	D_FF pip_mem2r (.q(MemToReg_e), .d(MemToReg), .reset, .clk);
	D_FF pip_shift (.q(shift_e), .d(shift), .reset, .clk);
	D_FF pip_dir (.q(direction_e), .d(direction), .reset, .clk);
	D_FF pip_math (.q(math_e), .d(math), .reset, .clk);
	D_FF pip_regw (.q(RegWrite_e), .d(RegWrite), .reset, .clk);
	D_FF pip_fwdMath (.q(fwd_math_e), .d(fwd_math), .reset, .clk);
	
	genvar i; 
	generate 
		// PIP - ex operator 
		for(i = 0; i < 3; i++) begin : eachALUopbit
			D_FF pip_ALUop (.q(ALUop_e[i]), .d(ALUop[i]), .reset, .clk);
		end
		
		// PIP - ex read regs 
		for(i = 0; i < 5; i++) begin : eachregbit1
			D_FF pip_wreg (.q(Rd_e[i]), .d(Rd[i]), .reset, .clk);
			D_FF pip_r1reg (.q(Rn_e[i]), .d(Rn_r[i]), .reset, .clk);
			D_FF pip_r2reg (.q(Rm_e[i]), .d(Ab[i]), .reset, .clk);
		end 
		
		// PIP - ex shamt 
		for(i = 0; i < 6; i++) begin : eachshamtbit
			D_FF pip_r1reg (.q(shamt_e[i]), .d(shamt_r[i]), .reset, .clk);
		end 
		
		// FWD from ex, mem & wr
		for (i = 0; i < 64; i++) begin : eachfwdbit
			mux4_1 fwdDa (.s0(fwdr1[0]), .s1(fwdr1[1]), .i0(Da[i]), .i1(result_e[i]), .i2(Dw[i]), .i3(Dw_r[i]), .out(fwd_Da[i]));
			mux4_1 fwdDb (.s0(fwdr2[0]), .s1(fwdr2[1]), .i0(Db[i]), .i1(result_e[i]), .i2(Dw[i]), .i3(Dw_r[i]), .out(fwd_Db[i]));
		end 
	endgenerate
	
	// PIP to ex - reg outputs 
	register regDa (.WriteData(fwd_Da), .regEnable(1'b1), .dataOut(Da_e), .clk);
	register regDb (.WriteData(fwd_Db), .regEnable(1'b1), .dataOut(Db_e), .clk);
	register regtempI (.WriteData(tempI), .regEnable(1'b1), .dataOut(tempI_e), .clk);
	
	// Raise zero flag in case of CBZ
	flag0 incase_cbz (.result(fwd_Db), .zero(zero_br)); 
	
	
	
	
	
	
	
	
	
	
	
	
	logic RegWrite_m; 
	logic MemWrite_m, MemToReg_m, shift_m, math_m, neg_e, zero_e, over_e, carryO_e;
	logic [4:0] Rm_m, Rn_m;
	logic [63:0] Db_m, mult_low_m, mult_high_m, shifted_m, result_m, tempMath_m;
	
	// EXECUTE STAGE : 
	
	// creating mux with ALUsrc for second ALU input 
	mux2_1_64 src (.d0(Db_e), .d1(tempI_e), .select(ALUsrc_e), .out(tempALU)); 
	
	// creating alu that computes add, sub, bypass
//	alu compute (.A(Da_e), .B(tempALU), .cntrl(ALUop_e), .result, .negative(neg_e), .zero(zero_e), .overflow(over_e), .carry_out(carryO_e)); 
	
	alu compute (.A(Da_e), .B(tempALU), .cntrl(ALUop_e), .result, .negative, .zero, .overflow, .carry_out); 
	
	// creating multiplier for MUL
	mult x (.A(Da_e), .B(Db_e), .doSigned(1'b1), .mult_low, .mult_high); 
	
	// creating a shifter for LSL and LSR
	shifter sh (.value(Da_e), .direction(direction_e), .distance(shamt_e), .result(shifted));
	
	// created a mux to select between shifted value or multiplied value 
	mux2_1_64 mult_shift (.d0(mult_low), .d1(shifted), .select(shift_e), .out(tempMath));
	
	// choosing output from math/alu
	mux2_1_64 math_alu (.d0(result), .d1(tempMath), .select(fwd_math_e), .out(result_e));
	
	
	// PIP - mem cntrl signals:
	D_FF pip_memw2 (.q(MemWrite_m), .d(MemWrite_e), .reset, .clk);
	D_FF pip_mem2r2 (.q(MemToReg_m), .d(MemToReg_e), .reset, .clk);
//	D_FF pip_shift2 (.q(shift_m), .d(shift_e), .reset, .clk);
	D_FF pip_math2 (.q(math_m), .d(math_e), .reset, .clk);
	D_FF pip_regw2 (.q(RegWrite_m), .d(RegWrite_e), .reset, .clk);
	
//	// PIP - flags from ALU 
//	D_FF pip_neg (.q(negative), .d(neg_e), .reset, .clk);
//	D_FF pip_zero (.q(zero), .d(zero_e), .reset, .clk);
//	D_FF pip_over (.q(overflow), .d(over_e), .reset, .clk);
//	D_FF pip_carryO (.q(carry_out), .d(carryO_e), .reset, .clk);
	
	genvar j; 
	generate
		// PIP - mem read regs 
		for(j = 0; j < 5; j++) begin : eachregbit2
			D_FF pip_wreg2 (.q(Rd_m[j]), .d(Rd_e[j]), .reset, .clk);
			D_FF pip_r1reg2 (.q(Rn_m[j]), .d(Rn_e[j]), .reset, .clk);
			D_FF pip_r2reg2 (.q(Rm_m[j]), .d(Rm_e[j]), .reset, .clk);
		end
	endgenerate
	
	// PIP to mem - ex outputs 
	register xDb2 (.WriteData(Db_e), .regEnable(1'b1), .dataOut(Db_m), .clk);
	register xmultlow (.WriteData(mult_low), .regEnable(1'b1), .dataOut(mult_low_m), .clk);
	register xmulthigh (.WriteData(mult_high), .regEnable(1'b1), .dataOut(mult_high_m), .clk);
	register xshifted (.WriteData(shifted), .regEnable(1'b1), .dataOut(shifted_m), .clk);
	register xresult (.WriteData(result), .regEnable(1'b1), .dataOut(result_m), .clk);
	register xtempMath (.WriteData(tempMath), .regEnable(1'b1), .dataOut(tempMath_m), .clk);
	
	
	
	
	
	
	
	
	
	
	logic [4:0] Rm_w, Rn_w; 
	
	// MEMORY STAGE : 
	
	// creating data memory for load and store 
	datamem memory (.address(result_m), .write_enable(MemWrite_m), .read_enable(1'b1), .write_data(Db_m), .clk, .xfer_size(4'd8), .read_data(Dout)); 
	
	// creating mux to store output from either alu or memory 
	mux2_1_64 MemReg (.d0(result_m), .d1(Dout), .select(MemToReg_m), .out(tempMem)); 
	
//	// created a mux to select between shifted value or multiplied value 
//	mux2_1_64 mult_shift (.d0(mult_low_m), .d1(shifted_m), .select(shift_m), .out(tempMath));
	
	// creating the last mux to write back the data from either the ALU or the math.sv to the regfile
	mux2_1_64 lastmux (.d0(tempMem), .d1(tempMath_m), .select(math_m), .out(Dw));
	
	// PIP - wr cntrl signals 
	D_FF pip_regw3 (.q(RegWrite_r), .d(RegWrite_m), .reset, .clk);
	
	genvar k; 
	generate
		// PIP - mem read regs 
		for(k = 0; k < 5; k++) begin : eachregbit3
			D_FF pip_wreg2 (.q(Rd_r[k]), .d(Rd_m[k]), .reset, .clk);
			D_FF pip_r1reg3 (.q(Rn_w[k]), .d(Rn_m[k]), .reset, .clk);
			D_FF pip_r2reg3 (.q(Rm_w[k]), .d(Rm_m[k]), .reset, .clk);
		end
		
	endgenerate








	// WRITE BACK - data : 	
	register wdata (.WriteData(Dw), .regEnable(1'b1), .dataOut(Dw_r), .clk);
	
endmodule 