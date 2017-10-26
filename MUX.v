`timescale 1ns / 1ps

module Mux2(input wire a,input wire b,input wire sel,output wire out);
	wire temp[1:0];
	and( temp[1] , a , sel );
	and( temp[0] , b , ~sel );
	or( out , temp[1] , temp[0] );
endmodule

module Mux4(input wire [3:0] a,input wire [1:0] sel,output wire out);
	wire temp[1:0];
	Mux2 m1 (a[3],a[2],sel[0],temp[1]);
	Mux2 m2 (a[1],a[0],sel[0],temp[0]);
	Mux2 m3 (temp[1],temp[0],sel[1],out);
endmodule

module Mux8(input wire [7:0] a,input wire [2:0] sel,output wire out);
	wire temp[1:0];
	Mux4 m1 (a[7:4],sel[1:0],temp[1]);
	Mux4 m2 (a[3:0],sel[1:0],temp[0]);
	Mux2 m3 (temp[1],temp[0],sel[2],out);
endmodule
