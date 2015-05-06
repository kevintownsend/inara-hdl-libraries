all : work multistage_interconnect_network multistage_interconnect_network_tb basic_switch

compile_multistage_interconnect_network = work/multistage_interconnect_network

work :
	vlib work

compile_basic_switch_ff = work/basic_switch_ff

basic_switch_ff : $(compile_basic_switch_ff)

$(compile_basic_switch_ff) : basic_switch_ff.v
	vlog basic_switch_ff.v +incdir+../.

compile_omega_network_ff = work/omega_network_ff basic_switch_ff

omega_network_ff : $(compile_omega_network_ff)

$(compile_omega_network_ff) : omega_network_ff.v
	vlog omega_network_ff.v +incdir+../.

compile_omega_network_ff_tb = work/omega_network_ff_tb

omega_network_ff_tb : $(compile_omega_network_ff_tb)

$(compile_omega_network_ff_tb) : omega_network_ff_tb.v
	vlog omega_network_ff_tb.v +incdir+../.

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
	vlog -work work multistage_interconnect_network_tb.v +incdir+../.

check :
	vsim < test.do

chk_omega : omega_network_ff_tb omega_network_ff
	vsim < omega.do

synthesis :
	xst -ifn multistage_interconnect_network.xst > xst.out

clean :
	rm -rf work transcript *.lso *.out *.ngc *.xrpt *.srp _xmsgs xst

tcl:
	vivado -mode tcl < compile.tcl
