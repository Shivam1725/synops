# Top-level Genus driver.

source [file join [file dirname [info script]] .. common setup.tcl]
source [file join [file dirname [info script]] .. common procs.tcl]

# Create top-level output directories for synthesis artifacts.
ensure_dir $REPORTS_ROOT
ensure_dir $OUTPUTS_ROOT
ensure_dir $LOGS_ROOT
ensure_dir $GENUS_OUTPUT_ROOT

# Run each synthesis stage in order.
run_stage [file join [file dirname [info script]] 01_read_design.tcl]
run_stage [file join [file dirname [info script]] 02_constraints.tcl]
run_stage [file join [file dirname [info script]] 03_synthesize.tcl]
run_stage [file join [file dirname [info script]] 04_reports.tcl]
run_stage [file join [file dirname [info script]] 05_export.tcl]

# Exit the tool cleanly once synthesis completes.
exit
