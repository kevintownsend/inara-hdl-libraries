all : work multistage_interconnect_network multistage_interconnect_network_tb basic_switch

compile_multistage_interconnect_network = work/multistage_interconnect_network

work :
	vlib work

compile_basic_switch = work/basic_switch

basic_switch : $(compile_basic_switch)

$(compile_basic_switch) : basic_switch.v
	vlog basic_switch.v

multistage_interconnect_network : $(compile_multistage_interconnect_network)

$(compile_multistage_interconnect_network) : multistage_interconnect_network.v
	vlog -work work multistage_interconnect_network.v +incdir+../.

compile_multistage_interconnect_network_tb = work/multistage_interconnect_network_tb

multistage_interconnect_network_tb : $(compile_multistage_interconnect_network_tb)

$(compile_multistage_interconnect_network_tb) : multistage_interconnect_network_tb.v
	vlog -work work multistage_interconnect_network_tb.v

check :
	vsim < test.do

synthesis :
	xst -ifn multistage_interconnect_network.xst > xst.out

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst
