xst : std_fifo.prj
	echo "run -ifn std_fifo.prj -ifmt mixed -top std_fifo -ofn std_fifo.ngc -ofmt NGC -p xc5vlx330-2 -opt_mode Speed -opt_level 1 -vlgincdir ../." | xst

std_fifo.prj :
	echo "verilog work std_fifo.v" > std_fifo.prj

cleanXst :
	rm -rf xst *.prj
