# Export the final implementation database and handoff files.

banner "Export Innovus outputs"
write_stream -format gds -output $FINAL_GDS
write_netlist $FINAL_NETLIST
write_sdf $FINAL_SDF
saveDesign $INNOVUS_DB
