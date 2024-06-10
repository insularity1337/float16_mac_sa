set lib_path [concat $env(SKYWATER_PDK)/libraries]

set_db init_lib_search_path $lib_path
set_db script_search_path   ./
set_db init_hdl_search_path ../src

set_db information_level 11
set_db use_power_ground_pin_from_lef true
set_db lp_insert_clock_gating true

read_mmmc ../mmmc.tcl

set hs_tech_lef [find [get_db init_lib_search_path]/sky130_fd_sc_hs/ -name "*.tlef"]

set hs_cell_lef [find \
  [get_db init_lib_search_path]/sky130_fd_sc_hs/ \
  -name "*.lef" ! -name "*magic*" ! -name "*tap*" ! -name "*fill*" ! -name "*dly*" ! -name "*decap*" ! -name "*bus*" ! -name "*diode*"]

read_physical -lefs [list {*}$hs_tech_lef {*}$hs_cell_lef]

read_hdl -language sv { \
  ./multiplier.sv \
  ./categorizer.sv \
  ./extreme_value_detector.sv \
  ./sig_mul.sv \
  ./norm_calc.sv \
  ./subnorm_calc.sv \
  ./add/post_add_norm.sv \
  ./add/final_result.sv \
  ./add/acc.sv \
  ./mac.sv \
  ./sa.sv \
}

elaborate

init_design

set_db [get_db hnets DVI*] .lp_asserted_probability 0.5
set_db [get_db hnets DVI*] .lp_asserted_toggle_rate [expr (1.0 / $period) * 0.8]

set_db [get_db hnets DI*] .lp_asserted_probability 0.5
set_db [get_db hnets DI*] .lp_asserted_toggle_rate [expr (1.0 / $period) * 0.8]


get_db lib_cells {*tap* *fill* *dly* *decap* *bus* *diode*} -foreach {set_db $object .avoid true}

set_db [get_db lib_cells *a2111*] .avoid true

predict_floorplan

syn_generic -physical

syn_map -physical

syn_opt

report_timing > timing.rpt
report_area > area.rpt
report_power > power.rpt

q