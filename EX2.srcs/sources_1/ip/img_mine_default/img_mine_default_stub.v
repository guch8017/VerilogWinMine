// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Thu Dec 12 12:11:49 2019
// Host        : DESKTOP-C6N4THH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {d:/OneDrive - mail.ustc.edu.cn/1st half of 2nd year/Digital
//               Circuit Experiment/Lab10/Verilog/EX2/EX2.srcs/sources_1/ip/img_mine_default/img_mine_default_stub.v}
// Design      : img_mine_default
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.1" *)
module img_mine_default(a, spo)
/* synthesis syn_black_box black_box_pad_pin="a[9:0],spo[11:0]" */;
  input [9:0]a;
  output [11:0]spo;
endmodule
