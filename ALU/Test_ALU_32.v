`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:28:13 08/19/2017
// Design Name:   ALU_32
// Module Name:   /home/sumeet/Documents/IITKGP/COA/GenericALU/Test_ALU_32.v
// Project Name:  GenericALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU_32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Test_ALU_32;


// Operation codes
parameter ADD = 0;//12'b000000000001;//0
parameter SUB = 1;//12'b000000000010;//1
parameter INX = 2;//12'b000000000100;//2
parameter DCX = 3;//12'b000000001000;//3

parameter CPX = 4;//12'b000000010000;//4
parameter SHL = 5;//12'b000000100000;//5
parameter SHR = 6;//12'b000001000000;//6
parameter SRA = 7;//12'b000010000000;//7

parameter AND = 8;//12'b000100000000;//8
parameter OR  = 9;//12'b001000000000;//9
parameter XOR =10;//12'b010000000000;//10
parameter NOT =11;//12'b100000000000;//11

// Flag codes
parameter ZF = 0;//2'b01 // Zero flag
parameter SF = 1;//2'b10 // Sign flag
parameter OF = 2;//2'b10 // Overflow flag
parameter CF = 3;//2'b10 // Carry flag

	// Inputs
	reg [31:0] x;
	reg [31:0] y;
	reg [11:0] OpCode;

	// Outputs
	wire [3:0] Flags;
	wire [31:0] z;

	// Instantiate the Unit Under Test (UUT)
	ALU_32 uut (
		.x(x), 
		.y(y), 
		.OpCode(OpCode), 
		.Flags(Flags), 
		.z(z)
	);

	initial begin
		OpCode = 0;
		
		// Initialize Inputs
		x = 32'b10010000000000000000000110000000;
		y = 32'b00000100000000000000000101000000;
		
		OpCode[ADD] = 1;#20;OpCode[ADD] = 0;#20;
		OpCode[SUB] = 1;#20;OpCode[SUB] = 0;#20;
		OpCode[INX] = 1;#20;OpCode[INX] = 0;#20;
		OpCode[DCX] = 1;#20;OpCode[DCX] = 0;#20;
		
		OpCode[CPX] = 1;#20;OpCode[CPX] = 0;#20;
		OpCode[SHL] = 1;#20;OpCode[SHL] = 0;#20;
		OpCode[SHR] = 1;#20;OpCode[SHR] = 0;#20;
		OpCode[SRA] = 1;#20;OpCode[SRA] = 0;#20;
		
		OpCode[AND] = 1;#20;OpCode[AND] = 0;#20;
		OpCode[OR] = 1;#20;OpCode[OR] = 0;#20;
		OpCode[XOR] = 1;#20;OpCode[XOR] = 0;#20;
		OpCode[NOT] = 1;#20;OpCode[NOT] = 0;#20;
		
		// Wait 100 ns for global reset to finish
		#100;
		
		// Add stimulus here

	end

      
endmodule

