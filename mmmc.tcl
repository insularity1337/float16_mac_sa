create_library_set \
  -name typ_lib \
  -timing { \
    sky130_fd_sc_hs/latest/timing/sky130_fd_sc_hs__tt_025C_1v80_ccsnoise.lib \
  }

create_opcond \
  -name typ_opcond \
  -process 1.0 \
  -voltage 1.8 \
  -temperature 25

create_timing_condition \
  -name typ_tcond \
  -library_sets typ_lib \
  -opcond typ_opcond

set captbl_path [concat $env(SKYWATER_PDK)/libraries/sky130_fd_sc_hs/latest/hs.captbl]

create_rc_corner \
  -name typ_rc \
  -temperature 25 \
  -cap_table $captbl_path

create_delay_corner \
  -name typ_dcorner \
  -early_timing_condition typ_tcond \
  -late_timing_condition typ_tcond \
  -early_rc_corner typ_rc \
  -late_rc_corner typ_rc

create_constraint_mode \
  -name typ_constr \
  -sdc_files ../sa.sdc

create_analysis_view \
  -name typ_view \
  -constraint_mode typ_constr \
  -delay_corner typ_dcorner

set_analysis_view \
  -setup typ_view \
  -hold typ_view