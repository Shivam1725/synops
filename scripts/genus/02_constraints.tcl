# Load MMMC setup and timing constraints before design initialization.

banner "Apply MMMC and SDC constraints"
source [file join $SCRIPTS_COMMON_ROOT mmmc.tcl]
read_sdc $SDC_FILE

# Initialize the elaborated design in the active analysis views.
init_design
