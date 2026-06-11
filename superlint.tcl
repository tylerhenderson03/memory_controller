config_rtlds -rule -disable -domain all
config_rtlds -rule -enable -category {AUTO_FORMAL_OVERFLOW AUTO_FORMAL_DEAD_CODE AUTO_FORMAL_FSM_DEADLOCK_LIVELOCK}
analyze -sv controller.sv
elaborate -top controller
clock clk
reset reset
check_superlint -extract
check_superlint -prove

