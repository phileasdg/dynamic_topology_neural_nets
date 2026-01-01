# Dynamic Topology Neural Nets

A Wolfram Language implementation of neural networks that evolve their own topology during learning.

## Quick Start
1.  Open `dynamic_topology_neural_nets.wl` in a notebook.
2.  Run `Get["dynamic_topology_neural_nets.wl"]`.
3.  Initialize a brain: `brain = NeuralNet[RandomGraph[{10, 20}]]`.
4.  Run a step: `newBrain = Step[brain]`.

## Documentation Index

We have structured the documentation to guide you from high-level "Why" to low-level "How".

| Level | Document | Description |
| :--- | :--- | :--- |
| **1. Theory** | [Theoretical Rationale](docs/theoretical_rationale.md) | **Why** are we doing this? Philosophies of Structural Plasticity, sparse networks, and biological inspiration. |
| **2. Architecture** | [Program Architecture](docs/program_architecture.md) | **How** is the program structured? Overview of the "BrainState" data structure and the functional simulation pipeline. |
| **3. Mechanics** | [Function Reference & Intuition](docs/function_reference.md) | **Deep Dive** into every specific function. Explains the exact mechanism and the design intuition behind specific algorithmic choices (e.g., fan-in normalization, Oja's rule). |
| **4. Math** | [Mathematical Model](docs/theory.md) | **Formulas**. The raw LaTeX formulations of the update rules. |

## File Structure
- `dynamic_topology_neural_nets.wl`: The core source code.
- `test_run.wl`: A verification script to test basic functionality.
- `docs/`: Documentation folder.
