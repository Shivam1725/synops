# Capture standard synthesis quality-of-results reports.

banner "Generate Genus reports"
snapshot_report genus timing {report_timing -max_paths 20 -nworst 1}
snapshot_report genus area {report_area}
snapshot_report genus power {report_power}
snapshot_report genus gates {report_gates}
snapshot_report genus qor {report_qor}
