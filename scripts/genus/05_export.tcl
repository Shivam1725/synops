# Export synthesis handoff data for downstream implementation.

banner "Export Genus handoff artifacts"
write_hdl > $GENUS_NETLIST
write_sdc > $GENUS_SDC
write_design -innovus -base_name [file join $GENUS_OUTPUT_ROOT $DESIGN_NAME]
