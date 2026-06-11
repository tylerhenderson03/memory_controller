#!/bin/sh
vlog tb.sv controller.sv covergroups.sv properties.sv +fcover -cover sbcef +cover=f -O0 -mfcu
vsim tb -c -coverage    -do cover.do
