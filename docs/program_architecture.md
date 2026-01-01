# Program Architecture & Design

## Overview
This software simulates a **Dynamic Topology Neural Network**. Unlike traditional Artificial Neural Networks (ANNs) where the architecture is fixed and only weights change, this system allows the graph structure itself (connections between neurons) to evolve during simulation.

## Implementation Philosophy
The system is implemented in **Wolfram Language** using a **Functional** and **Data-Oriented** approach.
- **State as Data**: The entire state of the brain is contained in a single immutable `Association` (dictionary).
- **Pure Functions**: The simulation advances via pure functions that map `OldState -> NewState`. There are no global variables or side effects within the core logic.

## Data Structure: The `BrainState`
The core data structure is an Association with the following keys:
- **`"network"`**: A Wolfram `Graph` object representing the current topology.
- **`"weights"`**: A `SparseArray` representing the adjacency matrix weighted by synaptic strength.
- **`"activation"`**: A generic `List` (vector) of current neuron activation levels.
- **`"biases"`**: A vector of bias values.
- **`"sensoryInput"`**: The current external input vector.

## The Simulation Loop
The simulation proceeds in discrete time steps. A single `Step` involves a pipeline of transformations:

1.  **`UpdateActivations`**
    - usage: Integrates inputs and updates neuron states.
    - logic: $A_{new} = (1-\lambda)A_{old} + \lambda \phi(W \cdot A + I)$
    - *Simulates*: Electrical activity / Firing rate.

2.  **`AdaptWeights`**
    - usage: Adjusts synaptic strengths based on activity.
    - logic: Uses **Oja's Rule** (stabilized Hebbian learning) to strengthen connections between correlated neurons.
    - *Simulates*: Long-term Potentiation/Depression (LTP/LTD).

3.  **`PruneSynapses`** (Structural Plasticity - Death)
    - usage: Removes edges from the graph.
    - logic: Edges with weight magnitude below `SurvivalThreshold` are deleted.
    - *Simulates*: Synaptic pruning.

4.  **`SproutSynapses`** (Structural Plasticity - Birth)
    - usage: Adds new edges to the graph.
    - logic:
        - Calculates a "Potentiality Matrix" (Hebbian correlation of *unconnected* nodes).
        - If potential > threshold, a new synapse is formed.
        - Enforces a `MaxDensity` constraint to prevent explosion.
    - *Simulates*: Synaptogenesis.

## Key Functions
- **`NeuralNet`**: Factory function to create the initial `BrainState`.
- **`Step`**: The master pipeline function composing the above steps.
