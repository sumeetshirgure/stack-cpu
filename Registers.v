`timescale 1ns / 1ps

module Flag_Reg( input wire [3:0] In, output reg [3:0] Out, input wire reset, input wire clk );
always @ (posedge clk) begin
	if(reset) Out = 0;
	else Out = In;
end
endmodule

module TransferSwitch( input wire TransferSignal, input wire [15:0]Input, output wire[15:0]Output );
assign Output = TransferSignal ? Input : 16'hZZZZ;
endmodule

module R_16( input wire [15:0] In, output reg [15:0] Out, input wire reset, input wire clk );
always @ (posedge clk) begin
	if( reset ) Out = 0;
	else Out = In;
end
endmodule
