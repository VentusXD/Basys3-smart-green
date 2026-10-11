vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../../../../../AMDDesignTools/2025.2/Vivado/data/rsb/busdef" \
"../../../../Proyecto_PFA.gen/sources_1/ip/xadc_wiz_0_2/xadc_wiz_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

