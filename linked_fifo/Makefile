all : work linked_fifo linked_fifo_tb linked_fifo_gold

work :
	vlib work

compile_linked_fifo = work/linked_fifo

linked_fifo : $(compile_linked_fifo)

$(compile_linked_fifo) : linked_fifo.v
	vlog -work work linked_fifo.v +incdir+../.

compile_linked_fifo_gold = work/linked_fifo_gold

linked_fifo_gold : $(compile_linked_fifo_gold)

$(compile_linked_fifo_gold) : linked_fifo_gold.v
	vlog -work work linked_fifo_gold.v +incdir+../.

compile_linked_fifo_tb = work/linked_fifo_tb

linked_fifo_tb : $(compile_linked_fifo_tb) $(compile_linked_fifo)

$(compile_linked_fifo_tb) : linked_fifo_tb.v
	vlog -work work linked_fifo_tb.v +incdir+../.

check : all
	vsim < test.do

xst : linked_fifo.v

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst out.xst
