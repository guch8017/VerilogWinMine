onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib img_empty_open_opt

do {wave.do}

view wave
view structure
view signals

do {img_empty_open.udo}

run -all

quit -force
