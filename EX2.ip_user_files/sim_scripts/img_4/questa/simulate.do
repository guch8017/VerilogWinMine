onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib img_4_opt

do {wave.do}

view wave
view structure
view signals

do {img_4.udo}

run -all

quit -force
