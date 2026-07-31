# Multi-mode, multi-corner setup shared by Genus and Innovus.

if {![info exists REPO_ROOT]} {
    source [file join [file dirname [info script]] setup.tcl]
}

# Create library sets for setup and hold analysis.
create_library_set -name $LIBSET_SETUP -timing [list $LIB_SLOW]
create_library_set -name $LIBSET_HOLD -timing [list $LIB_FAST]

# Create RC corners using placeholder QRC technology data.
create_rc_corner -name $RC_CORNER_SETUP \
    -temperature $RC_SETUP_TEMP_C \
    -qrc_tech $QRC_TECH_FILE \
    -pre_route_res $RC_SETUP_PRE_ROUTE_RES_SCALE \
    -pre_route_cap $RC_SETUP_PRE_ROUTE_CAP_SCALE
create_rc_corner -name $RC_CORNER_HOLD \
    -temperature $RC_HOLD_TEMP_C \
    -qrc_tech $QRC_TECH_FILE \
    -pre_route_res $RC_HOLD_PRE_ROUTE_RES_SCALE \
    -pre_route_cap $RC_HOLD_PRE_ROUTE_CAP_SCALE

# Bind library and RC information into delay corners.
create_delay_corner -name $DELAY_CORNER_SETUP -library_set $LIBSET_SETUP -rc_corner $RC_CORNER_SETUP
create_delay_corner -name $DELAY_CORNER_HOLD -library_set $LIBSET_HOLD -rc_corner $RC_CORNER_HOLD

# Use a single functional constraint mode by default.
create_constraint_mode -name $CONSTRAINT_MODE_FUNC -sdc_files [list $SDC_FILE]

# Create analysis views and enable them for setup/hold.
create_analysis_view -name $VIEW_SETUP -constraint_mode $CONSTRAINT_MODE_FUNC -delay_corner $DELAY_CORNER_SETUP
create_analysis_view -name $VIEW_HOLD -constraint_mode $CONSTRAINT_MODE_FUNC -delay_corner $DELAY_CORNER_HOLD
set_analysis_view -setup [list $VIEW_SETUP] -hold [list $VIEW_HOLD]
