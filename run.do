vlib work
vlog -f src_files.list
vsim -voptargs=+acc work.topmodule -classdebug -uvmcontrol=all
add wave /topmodule/fif/*
coverage save topmodule.ucdb -onexit
run -all
#quit -sim
#vcover report topmodule.ucdb -details -annotate -all -output cov.txt