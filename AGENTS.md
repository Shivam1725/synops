# AGENTS.md

Repository conventions for all agents:
- Use `scripts/common/setup.tcl` for design-specific variables, file lists, corner data, clock definitions, and placeholder PDK/library paths.
- Keep reusable TCL helpers in `scripts/common/` and stage drivers in `scripts/genus/` and `scripts/innovus/`.
- Write reports to `reports/<stage>/`, logs to `logs/`, and generated netlists/databases/streams to `outputs/`.
- Do not hardcode absolute PDK paths in flow steps; use variables from `setup.tcl`.
- Run synthesis with `make syn` and place-and-route with `make pnr` after updating `setup.tcl` and `constraints/design.sdc`.
- Never commit `.lib`, `.lef`, `.gds`, or other NDA-restricted vendor collateral.
