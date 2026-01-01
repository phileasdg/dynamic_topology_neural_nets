# Experiment 1: Silence (Input=0, Reward=0)

## Setup
- **Input**: 0 (Sensory Deprivation)
- **Reward**: 0 (Neutrality)
- **Parameters**: 
  - `LeakRate`: 0.1 (Metabolic cost of activity)
  - `SurvivalThreshold`: 0.005 (Pruning weak links)

## Hypothesis: Metabolic Decay
**System Behavior**: Weights don't change. Activations leak to zero. Edges under the threshold are pruned. Sprouting is active but finds no correlations in the silence.

**Narrative**: "If I feed the brain no sensory input and no reward, the existing weights do not undergo Hebbian learning, but the metabolism continues to run, so neuron activations leak at the specified LeakRate; meanwhile, edges under the SurvivalThreshold are pruned, and vertices whose residual activations correlate will sprout new connections with tiny pioneer weights at the specified SproutingRate within the MaxDensity capacity."

## Results
- **Status**: PASSED
- **Observation**: Mean activation decayed to < 0.01. Edge count remained flat or decreased.
