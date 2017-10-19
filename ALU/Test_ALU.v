`timescale 1ns / 1ps

module Test_ALU;

	// Operation codes
	parameter ADD  = 1;
	parameter NEGY = 2;
	parameter OR   = 3;
	parameter NOTY = 4;
	parameter CPX =  5;
	parameter INX =  6;
	parameter DCX =  7;
	parameter CPY =  0;
	// Flag codes
	parameter SF = 0;//2'b00 // Sign flag
	parameter CF = 1;//2'b01 // Carry flag
	parameter ZF = 2;//2'b10 // Zero flag
	parameter OF = 3;//2'b11 // Overflow flag
	// Inputs
	reg [15:0] x;
	reg [15:0] y;
	reg [2:0] ALOP;
	// Outputs
	wire [3:0] Flags;
	wire [15:0] z;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.x(x), 
		.y(y), 
		.ALOP(ALOP), 
		.Flags(Flags), 
		.z(z)
	);

	initial begin
		// Initialize Inputs
		y = 16'b0011100110010111;
		x = 16'b0000010010110000;
		ALOP = ADD; #40;
		ALOP = NEGY; #40;
		ALOP = OR; #40;
		ALOP = NOTY; #40;		
		ALOP = CPX; #40;
		ALOP = INX; #40;
		ALOP = DCX; #40;
		ALOP = CPY; #40;
		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
	end
endmodule

