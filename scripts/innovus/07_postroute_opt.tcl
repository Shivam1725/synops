# Run final post-route timing optimization.

banner "Run post-route optimization"
optDesign -postRoute -setup -hold
snapshot_report postroute timing {report_timing -max_paths 20 -nworst 1}
