sim :
	iverilog -o std_fifo_tb.vvp -I.. std_fifo_tb.v std_fifo.v
	std_fifo_tb.vvp

log2.vh :
	cp ../common/log2.vh .


include xst.mk
include vsim.mk

tcl : log2.vh
	vivado -mode tcl < compile.tcl

clean : cleanVsim cleanXst
	rm -rf work transcript *.vvp *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst *.log *.jou vivado

vim:
	vim -p makefile compile.tcl
