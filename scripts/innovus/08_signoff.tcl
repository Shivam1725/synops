# Run signoff-oriented physical verification checks.

banner "Run signoff verification"
snapshot_report signoff drc {verify_drc}
snapshot_report signoff connectivity {verify_connectivity}
snapshot_report signoff antenna {verifyProcessAntenna}
