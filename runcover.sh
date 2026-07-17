#!/bin/sh
vlog properties.sv controller.sv tbCover.sv covergroups.sv +fcover -cover sbcef +cover=f -O0 
vsim tbCover -c -coverage -do cover.do
