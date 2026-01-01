# Experiment 3: Pattern Learning (Input=1, Reward=0)

## Setup
- **Input**: 1 (Structured Pattern). We will subject the brain to a repeated input vector, e.g., neurons 1-5 active.
- **Reward**: 0 (Neutral). No explicit reinforcement signal.
- **Parameters**: 
  - `LeakRate`: 0.1
  - `SproutingRate`: 1
  - `SproutingThreshold`: 0.1
  - `LearningRate`: 0.01

## Hypothesis: Latent Learning
**System Behavior**: Activations saturate to input pattern. Weights don't change (no reward). Edges sprout rapidly ($P > \tau$) but remain at pioneer strength ($\delta$).

**Narrative**: "If I feed the brain a consistent pattern but no reward, Hebbian learning is inactive, so weights don't change; however, the Potentiality Matrix will reflect the correlations of the driven activations; if these exceed the threshold, edges will sprout to connect the pattern, but they will remain weak pioneer connections."

## Claims to Verify
1.  **Imprinting**: Activation pattern matches input pattern.
2.  **Stagnation**: Weights do *not* grow (Mean mag stable).
3.  **Wiring**: Topology *grows* significantly to connect the active neurons (EdgeCount increases).

## Results
- **Status**: PASSED
- **Observation**: Topology grew significantly (37 -> ~60 edges) to connect the active pattern.
- **Weights**: Remained small (Max < 0.5), confirming that structure can form (Latent Learning) without Hebbian reinforcement (weight saturation).
- **Conclusion**: The brain successfully "paved the road" for the pattern using the potentiality matrix, even without the "asphalt" of reward.
