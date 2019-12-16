onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib img_mine_exp_opt

do {wave.do}

view wave
view structure
view signals

do {img_mine_exp.udo}

run -all

quit -force
