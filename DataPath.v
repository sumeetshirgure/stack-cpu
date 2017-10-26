`timescale 1ns / 1ps

module DataPath(
input wire clk,
input wire reset,
input wire [8:0] LoadSignal,
input wire [5:0] TransferSignal,
input wire [2:0] ALOP,
input wire [15:0] DataIn,
output wire [15:0] AddrOut,
output wire [15:0] DataOut,
output wire [15:0] Instruction,
output wire Status
);

/* Constants */
// Load signal ids
parameter ldR = 0 ;   // GPR Array
parameter ldPC = 1 ;  // Program counter
parameter ldSP = 2 ;  // Stack pointer
parameter ldF = 3;    // Flag register
parameter ldT = 4;    // Temporary register
parameter ldMAR = 5;  // Memory address register
parameter ldMDM = 6;  // Memory data register (from main memory)
parameter ldMDZ = 7;  // Memory data register (from internal Z bus)
parameter ldIR = 8;   // Instruction register

// Transfer signal ids
parameter trR =  0;
parameter trPC = 1;
parameter trSP = 2;
parameter trMAR= 3;
parameter trMDR= 4;
parameter trL  = 5;

/* Data elements */
// Internal buses
wire [15:0] X;
wire [15:0] Z;

// Program counter
wire [15:0] PC_out;
wire loadPC ;
and(loadPC, clk, LoadSignal[ldPC]);
R_16 PC(Z,PC_out,reset,loadPC);
TransferSwitch transferPC( TransferSignal[trPC] , PC_out , X );

// Stack pointer
wire [15:0] SP_out;
wire loadSP ;
and(loadSP, clk, LoadSignal[ldSP]);
R_16 SP(Z,SP_out,reset,loadSP);
TransferSwitch transferSP( TransferSignal[trSP] , SP_out , X );

// Memory address register
wire loadMAR;
and(loadMAR, clk, LoadSignal[ldMAR]);
R_16 MAR(Z,AddrOut,reset,loadMAR);
TransferSwitch transferMAR( TransferSignal[trMAR] , AddrOut , X );

// Memory data register
wire [15:0] MDR_in;
wire loadMDR , temp;
or( temp , LoadSignal[ldMDZ] , LoadSignal[ldMDM] );
and( loadMDR , clk , temp );
TransferSwitch transferMDZ( LoadSignal[ldMDZ] , Z , MDR_in );
TransferSwitch transferMDM( LoadSignal[ldMDM] , DataIn , MDR_in );
R_16 MDR(MDR_in , DataOut , reset , loadMDR);
TransferSwitch transferMDR( TransferSignal[trMDR] , DataOut , X );

// Instruction register
wire loadIR;
and( loadIR , clk , LoadSignal[ldIR] );
R_16 IR( DataIn , Instruction , reset , loadIR );

wire [15:0] L; // Lower 12 bits of IR sign-extended to 16 bits, to get label
assign L = {Instruction[11],Instruction[11],Instruction[11],Instruction[11],Instruction[11:0]};
TransferSwitch transferL( TransferSignal[trL] , L , X );

wire [2:0] rId;
assign rId = Instruction[6:4];
wire [15:0] R_out;
wire loadR ;
and( loadR , LoadSignal[ldR] , clk );
RegBank regBank( Z , rId , loadR , reset , R_out );
TransferSwitch transferR( TransferSignal[trR] , R_out , X );

// Temporary register
wire [15:0] Y;
wire loadT;
and( loadT ,  LoadSignal[ldT] , clk );
R_16 T( X , Y , reset , loadT );

// ALU
wire [3:0] alu_flag_out;
ALU alu(X,Y,ALOP,alu_flag_out,Z);

// Flag register
wire [3:0] flags;
wire loadFlags;
and( loadFlags , LoadSignal[ldF] , clk );
Flag_Reg flagReg( alu_flag_out , flags , reset , loadFlags );

// Flag selector circuit
wire [2:0] cc;
wire stat;
assign cc = Instruction[14:12];
Mux4 flagSelect( flags , cc[2:1] , stat );
xor( Status , stat , cc[0] );

endmodule
