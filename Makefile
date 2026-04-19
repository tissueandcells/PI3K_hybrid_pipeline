# PI3K Hybrid Pipeline — Makefile
# Run `make help` to see all available targets

.PHONY: help all data train controls filter dock pharma figures md clean

PYTHON ?= python3
NOTEBOOK_DIR := notebooks
SCRIPT_DIR := scripts

help:
	@echo "PI3K Hybrid Pipeline — make targets"
	@echo ""
	@echo "  make data      Fetch + curate ChEMBL data (~30 min)"
	@echo "  make train     Train MT-GNN v1 and v2 (~2 h on RTX 5060 Ti)"
	@echo "  make controls  Run dual positive + negative control evaluation (~5 min)"
	@echo "  make filter    Apply Tier 1 drug-likeness + Tier 2 ADMET filters (~10 min)"
	@echo "  make dock      Full ensemble docking campaign (~24 h)"
	@echo "  make pharma    Pharmacophore analysis + robustness checks (~15 min)"
	@echo "  make figures   Regenerate all publication figures"
	@echo "  make md        Launch MD validation for CPD_0332 (~8 days, manual monitoring)"
	@echo "  make all       Run everything except MD (MD requires manual launch)"
	@echo "  make clean     Remove all intermediate files (keeps raw data + models)"
	@echo ""

all: data train controls filter dock pharma figures
	@echo "✓ Pipeline complete (MD not included — use 'make md' separately)"

data:
	@echo "→ Fetching ChEMBL data and curating dataset..."
	cd $(SCRIPT_DIR)/01_data_curation && $(PYTHON) fetch_chembl.py
	cd $(SCRIPT_DIR)/01_data_curation && $(PYTHON) curate_dataset.py
	cd $(SCRIPT_DIR)/01_data_curation && $(PYTHON) scaffold_split.py

train:
	@echo "→ Training MT-GNN v1 (baseline)..."
	cd $(SCRIPT_DIR)/02_mtgnn_training && $(PYTHON) train_mtgnn.py --config configs/v1.yaml
	@echo "→ Training MT-GNN v2 (selectivity-aware)..."
	cd $(SCRIPT_DIR)/02_mtgnn_training && $(PYTHON) train_mtgnn.py --config configs/v2.yaml
	@echo "→ Training single-task ablations..."
	cd $(SCRIPT_DIR)/02_mtgnn_training && $(PYTHON) train_single_task.py

controls:
	@echo "→ Evaluating positive and negative controls..."
	cd $(SCRIPT_DIR)/03_dual_controls && $(PYTHON) evaluate_controls.py

filter:
	@echo "→ Applying Tier 1 drug-likeness filter..."
	cd $(SCRIPT_DIR)/04_filtering && $(PYTHON) tier1_druglikeness.py
	@echo "→ Applying Tier 2 ADMET filter..."
	cd $(SCRIPT_DIR)/04_filtering && $(PYTHON) tier2_admet.py

dock:
	@echo "→ Preparing ligands..."
	cd $(SCRIPT_DIR)/05_ensemble_docking && $(PYTHON) prepare_ligands.py
	@echo "→ Running full ensemble docking campaign (17 structures × 494 compounds)..."
	cd $(SCRIPT_DIR)/05_ensemble_docking && $(PYTHON) run_campaign.py

pharma:
	@echo "→ Extracting pharmacophores and computing overlap..."
	cd $(SCRIPT_DIR)/06_pharmacophore && $(PYTHON) extract_pharmacophores.py
	cd $(SCRIPT_DIR)/06_pharmacophore && $(PYTHON) compute_overlap.py
	cd $(SCRIPT_DIR)/06_pharmacophore && $(PYTHON) robustness_analysis.py


md:
	@echo "→ Launching MD validation for CPD_0332 (~8 days)..."
	@echo "  Monitor with: tail -f ~/md_work/production/CPD_0332/prod_r1.log"
	cd $(SCRIPT_DIR)/07_md_validation && bash run_all.sh
	cd $(SCRIPT_DIR)/07_md_validation && bash run_rest.sh

test:
	@echo "→ Running unit tests..."
	$(PYTHON) -m pytest tests/ -v


