# Read timing, physical, and netlist inputs into Innovus.

banner "Initialize Innovus design database"
read_mmmc [file join $SCRIPTS_COMMON_ROOT mmmc.tcl]
read_physical -lef $LEF_FILES
read_netlist $GENUS_NETLIST

# Initialize the physical design database.
init_design
