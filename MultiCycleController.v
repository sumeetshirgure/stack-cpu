`timescale 1ns / 1ps

module Controller(
input wire clk,
input wire reset,
input wire MFC,
input wire Status,
input wire [15:0] Instruction,
output wire DataReset,
output wire [8:0] LoadSignal,
output wire [5:0] TransferSignal,
output reg [2:0] ALOP,
output reg RD,
output reg WR
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

wire _NotPushPop , _Pop , _NotBranch , _Condition;
or( _NotPushPop , Instruction[15] , Instruction[14] , Instruction[13] , Instruction[12] );
or( _Pop , Instruction[11] , Instruction[10] , Instruction[9] , Instruction[8] );
and( _NotBranch , Instruction[15] , Instruction[14] , Instruction[13] );
or( _Condition , Instruction[15] , Instruction[14] , Instruction[13] );

wire BranchInstruction;
or( BranchInstruction , ~_Condition , Status ); // Either unconditional or conditional branch instruction

reg [2:0] State = 0;
reg [2:0] Phase = 0;

// Operation codes
parameter ADD  = 1;
parameter NEGY = 2;
parameter OR   = 3;
parameter NOTY = 4;
parameter CPX =  5;
parameter INX =  6;
parameter DCX =  7;
parameter CPY =  0;

// Phases
parameter Reset  = 0; // Reset Phase
parameter Fetch  = 1;
parameter Push   = 2;
parameter Pop    = 3;
parameter Branch = 4;
parameter Call   = 5;
parameter Return = 6;
parameter PostEx = 7; // Post execution phase

// Transition function
always@ (posedge clk) begin
case( Phase )

Reset : begin
	if( State == 0 ) begin
		// DataReset
		State = 1;
	end else begin // State = 1
		// SP = ~T;
		State = 0;
		if( !reset ) begin
			Phase = Fetch;
		end
	end
end

Fetch : begin
	if( State == 0 ) begin
		// MAR = PC;
		State = 1;
		RD = 1;
	end else if( State == 1 ) begin
		// ldIR = 1;
		if( MFC ) begin
			RD = 0;
			State = 2;
		end
	end else begin // State = 2
		// PC = PC + 1;
		if( _NotPushPop ) begin // Select next submodule( Controller Module )
			if( _NotBranch ) begin
				if( Instruction[12] ) Phase = Return;
				else Phase = Call;
			end else begin
				Phase = Branch;
			end
		end else begin
			if( _Pop ) Phase = Pop ;
			else       Phase = Push;
		end
		State = 0; // Reset State
	end
end // End fetch phase.

Push : begin
	if( State == 0 ) begin
		// MAR = SP;
		State = 1;
	end else if( State == 1 ) begin
		// MDR = R[RegId];
		State = 2;
		WR = 1;
	end else if( State == 2 ) begin
		if( MFC ) begin
			WR = 0;
			State = 3;
		end
	end else begin // State == 3
		// SP = SP - 1;
		State = 0;
		Phase = PostEx;
	end
end // End push phase

Pop : begin
	if( State == 0 ) begin
		// SP = SP+1; MAR = SP;
		State = 1;
		RD = 1;
	end else if( State == 1 ) begin
		if( MFC ) begin
			RD = 0;
			// MDR = DataIn;
			State = 2;
		end
	end else if( State == 2 ) begin
		// T = MDR;
		State = 3;
	end else begin // State == 3
		// ALU operation
		State = 0;
		Phase = PostEx;
	end
end // End pop phase

Branch : begin
	if( State == 0 ) begin
		// T = L;
		State = 1;
	end else begin // State == 1
		// PC = PC + L
		State = 0;
		Phase = PostEx;
	end
end // End branch phase

Call : begin
	if( State == 0 ) begin
		// MDR = PC;
		State = 1;
	end else if( State == 1 ) begin
		// MAR = SP;
		State = 2;
	end else if( State == 2 ) begin
		// SP = SP - 1;
		State = 3;
		WR = 1;
	end else if( State == 3 ) begin
		if( MFC ) begin
			WR = 0;
			State = 4;
		end
	end else if( State == 4 ) begin
		// T = L;
		State = 5;
	end else begin // State == 5
		// PC = PC + T;
		Phase = PostEx;
	end
end // End Call phase

Return : begin
	if( State == 0 ) begin
		// SP = SP+1;MAR = SP;
		State = 1;
		RD = 1;
	end else if( State == 1 ) begin
		// MDR = DataIn;
		if( MFC ) begin
			RD = 0;
			State = 2;
		end
	end else begin // State == 2
		// PC = MDR;
		State = 0;
		Phase = PostEx;
	end
end // End Return phase

default : begin // Post execution phase
	if( reset ) begin
		State = 0; Phase = Reset;
	end else begin
		State = 0; Phase = Fetch;
	end
end // End post execution phase

endcase // Case Phase
end // @always

// Activation of control signals
assign DataReset = ( Phase == Reset & State == 0 );

assign TransferSignal[trMAR] = 0;

assign TransferSignal[trPC] = (Phase == Fetch & (State==0|State==2)) |
										BranchInstruction & (Phase == Branch & State == 1 ) |
										(Phase == Call & ( State == 0 | State == 5 ) ) ;

assign LoadSignal[ldPC] = 	( Phase == Fetch  & State == 2 ) |
									BranchInstruction & (Phase == Branch & State == 1 ) |
									( Phase == Call & State == 5 ) |
									(Phase == Return & State == 2 ) ;

assign TransferSignal[trSP] = ( Phase == Push & ( State == 0 | State == 3 ) ) |
										( Phase == Pop & State == 0 ) |
										( Phase == Call & ( State == 1 | State == 2 ) ) |
										( Phase == Return & State == 0 ) ;

assign LoadSignal[ldSP] = 	( Phase == Push & State == 3 ) |
									( Phase == Pop & State == 0 ) |
									( Phase == Call & State == 2 ) |
									( Phase == Return & State == 0 ) |
									(Phase == Reset & State == 1 ) ;

assign LoadSignal[ldT] = ( Phase == Pop & State == 2 ) |
								( Phase == Branch & State == 0 ) |
								( Phase == Call & State == 4 ) ;

assign LoadSignal[ldMAR] = ( Phase == Fetch & State == 0 ) |
									( Phase == Push & State == 0 ) |
									( Phase == Pop & State == 0 ) |
									( Phase == Call & State == 1 ) |
									( Phase == Return & State == 0 ) ;

assign LoadSignal[ldIR] = (Phase == Fetch & State == 1);

assign TransferSignal[trR] = 	( Phase == Push & State == 1 ) |
										( Phase == Pop & State == 3 ) ;

assign LoadSignal[ldR] = ( Phase == Pop & State == 3 );

assign LoadSignal[ldMDZ] = ( Phase == Push & State == 1 ) |
									( Phase == Call & State == 0 ) ;

assign LoadSignal[ldMDM] = ( Phase == Pop & State == 1 ) |
									( Phase == Return & State == 1 ) ;

assign TransferSignal[trMDR] =	( Phase == Pop & State == 2 ) |
											( Phase == Return & State == 2 );

assign LoadSignal[ldF] = ( Phase == Pop & State == 3 );

assign TransferSignal[trL] = 	( Phase == Branch & State == 0 ) |
										( Phase == Call & State == 4 ) ;

// Operation codes to ALU
always @(*) begin
case (Phase)

Reset : begin
	if( State == 0 ) begin
		// DataReset
	end else begin
		// SP = ~T;
		ALOP = NOTY;
	end
end

Fetch : begin
	if( State == 0 ) begin
		// MAR = PC;
		ALOP = CPX;
	end else if( State == 1 ) begin
		// Read
	end else begin // State = 2
		// PC = PC + 1;
		ALOP = INX;
	end
end // End fetch phase.

Push : begin
	if( State == 0 ) begin
		// MAR = SP;
		ALOP = CPX;
	end else if( State == 1 ) begin
		// MDR = R[RegId];
		ALOP = CPX;
	end else if( State == 2 ) begin
	end else begin // State == 3
		ALOP = DCX;
	end
end // End push phase

Pop : begin
	if( State == 0 ) begin
		ALOP = INX;
	end else if( State == 1 ) begin
		// Read
	end else if( State == 2 ) begin
		// T = MDR;
	end else begin // State == 3
		ALOP = Instruction[10:8];
	end
end // End pop phase

Branch : begin
	if( State == 0 ) begin
		// T = L;
	end else begin // State == 1
		// PC = PC + L
		ALOP = ADD;
	end
end // End branch phase

Call : begin
	if( State == 0 ) begin
		// MDR = PC;
		ALOP = CPX;
	end else if( State == 1 ) begin
		// MAR = SP;
		ALOP = CPX;
	end else if( State == 2 ) begin
		// SP = SP - 1;
		ALOP = DCX;
	end else if( State == 3 ) begin
	end else if( State == 4 ) begin
		// T = L;
	end else begin // State == 5
		// PC = PC + T;
		ALOP = ADD;
	end
end // End Call phase

Return : begin
	if( State == 0 ) begin
		// SP = SP+1;MAR = SP;
		ALOP = INX;
	end else if( State == 1 ) begin
		// MDR = DataIn;
	end else begin // State == 2
		// PC = MDR;
		ALOP = CPX;
	end
end // End Return phase

default : begin
// No operation
end

endcase
end // @ always

endmodule
