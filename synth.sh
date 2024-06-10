#!/bin/sh

rm -rf ./synth_*

T=("20.0" "10.0" "6.66" "5.0" "4.0" "3.33")


for i in ${T[@]}
do
	export PERIOD=$i
	mkdir "./synth_${PERIOD}"
	cd "./synth_${PERIOD}"
	genus -f ../synth.tcl
	cd ../
done