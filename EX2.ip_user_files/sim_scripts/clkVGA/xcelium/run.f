-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Vivado/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Vivado/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../EX2.srcs/sources_1/ip/clkVGA/clkVGA_clk_wiz.v" \
  "../../../../EX2.srcs/sources_1/ip/clkVGA/clkVGA.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

