onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib clkVGA_opt

do {wave.do}

view wave
view structure
view signals

do {clkVGA.udo}

run -all

quit -force
