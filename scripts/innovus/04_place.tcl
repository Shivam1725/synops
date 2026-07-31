# Run placement and snapshot basic placement QoR.

banner "Run placement"
place_opt_design
snapshot_report place timing {report_timing -max_paths 20 -nworst 1}
snapshot_report place congestion {reportCongestion}
