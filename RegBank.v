`timescale 1ns / 1ps

module RegBank(
input wire [15:0] rIn,
input wire [2:0] rId,
input wire ldR,
input wire reset,
input wire clk,
output wire [15:0] rOut
);

// Decoder, anded with load instruction and clock
wire [7:0] loadRegister;
and ( loadRegister[0] , clk , ldR , ~rId[2] , ~rId[1] , ~rId[0] );
and ( loadRegister[1] , clk , ldR , ~rId[2] , ~rId[1] , rId[0] );
and ( loadRegister[2] , clk , ldR , ~rId[2] , rId[1] , ~rId[0] );
and ( loadRegister[3] , clk , ldR , ~rId[2] , rId[1] , rId[0] );
and ( loadRegister[4] , clk , ldR , rId[2] , ~rId[1] , ~rId[0] );
and ( loadRegister[5] , clk , ldR , rId[2] , ~rId[1] , rId[0] );
and ( loadRegister[6] , clk , ldR , rId[2] , rId[1] , ~rId[0] );
and ( loadRegister[7] , clk , ldR , rId[2] , rId[1] , rId[0] );

// Register output wires
wire [15:0] regData [0:7];

// General purpose Registers
R_16 r0(rIn,regData[0],reset,loadRegister[0]);
R_16 r1(rIn,regData[1],reset,loadRegister[1]);
R_16 r2(rIn,regData[2],reset,loadRegister[2]);
R_16 r3(rIn,regData[3],reset,loadRegister[3]);
R_16 r4(rIn,regData[4],reset,loadRegister[4]);
R_16 r5(rIn,regData[5],reset,loadRegister[5]);
R_16 r6(rIn,regData[6],reset,loadRegister[6]);
R_16 r7(rIn,regData[7],reset,loadRegister[7]);

// Mux array
Mux8 m0({regData[0][0],regData[1][0],regData[2][0],regData[3][0],
			regData[4][0],regData[5][0],regData[6][0],regData[7][0]},
			rId,rOut[0]);

Mux8 m1({regData[0][1],regData[1][1],regData[2][1],regData[3][1],
			regData[4][1],regData[5][1],regData[6][1],regData[7][1]},
			rId,rOut[1]);

Mux8 m2({regData[0][2],regData[1][2],regData[2][2],regData[3][2],
			regData[4][2],regData[5][2],regData[6][2],regData[7][2]},
			rId,rOut[2]);

Mux8 m3({regData[0][3],regData[1][3],regData[2][3],regData[3][3],
			regData[4][3],regData[5][3],regData[6][3],regData[7][3]},
			rId,rOut[3]);

Mux8 m4({regData[0][4],regData[1][4],regData[2][4],regData[3][4],
			regData[4][4],regData[5][4],regData[6][4],regData[7][4]},
			rId,rOut[4]);

Mux8 m5({regData[0][5],regData[1][5],regData[2][5],regData[3][5],
			regData[4][5],regData[5][5],regData[6][5],regData[7][5]},
			rId,rOut[5]);

Mux8 m6({regData[0][6],regData[1][6],regData[2][6],regData[3][6],
			regData[4][6],regData[5][6],regData[6][6],regData[7][6]},
			rId,rOut[6]);

Mux8 m7({regData[0][7],regData[1][7],regData[2][7],regData[3][7],
			regData[4][7],regData[5][7],regData[6][7],regData[7][7]},
			rId,rOut[7]);

Mux8 m8({regData[0][8],regData[1][8],regData[2][8],regData[3][8],
			regData[4][8],regData[5][8],regData[6][8],regData[7][8]},
			rId,rOut[8]);

Mux8 m9({regData[0][9],regData[1][9],regData[2][9],regData[3][9],
			regData[4][9],regData[5][9],regData[6][9],regData[7][9]},
			rId,rOut[9]);

Mux8 m10({regData[0][10],regData[1][10],regData[2][10],regData[3][10],
			regData[4][10],regData[5][10],regData[6][10],regData[7][10]},
			rId,rOut[10]);

Mux8 m11({regData[0][11],regData[1][11],regData[2][11],regData[3][11],
			regData[4][11],regData[5][11],regData[6][11],regData[7][11]},
			rId,rOut[11]);

Mux8 m12({regData[0][12],regData[1][12],regData[2][12],regData[3][12],
			regData[4][12],regData[5][12],regData[6][12],regData[7][12]},
			rId,rOut[12]);

Mux8 m13({regData[0][13],regData[1][13],regData[2][13],regData[3][13],
			regData[4][13],regData[5][13],regData[6][13],regData[7][13]},
			rId,rOut[13]);

Mux8 m14({regData[0][14],regData[1][14],regData[2][14],regData[3][14],
			regData[4][14],regData[5][14],regData[6][14],regData[7][14]},
			rId,rOut[14]);

Mux8 m15({regData[0][15],regData[1][15],regData[2][15],regData[3][15],
			regData[4][15],regData[5][15],regData[6][15],regData[7][15]},
			rId,rOut[15]);

endmodule
