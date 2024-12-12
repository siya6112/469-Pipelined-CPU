# NOTES:
#  - The most important thing is locating where all of the files
#    are and specifying the correct paths (absolute or relative)
#    in the commands below.
#  - You will also need to make sure that your current directory
#    (cd) in ModelSim is the directory containing this .do file.


# Create work library
vlib work


# Compile Verilog
#  - All Verilog files that are part of this design should have
#    their own "vlog" line below.
vlog "./sub.sv"
vlog "./mux8_1.sv"
vlog "./mux4_1.sv"
vlog "./bypass.sv"
vlog "./mux2_1.sv"
vlog "./alu.sv"
vlog "./add.sv"
vlog "./flag0.sv"
vlog "./register.sv"
vlog "./regfile.sv"
vlog "./mux32_1.sv"
vlog "./demux3_8.sv"
vlog "./demux2_4.sv"
vlog "./decoder.sv"
vlog "./D_FF.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./math.sv"
vlog "./control.sv"
vlog "./cpu.sv"
vlog "./mux2_1_64.sv"
vlog "./datapathPC.sv"
vlog "./datapath.sv"
vlog "./mux2_1_5.sv"
vlog "./cpu_testbench.sv"


# Call vsim to invoke simulator
#  - Make sure the last item on the line is the correct name of
#    the testbench module you want to execute.
#  - If you need the altera_mf_ver library, add "-Lf altera_mf_lib"
#    (no quotes) to the end of the vsim command
vsim -voptargs="+acc" -t 1ps -lib work cpu_testbench 


# Source the wave do file
#  - This should be the file that sets up the signal window for
#    the module you are testing.
do cpu_testbench_wave.do


# Set the window types
view wave
view structure
view signals


# Run the simulation
run -all


# End
