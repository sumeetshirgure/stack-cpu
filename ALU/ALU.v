`timescale 1ns / 1ps

module ALU(
input wire[15:0] x,
input wire[15:0] y,
input wire[2:0] ALOP,
output wire[3:0] Flags,
output wire[15:0]z
);

wire[7:0] OpCode;

// Operation codes
parameter ADD  = 1;
parameter NEGY = 2;
parameter OR   = 3;
parameter NOTY = 4;
parameter CPX =  5;
parameter INX =  6;
parameter DCX =  7;
parameter CPY =  0;

assign OpCode[ADD]  = (ALOP == ADD);
assign OpCode[NEGY] = (ALOP == NEGY);
assign OpCode[OR]   = (ALOP == OR);
assign OpCode[NOTY] = (ALOP == NOTY);
assign OpCode[CPX]  = (ALOP == CPX);
assign OpCode[INX]  = (ALOP == INX);
assign OpCode[DCX]  = (ALOP == DCX);
assign OpCode[CPY]  = (ALOP == CPY);

// Flag codes
parameter SF = 0; // Sign flag
parameter CF = 1; // Carry flag
parameter ZF = 2; // Zero flag
parameter OF = 3; // Overflow flag

/*Arithmetic functions*/
wire Cin,Sub,Overflow,Carry;
wire [15:0]z_Ar;
wire [15:0]yy;
wire [15:0]xx;
or(Cin , OpCode[INX], OpCode[DCX]);
or(Sub , OpCode[NEGY], OpCode[DCX]);
assign yy = Cin ? 0 : y;
assign xx = OpCode[NEGY] ? 0 : x;
Add_Sub add_sub(xx,yy,Cin,Sub,z_Ar,Overflow,Carry);
/**********************/

/*Logic functions*/
wire [15:0] z_Lg;
assign z_Lg = (OpCode[OR] ? (x|y) : ~y  );
/*****************/

/*Copy Function*/
wire [15:0] z_Sh;
assign z_Sh[15:0] = (OpCode[CPX] ? x[15:0] : y[15:0] );

/*****************/

wire Op_Ar , Op_Lg, Op_Sh;
or(Op_Ar , OpCode[ADD] , OpCode[NEGY] , OpCode[INX] , OpCode[DCX]);//arithmetic
or(Op_Lg , OpCode[OR] , OpCode[NOTY]);//logic
or(Op_Sh , OpCode[CPY] , OpCode[CPX]);//copy

assign z = (Op_Ar ? z_Ar : (Op_Lg ? z_Lg : (Op_Sh ? z_Sh : 0) ) );

assign Flags[ZF] = (z == 0);
assign Flags[SF] = z[15];
assign Flags[OF] = Op_Ar ? Overflow : 0;
assign Flags[CF] = Op_Ar ? Carry : 0;

endmodule
