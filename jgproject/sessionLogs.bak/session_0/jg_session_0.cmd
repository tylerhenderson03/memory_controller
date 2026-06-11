# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2023.12
# platform  : Linux 5.14.0-611.36.1.el9_7.x86_64
# version   : 2023.12 FCS 64 bits
# build date: 2023.12.19 17:39:24 UTC
# ----------------------------------------
# started   : 2026-05-15 17:48:36 PDT
# hostname  : flip3.engr.oregonstate.edu.(none)
# pid       : 1483898
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:33461' '-style' 'windows' '-data' 'AAABJHicVY+9CsJAEIS/KPZWPoRgxD6tnSIqiF2IZ4yBkIgxCDb6qL5JnD1JkV3Y2Z+Z270AiN5t2+Jt+FIYs2LNjqXihoMQjswpuVALMxpyCnmqKmHhY8ODK46Ks/rGc+paXiozZiGV83WtGGqWSOMt+P6RKKBvVg/6ne2nhzDqxB3FBFNmet+urHgS6z7b23CTV9y1OdUFsX64F3vCSb1cnMxzQs2dtGY/K70nbQ==' '-proj' '/nfs/stak/users/hendetyl/eecs/ece499HW_Verif/hw/memory_controller/jgproject/sessionLogs/session_0' '-init' '-hidden' '/nfs/stak/users/hendetyl/eecs/ece499HW_Verif/hw/memory_controller/jgproject/.tmp/.initCmds.tcl' 'bringup.tcl'
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

prove -bg -all
visualize -violation -property <embedded>::controller.ctrl_sva_inst.m3_grant_LLM_generated -new_window
