include *.mk

vsim_std_fifo = work/std_fifo

vsim_std_fifo_tb = work/std_fifo_tb

all : work $(vsim_std_fifo) $(vsim_std_fifo_tb)

work :
	vlib work

$(vsim_std_fifo) : std_fifo.v
	vlog std_fifo.v

$(vsim_std_fifo_tb) : std_fifo_tb.v
	vlog std_fifo_tb.v

clean : cleanXst
	rm -rf work transcript

check : 
	echo -e "vsim work.std_fifo_tb\nrun -all" | vsim
