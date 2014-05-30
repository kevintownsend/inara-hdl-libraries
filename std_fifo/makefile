sim :
	iverilog -o std_fifo_tb.vvp -I.. std_fifo.v std_fifo_tb.v -o std_fifo_tb
	std_fifo_tb.vvp

synth :

include xst.mk
include vsim.mk

clean :
	rm -rf *.vvp
