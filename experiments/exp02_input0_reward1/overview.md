# Experiment 2: Input=0, Reward=1

## Setup
- **Input**: 0 (Sensory Deprivation)
- **Reward**: 1 (Pure Reinforcement)
- **Parameters**: 
  - `LeakRate`: 0.1 (Metabolic cost)
  - `LearningRate`: 0.01 (Hebbian plasticity)

## Hypothesis: Runaway Hallucination
**System Behavior**: Weights reinforcing internal loops grow toward saturation. Activations amplify. Edges sprout to support these self-generated echoes, crowding out others.

**Narrative**: "If I feed the brain no sensory input but provide high reward, any residual activity triggers a positive feedback loop; if this reinforcement strengthens weights faster than the signal decays, internal echoes will amplify and overcome the metabolic LeakRate, causing self-reinforcing loops to dominate while inactive edges are displaced by competitive replacement."

## Results
- **Status**: STABLE (No Hallucination)
- **Observation**: Weights did *not* amplify. The system prioritized energy conservation (decay) over signal amplification.
- **Implication**: To trigger hallucination, one must either:
    1. Drastically increase `LearningRate` (> 0.5?), or
    2. Disable `LeakRate` (0.0).
