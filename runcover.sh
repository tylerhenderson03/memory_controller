#!/bin/sh
vlog tb.sv controller.sv covergroups.sv +fcover -cover sbcef +cover=f -O0 
vsim tb -c -coverage -do cover.do
