onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib img_5_opt

do {wave.do}

view wave
view structure
view signals

do {img_5.udo}

run -all

quit -force
