-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Vivado/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Vivado/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/dist_mem_gen_v8_0_13 \
  "../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../EX2.srcs/sources_1/ip/img_empty_open/sim/img_empty_open.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib
