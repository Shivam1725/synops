# Top-level Innovus driver.

source [file join [file dirname [info script]] .. common setup.tcl]
source [file join [file dirname [info script]] .. common procs.tcl]

# Create top-level output directories for implementation artifacts.
ensure_dir $REPORTS_ROOT
ensure_dir $OUTPUTS_ROOT
ensure_dir $LOGS_ROOT
ensure_dir $INNOVUS_OUTPUT_ROOT

# Run each implementation stage in order.
run_stage [file join [file dirname [info script]] 01_init.tcl]
run_stage [file join [file dirname [info script]] 02_floorplan.tcl]
run_stage [file join [file dirname [info script]] 03_powerplan.tcl]
run_stage [file join [file dirname [info script]] 04_place.tcl]
run_stage [file join [file dirname [info script]] 05_cts.tcl]
run_stage [file join [file dirname [info script]] 06_route.tcl]
run_stage [file join [file dirname [info script]] 07_postroute_opt.tcl]
run_stage [file join [file dirname [info script]] 08_signoff.tcl]
run_stage [file join [file dirname [info script]] 09_export.tcl]

# Exit the tool cleanly once implementation completes.
exit
