# PI3K Hybrid Pipeline

Computational workflows for prioritising inhibitor candidates across the four class I PI3K isoforms (α, β, δ and γ), combining molecular machine learning with structure-based analysis.

## Workflow

1. ChEMBL bioactivity data retrieval, curation and scaffold-based splitting.
2. Multi-task graph neural network modelling and control-compound evaluation.
3. Compound filtering and ensemble molecular docking.
4. Pharmacophore comparison and molecular dynamics analysis.

## Repository contents

- `scripts/` — Data processing, model training, control evaluation, filtering, docking and MD workflow scripts.
- `data/` — Control-compound data and selected dataset, docking and pharmacophore summary tables.

## Software

The workflows use Python, RDKit, PyTorch, PyTorch Geometric, AutoDock Vina and GROMACS. Dependencies and input files depend on the selected workflow.

## License

Code: [MIT](https://opensource.org/licenses/MIT).
Data: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
