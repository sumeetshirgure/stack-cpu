`timescale 1ns / 1ps

module RegBank(
input wire [15:0] rIn,
input wire [2:0] inId,
input wire [2:0] outId,
input wire ldR,
input wire reset,
output wire [15:0] rOut
);

wire [7:0] loadRegister; // 3 : 8 decoded load instruction
and ( loadRegister[0] , ldR , ~inId[2] , ~inId[1] , ~inId[0] );
and ( loadRegister[1] , ldR , ~inId[2] , ~inId[1] , inId[0] );
and ( loadRegister[2] , ldR , ~inId[2] , inId[1] , ~inId[0] );
and ( loadRegister[3] , ldR , ~inId[2] , inId[1] , inId[0] );
and ( loadRegister[4] , ldR , inId[2] , ~inId[1] , ~inId[0] );
and ( loadRegister[5] , ldR , inId[2] , ~inId[1] , inId[0] );
and ( loadRegister[6] , ldR , inId[2] , inId[1] , ~inId[0] );
and ( loadRegister[7] , ldR , inId[2] , inId[1] , inId[0] );

// Register output wires
wire [15:0] regData [0:7];

// General purpose Registers
generate
	genvar j;
	for( j = 0; j<8; j=j+1) begin : regArray
		R_16 reg_i( rIn , regData[j] , reset , loadRegister[j] );
	end
endgenerate

// Generate mux array
generate
	genvar i;
	for( i = 0; i<16; i=i+1) begin : MuxArray
		Mux8 mux_i(
			{ regData[7][i] , regData[6][i] , regData[5][i] , regData[4][i] ,
				regData[3][i] , regData[2][i] , regData[1][i] , regData[0][i] } ,
				outId ,
				rOut[i]
		);
	end
endgenerate

endmodule
