SHELL := /bin/bash

.PHONY: syn pnr clean

syn:
	mkdir -p logs
	genus -files scripts/genus/run_genus.tcl -log logs/genus

pnr:
	mkdir -p logs
	innovus -files scripts/innovus/run_innovus.tcl -log logs/innovus

clean:
	rm -rf logs/* outputs/* reports/*
	touch logs/.gitkeep outputs/.gitkeep reports/.gitkeep
