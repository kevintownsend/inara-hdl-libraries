
vsim_arbiter_tb = work/arbiter_8_tb/_primary.dat
vsim_arbiter = work/arbiter/_primary.dat
vsim_std_fifo = work/std_fifo/_primary.dat
VCOM = vcom
VLOG = vlog
VOPT = vopt
SCCOM = sccom

all : work $(vsim_arbiter_tb) $(vsim_std_fifo) $(vsim_arbiter)

work :
	vlib work

$(vsim_arbiter) : arbiter.v
	vlog -work work -L mtiAvm -L mtiOvm arbiter.v +incdir+./..

$(vsim_arbiter_tb) : arbiter_tb.v 
	vlog -work work -L mtiAvm -L mtiOvm -L mtiUvm -L mtiUPF arbiter_tb.v +incdir+./..

$(vsim_std_fifo) : ../std_fifo/std_fifo.v
	vlog -work work -L mtiAvm -L mtiOvm -L mtiUvm -L mtiUPF ../std_fifo/std_fifo.v +incdir+./..


check : all
	vsim < test.do

synthesis : 
	xst -ifn arbiter.xst > xst.out

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst
