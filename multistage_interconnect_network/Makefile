all : work multistage_interconnect_network multistage_interconnect_network_tb basic_switch

compile_multistage_interconnect_network = work/multistage_interconnect_network

work :
	vlib work

compile_basic_switch_ff = work/basic_switch_ff

basic_switch_ff : $(compile_basic_switch_ff)

$(compile_basic_switch_ff) : basic_switch_ff.v
	vlog basic_switch_ff.v

compile_omege_network_ff = work/omege_network_ff

omege_network_ff : $(compile_omege_network_ff)

$(compile_omege_network_ff) : omege_network_ff.v
	vlog omege_network_ff.v

compile_omega_network_ff_tb = work/omega_network_ff_tb

omega_network_ff_tb : $(compile_omega_network_ff_tb)

$(compile_omega_network_ff_tb) : omega_network_ff_tb.v
	vlog omega_network_ff_tb.v

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
