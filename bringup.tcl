clear -all

analyze -sv controller.sv
analyze -sv tb.sv
analyze -sv properties.sv
analyze -sv covergroups.sv

elaborate -disable_auto_bbox \
    -bbox_m functional_cov \
    -top controller

reset rst

clock clk

reset -expression rst

set_engine_mode {B M G Hps Hts Tri}

