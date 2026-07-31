# Route the design with the default NanoRoute flow.

banner "Run detail routing"
routeDesign
snapshot_report route timing {report_timing -max_paths 20 -nworst 1}
