sim :
	iverilog -o std_fifo_tb.vvp -I.. std_fifo_tb.v std_fifo.v 	
	std_fifo_tb.vvp

synth :

include xst.mk
include vsim.mk

tcl :
	vivado -mode tcl < compile.tcl

clean : cleanVsim cleanXst
	rm -rf work transcript *.vvp *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst *.log *.jou vivado
