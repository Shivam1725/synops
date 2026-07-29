"""
Agent Search and Discovery System for Synops EDA Agents.

Provides functionality to search, discover, and load agents from the
agent registry based on user queries, expertise requirements, or tags.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


REGISTRY_PATH = Path(__file__).parent / "agent-registry.yml"


@dataclass
class Agent:
    """Represents a registered Synops agent."""

    id: str
    name: str
    version: str
    description: str
    expertise: list[str] = field(default_factory=list)
    tools: list[str] = field(default_factory=list)
    tags: list[str] = field(default_factory=list)
    config: str | None = None

    def matches(self, query: str, threshold: float = 0.3) -> float:
        """
        Compute a relevance score for this agent against a query string.

        Returns a float in [0.0, 1.0] where higher means more relevant.
        """
        query_tokens = set(re.split(r"[\s,_\-]+", query.lower()))
        if not query_tokens:
            return 0.0

        searchable: list[str] = [
            self.id,
            self.name,
            self.description,
            *self.expertise,
            *self.tags,
        ]
        text = " ".join(searchable).lower()
        text_tokens = set(re.split(r"[\s,_\-]+", text))

        hits = query_tokens & text_tokens
        score = len(hits) / len(query_tokens)
        return score if score >= threshold else 0.0


@dataclass
class DiscoveryConfig:
    """Configuration for the discovery system."""

    search_fields: list[str]
    default_limit: int
    similarity_threshold: float
    fallback_agent_id: str


class AgentRegistry:
    """
    Loads and indexes agents from the YAML registry file.

    Usage::

        registry = AgentRegistry()
        results = registry.search("routing congestion", limit=3)
        for agent in results:
            print(agent.name, agent.description)
    """

    def __init__(self, registry_path: Path = REGISTRY_PATH) -> None:
        raw = yaml.safe_load(registry_path.read_text())

        self._agents: dict[str, Agent] = {}
        for entry in raw.get("agents", []):
            agent = Agent(
                id=entry["id"],
                name=entry["name"],
                version=entry["version"],
                description=entry["description"],
                expertise=entry.get("expertise", []),
                tools=entry.get("tools", []),
                tags=entry.get("tags", []),
                config=entry.get("config"),
            )
            self._agents[agent.id] = agent

        discovery_raw = raw.get("discovery", {})
        routing_raw = raw.get("routing", {})
        self._config = DiscoveryConfig(
            search_fields=discovery_raw.get("search_fields", []),
            default_limit=discovery_raw.get("default_limit", 5),
            similarity_threshold=discovery_raw.get("similarity_threshold", 0.3),
            fallback_agent_id=routing_raw.get("fallback", ""),
        )

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    @property
    def agents(self) -> list[Agent]:
        """Return all registered agents."""
        return list(self._agents.values())

    def get(self, agent_id: str) -> Agent | None:
        """Return an agent by its unique identifier, or None if not found."""
        return self._agents.get(agent_id)

    def search(self, query: str, limit: int | None = None) -> list[Agent]:
        """
        Search for agents matching a free-text query.

        Results are ranked by relevance score (descending).  Only agents
        whose score meets the configured ``similarity_threshold`` are returned.

        Parameters
        ----------
        query:
            Natural-language or keyword query string, e.g.
            ``"clock tree synthesis hold violations"``.
        limit:
            Maximum number of results.  Defaults to the registry's
            ``discovery.default_limit``.

        Returns
        -------
        list[Agent]
            Matching agents ordered by descending relevance.
        """
        max_results = limit if limit is not None else self._config.default_limit
        scored: list[tuple[float, Agent]] = []

        for agent in self._agents.values():
            score = agent.matches(query, self._config.similarity_threshold)
            if score > 0.0:
                scored.append((score, agent))

        scored.sort(key=lambda t: t[0], reverse=True)
        return [agent for _, agent in scored[:max_results]]

    def search_by_expertise(self, expertise: str) -> list[Agent]:
        """Return agents that list *expertise* in their expertise field."""
        expertise_lower = expertise.lower()
        return [
            a
            for a in self._agents.values()
            if any(expertise_lower in e.lower() for e in a.expertise)
        ]

    def search_by_tag(self, tag: str) -> list[Agent]:
        """Return agents that carry the given *tag*."""
        tag_lower = tag.lower()
        return [
            a
            for a in self._agents.values()
            if any(tag_lower in t.lower() for t in a.tags)
        ]

    def search_by_tool(self, tool: str) -> list[Agent]:
        """Return agents that use the specified *tool*."""
        tool_lower = tool.lower()
        return [
            a
            for a in self._agents.values()
            if any(tool_lower in t.lower() for t in a.tools)
        ]

    def fallback(self) -> Agent | None:
        """Return the configured fallback agent, or None."""
        return self.get(self._config.fallback_agent_id)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def summary(self) -> dict[str, Any]:
        """Return a summary dict suitable for logging or display."""
        return {
            "total_agents": len(self._agents),
            "agents": [
                {
                    "id": a.id,
                    "name": a.name,
                    "tags": a.tags,
                }
                for a in self._agents.values()
            ],
        }


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def _cli() -> None:
    """Simple command-line interface for agent discovery."""
    import argparse
    import json

    parser = argparse.ArgumentParser(
        description="Synops agent search and discovery tool"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # list command
    subparsers.add_parser("list", help="List all registered agents")

    # search command
    search_parser = subparsers.add_parser("search", help="Search agents by query")
    search_parser.add_argument("query", help="Search query string")
    search_parser.add_argument(
        "--limit", type=int, default=None, help="Maximum results"
    )

    # get command
    get_parser = subparsers.add_parser("get", help="Get agent by ID")
    get_parser.add_argument("agent_id", help="Agent identifier")

    args = parser.parse_args()
    registry = AgentRegistry()

    if args.command == "list":
        print(json.dumps(registry.summary(), indent=2))

    elif args.command == "search":
        results = registry.search(args.query, limit=args.limit)
        if not results:
            print("No agents found matching query.")
        else:
            for agent in results:
                print(f"  [{agent.id}]  {agent.name}")
                print(f"    {agent.description.strip()}")
                print(f"    Tags: {', '.join(agent.tags)}")
                print()

    elif args.command == "get":
        agent = registry.get(args.agent_id)
        if agent is None:
            print(f"Agent '{args.agent_id}' not found.")
        else:
            print(f"Name:        {agent.name}")
            print(f"Version:     {agent.version}")
            print(f"Description: {agent.description.strip()}")
            print(f"Expertise:   {', '.join(agent.expertise)}")
            print(f"Tools:       {', '.join(agent.tools)}")
            print(f"Tags:        {', '.join(agent.tags)}")


if __name__ == "__main__":
    _cli()
