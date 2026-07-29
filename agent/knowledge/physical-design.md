# Physical Design Domain Knowledge

## Overview

Physical design is the process of transforming a logical (RTL/netlist) design
into a physical layout ready for fabrication. This document covers the key
concepts, methodologies, and best practices for Synopsys-based physical design
flows.

---

## 1. Physical Design Flow Overview

```
RTL / Synthesized Netlist
         │
         ▼
  ┌─────────────────┐
  │  Design Import  │  ← NDM libs, TLU+, SDC
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │  Floorplanning  │  ← Die size, macros, power grid
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │   Placement     │  ← Standard cell placement
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │      CTS        │  ← Clock tree synthesis
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │    Routing      │  ← Global + detail route
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │    Signoff      │  ← Timing, DRC, LVS, Power
  └─────────────────┘
         │
         ▼
  GDSII / OASIS Layout
```

---

## 2. Key Concepts

### 2.1 Standard Cell Library

Standard cells are pre-designed logic gates characterized for:
- **Timing:** Setup/hold times, propagation delays (NLDM/CCS models)
- **Power:** Static leakage, dynamic switching power (CPF/UPF)
- **Physical:** LEF/GDS geometry, pin locations, blockages

**Multi-Vt (Threshold Voltage) Libraries:**
| Vt Type | Speed  | Leakage | Usage |
|---------|--------|---------|-------|
| HVT     | Slow   | Low     | Non-critical paths |
| SVT     | Medium | Medium  | General purpose |
| LVT     | Fast   | High    | Critical paths |
| ULVT    | Fastest| Highest | Speed-critical only |

### 2.2 Placement Concepts

**Utilization:** Ratio of standard cell area to core area
- Typical range: 60-80% for routability
- >85% often leads to congestion

**Routing Resources:**
- **Horizontal layers:** Typically even-numbered metal layers
- **Vertical layers:** Typically odd-numbered metal layers
- **Preferred direction:** Reduces adjacent-layer vias

### 2.3 Clock Distribution

Clock distribution networks must achieve:
- **Low skew:** Minimizes setup/hold window
- **Low latency:** Reduces insertion delay impact
- **Low power:** Clock nets contribute 20-40% of dynamic power

**CTS Topologies:**
- **H-Tree:** Balanced binary tree, good for regular designs
- **Fishbone:** Hierarchical mesh for low-skew designs
- **Grid/Mesh:** Ultra-low skew, high power consumption
- **Clock Spine:** Horizontal trunk with vertical branches

### 2.4 Routing Layers

Typical advanced-node metal stack:

| Layer | Direction | Usage |
|-------|-----------|-------|
| M1    | H/V       | Local cell connections |
| M2    | Horizontal| Short-range signals |
| M3    | Vertical  | Medium-range signals |
| M4    | Horizontal| Medium-range signals |
| M5    | Vertical  | Long-range signals |
| M6    | Horizontal| Power / long-range |
| M7-M9 | H/V       | Power grid, global routing |
| AP    | —         | Top-level pads |

---

## 3. Timing Closure Methodology

### 3.1 Multi-Corner Multi-Mode (MCMM) Analysis

Physical design must close timing across all relevant scenarios:

```
Modes × Corners = Analysis Scenarios

Modes:
  - func_mode    (functional operation)
  - scan_mode    (DFT scan shift)
  - test_mode    (at-speed test)

Corners:
  - ss_0p72v_125c   (slow, high temp  → setup worst case)
  - ff_0p88v_m40c   (fast, low temp   → hold worst case)
  - tt_0p8v_25c     (typical          → power analysis)
```

### 3.2 Timing Budget

```
Clock Period = Setup Margin + Data Path Delay + Clock Uncertainty
            = slack_target + (launch_path - capture_path) + uncertainty

Hold Slack  = Data Path Delay - Clock Skew - Hold Margin
```

### 3.3 Physical Timing Optimization

**Common bottlenecks and fixes:**

| Issue | Analysis Command | Fix Strategy |
|-------|-----------------|--------------|
| Long wire delay | `report_timing -physical` | Route-aware optimization |
| High fanout net | `report_net -of_objects [get_nets ...]` | Buffer insertion |
| Long path with detour | `report_timing -crosstalk_delta` | Placement adjustment |
| Transition violation | `report_constraint -max_transition` | Buffer/driver sizing |

---

## 4. Power Planning

### 4.1 Power Grid Architecture

