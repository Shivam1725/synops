# Build clock trees and review clock QoR.

banner "Run clock tree synthesis"
create_clock_tree_spec -file [file join $INNOVUS_OUTPUT_ROOT ${DESIGN_NAME}.cts.spec]
ccopt_design
snapshot_report cts timing {report_timing -max_paths 20 -nworst 1}
