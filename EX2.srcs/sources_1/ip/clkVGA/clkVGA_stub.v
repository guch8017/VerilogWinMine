// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Thu Dec 12 10:17:55 2019
// Host        : DESKTOP-C6N4THH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/OneDrive - mail.ustc.edu.cn/1st half of 2nd year/Digital
//               Circuit Experiment/Lab10/Verilog/EX2/EX2.srcs/sources_1/ip/clkVGA/clkVGA_stub.v}
// Design      : clkVGA
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clkVGA(clk25MHz, reset, locked, clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk25MHz,reset,locked,clk_in" */;
  output clk25MHz;
  input reset;
  output locked;
  input clk_in;
endmodule
