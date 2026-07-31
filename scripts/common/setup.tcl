# Common design and environment setup for Cadence Genus and Innovus.
# Replace the placeholder values below with real project-specific inputs.

set REPO_ROOT [file normalize [file join [file dirname [info script]] ../..]]
set SCRIPTS_COMMON_ROOT [file join $REPO_ROOT scripts common]
set CONSTRAINTS_ROOT [file join $REPO_ROOT constraints]
set REPORTS_ROOT [file join $REPO_ROOT reports]
set OUTPUTS_ROOT [file join $REPO_ROOT outputs]
set LOGS_ROOT [file join $REPO_ROOT logs]

# Design identity.
set DESIGN_NAME "example_top"
set TOP_MODULE $DESIGN_NAME

# RTL inputs.
set RTL_ROOT [file join $REPO_ROOT rtl]
set RTL_FILES [list [file join $RTL_ROOT ${TOP_MODULE}.v]]
set HDL_SEARCH_PATHS [list $RTL_ROOT]

# Placeholder PDK and library configuration.
# Do not commit real foundry/vendor paths into the repository.
set PDK_ROOT "__SET_PDK_ROOT__"
set LIB_ROOT "__SET_LIB_ROOT__"
set LIB_SLOW "__SET_LIB_SLOW__"
set LIB_FAST "__SET_LIB_FAST__"
set TECH_LEF "__SET_TECH_LEF__"
set CELL_LEFS [list "__SET_CELL_LEF__"]
set LEF_FILES [concat [list $TECH_LEF] $CELL_LEFS]
set QRC_TECH_FILE "__SET_QRC_TECH_FILE__"
set INIT_LIB_SEARCH_PATHS [list $LIB_ROOT $PDK_ROOT]

# Constraints and MMMC names.
set SDC_FILE [file join $CONSTRAINTS_ROOT design.sdc]
set LIBSET_SETUP "libset_setup"
set LIBSET_HOLD "libset_hold"
set RC_CORNER_SETUP "rc_setup"
set RC_CORNER_HOLD "rc_hold"
set DELAY_CORNER_SETUP "delay_setup"
set DELAY_CORNER_HOLD "delay_hold"
set CONSTRAINT_MODE_FUNC "constraint_func"
set VIEW_SETUP "view_setup"
set VIEW_HOLD "view_hold"

# RC corner placeholders.
set RC_SETUP_TEMP_C 125
set RC_HOLD_TEMP_C -40
set RC_SETUP_PRE_ROUTE_RES_SCALE 1.00
set RC_SETUP_PRE_ROUTE_CAP_SCALE 1.00
set RC_HOLD_PRE_ROUTE_RES_SCALE 1.00
set RC_HOLD_PRE_ROUTE_CAP_SCALE 1.00

# Basic clock definition placeholders.
set CLOCK_NAME "core_clk"
set CLOCK_PORT "clk"
set CLOCK_PERIOD_NS 1.000
set CLOCK_UNCERTAINTY_NS 0.050
set INPUT_DELAY_NS 0.100
set OUTPUT_DELAY_NS 0.100

# Floorplan and power-planning placeholders.
set PLACE_SITE "__SET_PLACE_SITE__"
set CORE_UTILIZATION 0.65
set CORE_ASPECT_RATIO 1.0
set CORE_MARGIN_LEFT 10.0
set CORE_MARGIN_RIGHT 10.0
set CORE_MARGIN_TOP 10.0
set CORE_MARGIN_BOTTOM 10.0
set POWER_NET "VDD"
set GROUND_NET "VSS"
set RING_WIDTH 2.0
set RING_SPACING 1.0
set STRIPE_WIDTH 2.0
set STRIPE_SPACING 20.0
set STRIPE_PITCH 80.0

# Output locations.
set GENUS_OUTPUT_ROOT [file join $OUTPUTS_ROOT genus]
set INNOVUS_OUTPUT_ROOT [file join $OUTPUTS_ROOT innovus]
set GENUS_NETLIST [file join $GENUS_OUTPUT_ROOT ${DESIGN_NAME}_syn.v]
set GENUS_SDC [file join $GENUS_OUTPUT_ROOT ${DESIGN_NAME}_syn.sdc]
set INNOVUS_DB [file join $INNOVUS_OUTPUT_ROOT ${DESIGN_NAME}.enc]
set FINAL_NETLIST [file join $INNOVUS_OUTPUT_ROOT ${DESIGN_NAME}_pnr.v]
set FINAL_SDF [file join $INNOVUS_OUTPUT_ROOT ${DESIGN_NAME}.sdf]
set FINAL_GDS [file join $INNOVUS_OUTPUT_ROOT ${DESIGN_NAME}.gds]
