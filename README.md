# synops

`synops` is a starter Cadence digital-implementation workspace for ASIC/SoC flows built around Cadence Genus (logic synthesis) and Innovus (place-and-route). It includes a custom Copilot agent for Cadence flow authoring/debug, reusable TCL scaffolding, and placeholder configuration for design- and PDK-specific data that must stay outside version control.

## Repository layout

```text
.github/agents/cadence.md   Custom Copilot agent for Genus/Innovus help
AGENTS.md                   Repo-wide agent conventions
constraints/design.sdc      Template timing constraints
libs/                       Placeholder location only; do not commit vendor files
logs/                       Tool logs
outputs/                    Generated netlists/databases/GDS/SDF
reports/                    Stage reports grouped by flow stage
scripts/common/             Shared setup, MMMC, and helper procs
scripts/genus/              Genus synthesis flow stages
scripts/innovus/            Innovus implementation flow stages
```

## Configure a new design

1. Edit `scripts/common/setup.tcl`.
2. Set the design identity (`DESIGN_NAME`, `TOP_MODULE`) and update `RTL_FILES` / `HDL_SEARCH_PATHS`.
3. Replace placeholder values such as `__SET_PDK_ROOT__`, `__SET_LIB_SLOW__`, `__SET_TECH_LEF__`, and `__SET_QRC_TECH_FILE__` with your environment-specific paths or variables.
4. Adjust floorplan, power-grid, and output settings as needed.
5. Update `constraints/design.sdc` with your real clocks, IO delays, false paths, and multicycle exceptions.

> Do not commit `.lib`, `.lef`, `.gds`, vendor-encrypted, or other NDA-restricted foundry collateral to this repository.

## Run the flows

From the repository root:

```bash
make syn
make pnr
make clean
```

Targets:
- `make syn` runs `genus -files scripts/genus/run_genus.tcl -log logs/genus`
- `make pnr` runs `innovus -files scripts/innovus/run_innovus.tcl -log logs/innovus`
- `make clean` removes generated flow outputs while preserving tracked placeholders

## Flow conventions

- Keep reusable procedures in `scripts/common/`.
- Keep tech and library paths centralized in `scripts/common/setup.tcl`.
- Write reports to `reports/<stage>/`, generated implementation data to `outputs/`, and logs to `logs/`.
- Use placeholder variables instead of hardcoded absolute PDK paths in reusable scripts.

## Use the Cadence Copilot agent

After this repo is open in GitHub Copilot-enabled tooling, invoke the custom agent by selecting the `cadence` agent in the agent picker or by prompting `@copilot` with the Cadence agent selected. Use it for:
- Genus and Innovus TCL generation/review
- Timing, power, area, congestion, and DRC triage
- MMMC setup and flow handoff debugging
