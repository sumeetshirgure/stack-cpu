`timescale 1ns / 1ps

module Test;

	// Main memory
	reg [15:0] RAM [0:65535];
	wire RD;
	wire WR;
	reg [15:0] DataIn; // To datapath
	wire [15:0] AddrOut;// From datapath
	wire [15:0] DataOut;// From datapath

	always @(posedge RD) begin
		DataIn = RAM[AddrOut];
		MFC = 1;
	end
	
	always @(posedge WR) begin
		RAM[AddrOut] = DataOut;
		MFC = 1;
	end
	
	always @(negedge RD or negedge WR) begin
		MFC = 0;
	end

	// Inputs to controller or datapath
	reg clk;
	reg reset;
	reg MFC;
	
	// From datapath to controller
	wire Status;
	wire [15:0] Instruction;

	// From controller to datapath
	wire DataReset;
	wire [8:0] LoadSignal;
	wire [5:0] TransferSignal;
	wire [2:0] ALOP;

	// Instantiate the Controller
	Controller controller (
		.clk(clk), 
		.reset(reset), 
		.MFC(MFC), 
		.Status(Status), 
		.Instruction(Instruction), 
		.DataReset(DataReset), 
		.LoadSignal(LoadSignal), 
		.TransferSignal(TransferSignal), 
		.ALOP(ALOP), 
		.RD(RD), 
		.WR(WR)
	);
	
	// Instantiate the datapath
	DataPath datapath (
		.clk(~clk), // Negative edge-synchronized
		.reset(DataReset), // All zeroes
		.LoadSignal(LoadSignal), 
		.TransferSignal(TransferSignal), 
		.ALOP(ALOP), 
		.DataIn(DataIn), 
		.AddrOut(AddrOut), 
		.DataOut(DataOut), 
		.Instruction(Instruction), 
		.Status(Status)
	);
	
	// start clock
	always begin
		clk = ~clk; # 10;
	end
	
	initial begin
		clk = 0;
		reset = 1;
		MFC = 0;
		
		// `Test program'
		RAM[0] = 16'h0000;	// push r0
		RAM[1] = 16'h0C00;	// not r0
		RAM[2] = 16'h0000;	// push r0
		RAM[3] = 16'h0A00;	// neg r0
		// r0 <- 1 , assuming data was reset just before execution
		
		RAM[4] = 16'h0000;	// push r0
		RAM[5] = 16'h0000;	// push r0
		
		RAM[6] = 16'h0810;	// pop r1
		RAM[7] = 16'h0910;	// add r1
		// r1 <- 2
		
		RAM[8] = 16'h0010;	// push r1
		RAM[9] = 16'h0010;	// push r1
		RAM[10] = 16'h0000;	// push r0
		
		RAM[11] = 16'h0820;	// pop r2
		RAM[12] = 16'h0920;	// add r2
		RAM[13] = 16'h0920;	// add r2
		// r2 <- 5
		
		RAM[14] = 16'h0000;	// push r0
		RAM[15] = 16'h0A30;	// neg r3
		// r3 <- -1
		
		RAM[16] = 16'hE054;	// call +85; (r2 <- r2 + r3)
		
		// Break loop on r3 == 0 or r3 == -1...
		// RAM[17] = 16'h4001; // bz +2 ; (bz halt)
		RAM[17] = 16'h8001;	// bs +2 ; (bs halt)
		
		RAM[18] = 16'h1FFD;	// b -3 ; (goto loop)
		
		RAM[19] = 16'h1FFF;	// b 0 ; (sort of halt)
		
		// Function : r3 <- r3 + r4
		RAM[101] = 16'h0030;	// push r3
		RAM[102] = 16'h0920;	// add r2
		RAM[103] = 16'hF000;	// return
		
		#50;
		reset = 0;
		
		// Test reset submodule
		#8500 ;
		reset = 1;
		#100 ;
		reset = 0;
		
	end
	
	// Outputs to display on simulator
	wire [15:0] SP = datapath.SP_out;
	wire [15:0] PC = datapath.PC_out;
	
	wire [15:0] r0 = datapath.regBank.regArray[0].reg_i.Out;
	wire [15:0] r1 = datapath.regBank.regArray[1].reg_i.Out;
	wire [15:0] r2 = datapath.regBank.regArray[2].reg_i.Out;
	wire [15:0] r3 = datapath.regBank.regArray[3].reg_i.Out;
	
	parameter HI = 65535;
	wire [15:0] s0 = RAM[HI];
	wire [15:0] s1 = RAM[HI-1];
	wire [15:0] s2 = RAM[HI-2];
	
	wire [2:0] Phase = controller.Phase;
	wire [2:0] State = controller.State;

endmodule

