# Analysis & Intuition Tools

This document describes the library `experiments/analysis_tools.wl`, which provides composable functions for visualizing brain dynamics.

## Philosophy
Instead of running pre-canned "scenarios," these tools are designed to filter and visualize the history of *any* simulation run. This allows you to explore the data from multiple angles.

## API Reference

### 1. Vector History (Arrays)
**`PlotVectorHistory[history, key]`**
- **What it does**: Visualizes a vector property (like "activation" or "biases") as an `ArrayPlot` over time.
- **Axes**: X = Time, Y = Neuron Index.
- **Use case**: Seeing "thoughts" (activation patterns) or "drift" (bias changes).

### 2. Scalar History (Lines)
**`PlotScalarHistory[history, extractor, label]`**
- **What it does**: Applies a function (`extractor`) to every state in history and plots the result.
- **Use case**: Tracking global metrics.
- **Examples**:
    ```wolfram
    (* Track total correlation *)
    PlotScalarHistory[history, Mean[#["activation"]]&, "Mean Activity"]
    
    (* Track structural complexity *)
    PlotScalarHistory[history, EdgeCount[#["network"]]&, "Edges"]
    ```

### 3. Structural Snapshots
**`PlotWeightMatrix[brain]`**
- **What it does**: `MatrixPlot` of synaptic weights.
- **Use case**: Seeing the connectivity structure (diagonal bands, modularity, sparsity).

**`PlotGraphTopology[brain]`**
- **What it does**: `GraphPlot` of the network.

## Usage Example

```wolfram
Get["experiments/analysis_tools.wl"];

(* 1. Run your own custom loop *)
history = NestList[Step[#, input, reward]&, brain, 100];

(* 2. Analyze it *)
activations = PlotVectorHistory[history, "activation"];
edges = PlotScalarHistory[history, EdgeCount[#["network"]]&, "Edge Count"];
```
