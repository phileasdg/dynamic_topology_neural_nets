# Speculative Dynamics & Behavioral Modes

> [!WARNING]
> This document contains **hypothesized** system behaviors. These dynamics have not yet been fully verified by experiment.

## 6. System Dynamics Matrix
This matrix describes the system's anticipated behavior under various environmental configurations of Sensory Input ($\mathbf{u}$) and Reward ($R$).

| Input ($\mathbf{u}$) | Reward ($R$) | System Behavior & Consequence |
| :--- | :--- | :--- |
| **0 (Silence)** | **0 (None)** | **Metabolic Decay**. Weights don't change. Activations leak to zero. Edges under the threshold are pruned. Sprouting is active but finds no correlations in the silence. |
| **0 (Silence)** | **1 (High)** | **Runaway Hallucination**. Weights reinforcing internal loops grow toward saturation. Activations amplify. Edges sprout to support these self-generated echoes, crowding out others. |
| **0 (Silence)** | **-1 (Punish)** | **Self-Destruction**. Weights in active loops are actively decreased. Activations leak. Residual structures are weakened and pruned. The brain silences itself. |
| **0 (Silence)** | **Random** | **Delirium**. Activations amplify intermittently. Weights fluctuate on residual loops. Anatomy flickers as weak structures form and dissolve. |
| **1 (Pattern)** | **0 (None)** | **Latent Learning**. Activations saturate to input pattern. Weights don't change. Edges sprout rapidly ($P > \tau$) but remain at pioneer strength ($\delta$). |
| **1 (Pattern)** | **1 (High)** | **Hebbian Imprinting**. Activations saturate. Weights grow rapidly toward $\pm 1$. Structure locks the input pattern into physical memory. |
| **1 (Pattern)** | **-1 (Punish)** | **Active Unlearning (Aversion)**. Activation saturates. Weights decreased. Edges connecting pattern are weakened and severed. |
| **1 (Pattern)** | **Random** | **Robustness (Habit)**. Weights fluctuate but trend upward. Structure persists through reward droughts. |
| **-1 (Inhibition)** | **0 (None)** | **Latent Inhibition**. Activations saturate negatively. Double-negative correlations cause sprouting ($P > \tau$). Edges form but remain weak. |
| **-1 (Inhibition)** | **1 (High)** | **Negative Imprinting**. Edges between mutually inhibited neurons form and strengthen. System encodes "absence" or "bad" states. |
| **Random** | **0 (None)** | **Reservoir Generation**. Activations flicker correctly. Weak edges sprout based on accidental correlations -> sparse random graph. |
| **Random** | **1 (High)** | **Superstitious Learning**. Weights jitter wildly on reinforced coincidences. Unstable topology. |

## 6.2 Scenario Narratives

### 1. Silence (Input = 0)
- **Reward = 0**: "If I feed the brain no sensory input and no reward, the existing weights do not undergo Hebbian learning, but the metabolism continues to run, so neuron activations leak at the specified LeakRate; meanwhile, edges under the SurvivalThreshold are pruned, and vertices whose residual activations correlate will sprout new connections with tiny pioneer weights at the specified SproutingRate within the MaxDensity capacity."
- **Reward = 1**: "If I feed the brain no sensory input but provide high reward, any residual activity triggers a positive feedback loop; if this reinforcement strengthens weights faster than the signal decays, internal echoes will amplify and overcome the metabolic LeakRate, causing self-reinforcing loops to dominate while inactive edges are displaced by competitive replacement."

### 2. Pattern (Input = 1)
- **Reward = 1**: "If I feed the brain a consistent pattern and high reward, the existing weights grow rapidly toward saturation, neuron activations saturate to reflect the input, edges become strong and immune to pruning, and vertices whose activations correlate are added and immediately reinforced."
