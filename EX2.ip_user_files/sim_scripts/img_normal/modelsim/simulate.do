onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L dist_mem_gen_v8_0_13 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.img_normal xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {img_normal.udo}

run -all

quit -force