A robust power grid requires:
- **Global straps:** Wide M7-M9 straps across the full die
- **Local mesh:** M5-M6 pitch-matched to standard cell heights
- **Via stacks:** Full-via stacks for low-resistance connections
- **Rail resistance:** < 1 Ω from pad to furthest cell

### 4.2 IR Drop Analysis

```
V_drop = I_demand × R_grid

Acceptable limits:
  - Static IR drop:  < 3% of VDD
  - Dynamic IR drop: < 5% of VDD
```

**Mitigation:**
- Increase strap width/count
- Add decoupling capacitance cells
- Optimize activity switching patterns

### 4.3 Power Optimization Techniques

1. **Clock Gating:** Disable clocks to idle registers (reduces 20-40% power)
2. **Multi-Vt Optimization:** Replace non-critical LVT → HVT cells
3. **Operand Isolation:** Gate data inputs during hold conditions
4. **Power Gating:** Shut down idle power domains
5. **Dynamic Voltage Frequency Scaling (DVFS):** Operate at minimum required V/F

---

## 5. Design Rule Checking (DRC)

### 5.1 Key Design Rules

| Rule Category | Description |
|---------------|-------------|
| Minimum width | Minimum metal/via width |
| Minimum spacing | Minimum gap between same-layer shapes |
| Minimum enclosure | Via must be enclosed by metal |
| Minimum area | Minimum metal island area |
| Density | Metal density must be within bounds |
| Antenna | Metal area to gate oxide area ratio |
| ESD | Electrostatic discharge protection rules |

### 5.2 Advanced Node Specific Rules

- **Double Patterning (DPT):** Alternating masks for fine-pitch layers
- **Self-Aligned Via (SAV):** Via automatically aligned to connecting metals
- **Native Vt:** Transistor orientation/coloring constraints
- **SADP/SAQP:** Self-aligned double/quadruple patterning rules

---

## 6. Physical Verification

### 6.1 DRC Flow

```
GDSII  →  DRC Tool (Mentor Calibre / Synopsys ICV)  →  DRC Report
```

Key DRC tools:
- **Synopsys ICV (IC Validator):** Integrated with ICC2
- **Mentor Calibre:** Industry-standard verification
- **Klayout:** Open-source DRC scripting

### 6.2 LVS (Layout vs. Schematic)

Ensures layout matches netlist:

```
GDSII + CDL Netlist  →  LVS Tool  →  Match/Mismatch Report
```

Common LVS errors:
- Short circuits (unintended connections)
- Open circuits (missing connections)
- Extra/missing devices
- Parameter mismatches

### 6.3 Parasitic Extraction

Extracts RC parasitics for accurate post-layout simulation:

```tcl
# StarRC extraction in ICC2
set_extraction_options -parasitic_corner {max min}
extract_rc -coupling_cap true
```

---

## 7. Hierarchical Design

For large designs (>20M instances), hierarchical flows are required:

### 7.1 Hierarchical Design Planning

```
Top Level (Abstract)
    ├── Block A (Full Implementation)
    ├── Block B (Full Implementation)
    └── Block C (Full Implementation)
```

**Interface Logic Model (ILM):**
- Captures timing through block boundary
- Replaces full block for top-level timing
- Reduces runtime significantly

### 7.2 Budgeting and Interface Constraints

```tcl
# Create ILM for hierarchical implementation
create_ilm -output $block_ilm_path

# Use ILM in top-level
read_ilm -cell $block_name \
         -path $block_ilm_path
```

---

## 8. Glossary

| Term | Definition |
|------|-----------|
| APR  | Automated Place and Route |
| CTS  | Clock Tree Synthesis |
| DRC  | Design Rule Check |
| ECO  | Engineering Change Order |
| GDSII| Graphic Data System II (layout format) |
| ILM  | Interface Logic Model |
| IR Drop | Voltage drop across power grid resistance |
| LEF  | Library Exchange Format |
| LVS  | Layout versus Schematic |
| MCMM | Multi-Corner Multi-Mode |
| NDM  | New Data Model (Synopsys library format) |
| PEX  | Parasitic Extraction |
| PNR  | Place and Route |
| QoR  | Quality of Results |
| STA  | Static Timing Analysis |
| TLU+ | Table Lookup (parasitic technology file) |
| UPF  | Unified Power Format |
| WNS  | Worst Negative Slack |
| TNS  | Total Negative Slack |
