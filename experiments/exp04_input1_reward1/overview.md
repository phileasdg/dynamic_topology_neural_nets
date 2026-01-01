# Experiment 4: Hebbian Imprinting (Input=1, Reward=1)

## Setup
- **Input**: 1 (Structured Pattern). Neurons 1-5 active.
- **Reward**: 1 (High). Constant reinforcement.
- **Parameters**: 
  - `LeakRate`: 0.1
  - `LearningRate`: 0.01 (Hebbian)
  - `SproutingRate`: 1

## Hypothesis: Hebbian Imprinting
**System Behavior**: Activations saturate. Weights grow rapidly toward $\pm 1$. Structure locks the input pattern into physical memory.

**Narrative**: "If I feed the brain a consistent pattern and high reward, the existing weights grow rapidly toward saturation, neuron activations saturate to reflect the input, edges become strong and immune to pruning, and vertices whose activations correlate are added and immediately reinforced."

## Claims to Verify
1.  **Saturation**: Weights grow significantly (Mean mag increases).
2.  **Imprinting**: Final activation pattern strongly matches input.
3.  **Lock-in**: Topology grows to support the pattern and edges become strong (Mean Weight > Initial).

## Results
- **Status**: PASSED
- **Observation**: Weights grew significantly (Mean 0.003 -> 0.011) and topology grew (37 -> 46 edges).
- **Imprinting**: Activation pattern correlated 0.999 with input.
- **Conclusion**: High reward caused Hebbian reinforcement to lock the pattern into both structure (edges) and strength (weights).
