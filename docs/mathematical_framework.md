# Mathematical Framework: Dynamic Topology Neural Networks

## 1. Introduction: The Living Graph
The network evolves through coupled physiological (fast) and anatomical (slow) timescales. This framework integrates standard neuroscience dynamics with matrix-algebraic constraints for efficient simulation.

### 1.1 The Canonical Alignment Axiom
Vertices are Indices. To prevent physiological drift, the system relies on a single invariant:
- The set of vertices $V$ is the ordered set of integers $\{1, 2, \dots, N\}$.
- Row $i$ of any system matrix strictly corresponds to Vertex $i$.
- All graph operations use `Range[N]` to force this ordering.

## 2. State Variables ($\mathcal{S}_t$)
The state of the network is maintained as an Association containing:
- $\mathbf{x}_t \in [-1, 1]^N$: **Activation** ($a$). Short-term electrochemical state.
- $\mathbf{W}_t \in [-1, 1]^{N \times N}$: **Weights** ($W$). Synaptic strengths.
- $\mathbf{M}_t \in \{0, 1\}^{N \times N}$: **Skeleton** ($network$). The binary anatomy.
- $\mathbf{b} \in \mathbb{R}^N$: **Biases**. Intrinsic excitability.
- $\rho_{max} \in [0, 1]$: **Target Density**. The metabolic ceiling.

## 3. The Transition Cycle

### 3.1 Step 1: Dynamics (Activation)
Signal propagation via Leaky Integration.

**Pre-Activation ($z$)**:
The total input is the sum of recurrent network input, sensory input, and bias.
$$ \mathbf{z}_{t+1} = (\mathbf{W}_t \cdot \mathbf{x}_t) + (\mathbf{s} \circ \mathbf{u}_t) + \mathbf{b} $$

**Activation Update**:
Neurons update their state using a **Leaky Integrate-and-Fire** inspired mechanism.
$$ \mathbf{x}_{t+1} = (1 - \lambda)\mathbf{x}_t + \lambda \sigma(\mathbf{z}_{t+1}) $$
Where:
- $\lambda$: **Leak Rate** (standard range 0.1 - 0.5).
- $\sigma$: Activation function (default `Tanh`).

### 3.2 Step 2: Plasticity (Weights)
We employ local Hebbian learning stabilized by Oja's rule.

**Hebbian Signal**:
$$ \Delta \mathbf{W} = \eta \cdot R_t \cdot (\mathbf{x}\mathbf{x}^T - \text{diag}(\mathbf{x}^2)\mathbf{W}_t) $$
Where:
- $\eta$: **Learning Rate** (Base plasticity).
- $R_t$: **Reward Signal** (Modulator).
- The term $\text{diag}(\mathbf{x}^2)\mathbf{W}$ is the Oja decay term preventing infinite growth.

**Sweeping Mask Invariant**: Memory is accumulated additively, then immediately masked by the anatomy to prevent "Phantom Learning" (weights existing where no edge exists).
$$ \mathbf{W}_{temp} = \mathbf{M}_t \circ (\mathbf{W}_t + \Delta \mathbf{W}) $$

**Hard Clip**: Weights are strictly clamped to range.
$$ \mathbf{W}_{t+1} = \text{Clip}(\mathbf{W}_{temp}, -1, 1) $$

### 3.3 Step 3: Structural Adaptation

#### 3.3.1 Pruning (Synchronous Death)
Synapses that become too weak are removed to conserve resources.
If $|W_{ij}| < \theta_{survival}$:
$$ W_{ij} \to 0 \quad \text{and} \quad M_{ij} \to 0 $$
The edge is removed from the graph.

#### 3.3.2 Sprouting (Competitive Birth)
New synapses can form between unconnected neurons that fire together (Hebbian potentiality).

**Potentiality**: Calculate correlations in the void (non-existent edges):
$$ \mathbf{P} = (1 - \mathbf{M} - \mathbf{I}) \circ (\mathbf{x}\mathbf{x}^T) $$

**Metabolic Budget**: Calculate $E_{max} = \lceil \rho_{max} \cdot N^2 \rceil$.

**The Duel**: If $|E| \ge E_{max}$, a candidate edge $(u,v)$ with potential $P_{uv}$ is instantiated only if it is strictly stronger than the weakest existing edge $(i,j)$.
$$ P_{uv} > \theta_{sprout} \quad \text{and} \quad P_{uv} > |W_{ij}| \implies \text{Prune } (i,j), \text{ Sprout } (u,v) $$

## 4. Hyperparameter Reference

| Symbol | Code Param | Recommended | Role |
| :--- | :--- | :--- | :--- |
| $\lambda$ | `LeakRate` | $0.1 - 0.5$ | Working Memory Decay |
| $\eta$ | `LearningRate` | $0.01 - 0.2$ | Plasticity Speed |
| $R$ | `RewardSignal` | $\pm 1.0$ | Reinforcement Valance |
| $\theta_{survival}$ | `SurvivalThreshold` | $0.005$ | Pruning Cutoff |
| $\theta_{sprout}$ | `SproutingThreshold` | $0.1$ | Growth Cutoff |
| $\rho_{max}$ | `MaxDensity` | $0.5$ | Complexity Limit |
