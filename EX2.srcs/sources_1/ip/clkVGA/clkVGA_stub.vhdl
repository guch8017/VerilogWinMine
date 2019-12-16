-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Thu Dec 12 10:17:55 2019
-- Host        : DESKTOP-C6N4THH running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {d:/OneDrive - mail.ustc.edu.cn/1st half of 2nd year/Digital Circuit
--               Experiment/Lab10/Verilog/EX2/EX2.srcs/sources_1/ip/clkVGA/clkVGA_stub.vhdl}
-- Design      : clkVGA
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clkVGA is
  Port ( 
    clk25MHz : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end clkVGA;

architecture stub of clkVGA is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk25MHz,reset,locked,clk_in";
begin
end;
