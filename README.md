# synops

Synopsys EDA AI agent configuration with deep expertise in PNR (Place and Route)
flows, physical design, and Synopsys tool integration.

---

## Features

| Feature | Description |
|---------|-------------|
| **PNR Flow Expertise** | Complete ICC2 PNR guidance from import through GDSII signoff |
| **Physical Design Knowledge** | Timing closure, power planning, CTS, routing best practices |
| **SolveNet Integration** | Automatic lookup of Synopsys Known Issues and Design Advisories |
| **Agent Discovery** | Registry and search system for all Synops specialist agents |

---

## Repository Structure

```
synops/
├── .github/
│   └── copilot-instructions.md   # Copilot agent instructions
├── agent/
│   ├── config/
│   │   └── agent.yml             # Main agent configuration
│   ├── profiles/
│   │   └── pnr-expertise.yml     # PNR flow expertise profile
│   ├── knowledge/
│   │   ├── pnr-flow.md           # PNR flow knowledge base
│   │   └── physical-design.md    # Physical design domain knowledge
│   ├── integrations/
│   │   └── solvenet.yml          # SolveNet integration configuration
│   └── discovery/
│       ├── agent-registry.yml    # Agent registry
│       └── search.py             # Agent search and discovery system
└── README.md
```

---

## Quick Start

### Agent Discovery CLI

```bash
# Install dependencies
pip install pyyaml

# List all registered agents
python agent/discovery/search.py list

# Search for agents by query
python agent/discovery/search.py search "clock tree synthesis"

# Get details of a specific agent
python agent/discovery/search.py get synops-pnr-agent
```

### Programmatic Usage

```python
from agent.discovery.search import AgentRegistry

registry = AgentRegistry()

# Search by free-text query
agents = registry.search("routing congestion DRC")

# Search by expertise area
agents = registry.search_by_expertise("timing_closure")

# Search by tool
agents = registry.search_by_tool("icc2_shell")
```

---

## Registered Agents

| Agent ID | Specialization |
|----------|---------------|
| `synops-pnr-agent` | Place and Route (ICC2) — *default* |
| `synops-timing-agent` | Static Timing Analysis (PrimeTime) |
| `synops-synthesis-agent` | Logic Synthesis (Design Compiler) |
| `synops-verification-agent` | DRC / LVS (IC Validator) |
| `synops-power-agent` | Power Analysis and IR Drop |

---

## SolveNet Integration

Set the `SOLVENET_API_TOKEN` environment variable to enable automatic
SolveNet lookups when the agent encounters tool errors or warnings.

```bash
export SOLVENET_API_TOKEN=<your-token>
```

See [`agent/integrations/solvenet.yml`](agent/integrations/solvenet.yml)
for full configuration options.
