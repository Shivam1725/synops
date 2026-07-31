# Shared helper procedures for Cadence flow scripts.

proc banner {message} {
    puts "\n========== $message =========="
}

proc ensure_dir {path} {
    if {![file exists $path]} {
        file mkdir $path
    }
}

proc run_stage {stage_script} {
    banner "Running [file tail $stage_script]"
    if {![file exists $stage_script]} {
        error "Missing stage script: $stage_script"
    }
    uplevel #0 [list source $stage_script]
}

proc snapshot_report {stage name command} {
    ensure_dir [file join $::REPORTS_ROOT $stage]
    set report_file [file join $::REPORTS_ROOT $stage ${name}.rpt]
    banner "Writing $report_file"
    set redirect_cmd [concat [list redirect -tee -file $report_file] $command]
    uplevel #0 $redirect_cmd
}
