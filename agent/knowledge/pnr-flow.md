# PNR Flow Knowledge Base

## Overview

Place and Route (PNR) is the physical implementation phase of ASIC design
that transforms a synthesized netlist into a manufacturable layout. This
knowledge base covers the complete PNR flow using Synopsys IC Compiler II
(ICC2).

---

## 1. Design Import and Setup

### Library Setup

Before importing design data, ensure all required libraries are configured:

```tcl
# Create or open design library
create_lib -technology $tech_file \
           -ref_libs "$std_cell_ndm $macro_ndm_list" \
           $design_lib

# Read the synthesized netlist
read_verilog $netlist_file
link_design $top_module

# Read timing constraints
read_sdc $sdc_file

# Read parasitic technology files
read_parasitic_tech_file -tlup_plus $tlup_max \
                          -tlup_plus_min $tlup_min \
                          -tech2itf_map $layer_map
```

### Design Rule Checks at Import

Always run an initial design check after import:

```tcl
check_design -checks dp_pre_floorplan
report_design_mismatch
```

---

## 2. Floorplanning

### Die/Core Area Definition

```tcl
# Initialize floorplan with utilization target
initialize_floorplan \
    -core_utilization 0.70 \
    -core_offset {5 5 5 5} \
    -flip_first_row true

# Or specify explicit dimensions
initialize_floorplan \
    -die_size {0 0 2000 1500} \
    -core_offset {20 20 20 20}
```

### Macro Placement

Proper macro placement is critical for routability and timing:

```tcl
# Set macro placement constraints
set_macro_placement_constraint \
    -macro_list [get_cells -filter "is_hard_macro==true"] \
    -keep_out_margin {5 5 5 5}

# Snap macros to legal positions
snap_floorplan -macro
```

**Best Practices:**
- Place macros in corners/edges to minimize routing detours
- Maintain adequate spacing between macros for routing channels
- Align macro orientation with signal flow direction
- Avoid macros blocking primary power straps

### Power Planning

```tcl
# Create power network mesh
create_pg_mesh_pattern -net VDD \
    -layer {M8 M9} \
    -width {4 4} \
    -pitch {80 80}

# Connect standard cell rails
create_pg_std_cell_conn_pattern \
    -net_pairs {VDD VSS} \
    -rail_width 0.1

# Run power network synthesis
synthesize_pg_network
```

---

## 3. Placement

### Place and Optimize

```tcl
# Run placement with optimization
place_opt \
    -effort high \
    -congestion \
    -timing_driven

# Report placement quality
report_placement_utilization
report_timing -max_paths 10
report_congestion
```

### Congestion Analysis

```tcl
# Check routing congestion
report_congestion -layers_used {M1 M2 M3 M4 M5 M6} \
                  -rerun_global_route

# Visualize congestion hotspots
create_routing_guide \
    -coord {x1 y1 x2 y2} \
    -layer M3
```

**Congestion Mitigation:**
1. Add placement blockages in congested areas
2. Reduce local cell density with partial blockages
3. Split congested macros if possible
4. Use higher drive-strength cells to reduce buffer counts

---

## 4. Clock Tree Synthesis (CTS)

### CTS Setup

```tcl
# Set CTS options
set_clock_tree_options \
    -clock_trees [get_clocks *] \
    -target_skew 0.05 \
    -max_transition 0.15 \
    -max_capacitance 0.15

# Define NDR rules for clock routing
create_routing_rule clock_rule \
    -width {M2 0.2 M3 0.2} \
    -spacing {M2 0.2 M3 0.2}

set_clock_routing_rules \
    -rules clock_rule \
    -clocks [get_clocks *]
```

### Run CTS

```tcl
# Perform clock tree synthesis
clock_opt \
    -only_cts \
    -no_clock_route

# Report clock tree results
report_clock_tree -summary
check_clock_tree -clocks [get_clocks *]
```

### Post-CTS Hold Fix

```tcl
# Fix hold violations after CTS
clock_opt \
    -only_psyn \
    -hold

report_timing -delay_type min -max_paths 20
```

---

## 5. Routing

### Global and Detail Routing

```tcl
# Run full routing flow
route_auto \
    -max_detail_route_iterations 5

# Or step-by-step
route_global -effort high
route_track
route_detail

# Post-route optimization
route_opt
```

### DRC Checking

```tcl
# Check for routing violations
check_routes
report_drc -output drc_report.txt

# Fix remaining violations
route_detail -incremental true
```

### Signal Integrity

```tcl
# Analyze crosstalk
report_noise -max_paths 20 \
             -slack_lesser_than 0.1

# Perform SI fixing
route_opt \
    -effort high \
    -signal_integrity
```

---

## 6. Signoff

### Timing Signoff

```tcl
# Final timing report
report_timing \
    -delay_type max \
    -max_paths 50 \
    -slack_lesser_than 0 \
    -output setup_violations.txt

report_timing \
    -delay_type min \
    -max_paths 50 \
    -slack_lesser_than 0 \
    -output hold_violations.txt

# Summary
report_timing_summary
```

### Power Analysis

```tcl
# Read activity for power analysis
read_saif $saif_file -instance $top_module

# Report power
report_power \
    -hierarchy \
    -output power_report.txt
```

### Output Generation

```tcl
# Write final GDS
write_gds -output $design.gds \
          -lib_cell_name $top_module

# Write final netlist
write_verilog -output $design.v

# Write SDF for simulation
write_sdf -output $design.sdf

# Write DEF
write_def -output $design.def
```

---

## 7. Common Issues and Solutions

### Setup Timing Violations

| Symptom | Root Cause | Solution |
|---------|-----------|----------|
| Large negative WNS | Long combinational path | Size up cells, insert buffers, restructure logic |
| Many paths failing | Tight clock constraint | Review SDC, identify false paths |
| Hold violations | Clock skew | Adjust CTS targets, add delay buffers |

### Congestion Issues

| Symptom | Root Cause | Solution |
|---------|-----------|----------|
| High routing overflow | Dense macro/cell region | Adjust macro placement, add routing guides |
| Via overflow | Too many vertical transitions | Optimize layer assignment |
| DRC after route | Congested local area | Add detour routes, widen channels |

### Timing Convergence Tips

1. **Early timing closure:** Run initial timing analysis after placement
2. **Incremental optimization:** Use `-incremental` flag for targeted fixes
3. **Path-specific fixes:** Address top-N worst paths before global optimization
4. **Physical optimization:** Co-optimize placement and routing

---

## 8. Flow Scripts Reference

### Recommended Flow Template

```
design_setup.tcl
floorplan.tcl
place.tcl
cts.tcl
route.tcl
signoff.tcl
```

Each script should source a common environment setup:

```tcl
# env_setup.tcl
set DESIGN_NAME    "my_design"
set WORK_DIR       "./work"
set REPORTS_DIR    "./reports"
set OUTPUTS_DIR    "./outputs"

source $WORK_DIR/lib_setup.tcl
source $WORK_DIR/constraint_setup.tcl
```
