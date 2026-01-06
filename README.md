# Dynamic Topology Neural Nets

A Wolfram Language implementation of neural networks that evolve their own topology during learning.

## Quick Start
1.  Open `tools/dynamic_topology_neural_nets.wl` in a notebook to inspect the core library.
2.  Run the **test run**: Open `test_run.wl`.
3.  Try a **guide**: Open `guides/pavlovian_conditioning/experiment.wl` for a walkthrough of associative learning.

## Documentation Index

We have structured the documentation to guide you from high-level "Why" to low-level "How".

| Level | Document | Description |
| :--- | :--- | :--- |
| **1. Theory** | [Theoretical Rationale](docs/theoretical_rationale.md) | **Why** are we doing this? Philosophies of Structural Plasticity, sparse networks, and biological inspiration. |
| **2. Architecture** | [Program Architecture](docs/program_architecture.md) | **How** is the program structured? Overview of the "BrainState" data structure and the functional simulation pipeline. |
| **3. Mechanics** | [Function Reference](docs/function_reference.md) | **Deep Dive** into every specific function. Explains the exact mechanism and the design intuition behind specific algorithmic choices. |
| **4. Math** | [Mathematical Framework](docs/mathematical_framework.md) | **Formulas**. The raw LaTeX formulations of the update rules and state transitions. |
| **5. Parameters** | [Parameters Reference](docs/parameters_reference.md) | **Tuning**. Detailed explanation of hyperparameters like Leak Rate, Learning Rate, and Thresholds. |
| **6. Speculation** | [Speculative Dynamics](docs/speculative_dynamics.md) | **Future**. Thoughts on advanced behaviors and complex system dynamics. |

## Guides & Examples

### [Pavlovian Conditioning](guides/pavlovian_conditioning/overview.md)
Demonstration of associative learning where the network learns to predict a reward based on a stimulus.
- Run the experiment: `guides/pavlovian_conditioning/experiment.wl`

## File Structure
- `tools/dynamic_topology_neural_nets.wl`: The core source code.
- `tools/generating_random_digraphs.wl`: Helper utility for graph generation.
- `test_run.wl`: A verification script to test basic functionality.
- `docs/`: Documentation folder.
- `guides/`: Step-by-step walkthroughs of specific problems.
- `experiments/`: Raw data and scripts for various experimental setups.
