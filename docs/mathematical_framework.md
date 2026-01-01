# Mathematical Framework: Dynamic Topology Neural Networks

## 1. Introduction: The Living Graph
The network evolves through coupled physiological (fast) and anatomical (slow) timescales.

### 1.1 The Canonical Alignment Axiom
Vertices are Indices. To prevent physiological drift, the system relies on a single invariant:
- The set of vertices $V$ is the ordered set of integers $\{1, 2, \dots, N\}$.
- Row $i$ of any system matrix strictly corresponds to Vertex $i$.
- All graph operations use `Range[N]` to force this ordering.

## 2. State Variables ($\mathcal{S}_t$)
- $\mathbf{x}_t \in [-1, 1]^N$: **Activation**. Short-term electrochemical state.
- $\mathbf{W}_t \in [-1, 1]^{N \times N}$: **Weights**. Synaptic strengths.
- $\mathbf{M}_t \in \{0, 1\}^{N \times N}$: **Skeleton**. The binary anatomy.
- $\rho_{max} \in [0, 1]$: **Target Density**. The metabolic ceiling.

## 3. The Transition Cycle

### 3.1 Step 1: Dynamics (Activation)
Signal propagation via Leaky Integration:
$$ \mathbf{z}_{t+1} = (\mathbf{W}_t \cdot \mathbf{x}_t) + (\mathbf{s} \circ \mathbf{u}_t) + \mathbf{b} $$
$$ \mathbf{x}_{t+1} = (1 - \alpha)\mathbf{x}_t + \alpha \sigma(\mathbf{z}_{t+1}) $$

### 3.2 Step 2: Plasticity (Weights)
Hebbian Signal:
$$ \Delta \mathbf{W} \propto R_t \cdot (\mathbf{x}\mathbf{x}^T - \text{diag}(\mathbf{x}^2)\mathbf{W}) $$

**Sweeping Mask Invariant**: Memory is accumulated additively, then immediately masked by the anatomy to prevent "Phantom Learning."
$$ \mathbf{W}_{temp} = \mathbf{M}_t \circ (\mathbf{W}_t + \Delta \mathbf{W}) $$

**Hard Clip**: Weights are strictly clamped to range.
$$ \mathbf{W}_{t+1} = \text{Clip}(\mathbf{W}_{temp}, -1, 1) $$

### 3.3 Step 3: Structural Adaptation

#### 3.3.1 Pruning (Synchronous Death)
If $|W_{ij}| < \epsilon$:
$$ W_{ij} \to 0 \quad \text{and} \quad M_{ij} \to 0 $$
The edge is removed from $\mathbf{G}$.

#### 3.3.2 Sprouting (Competitive Birth)
**Potentiality**: Calculate correlations in the void:
$$ \mathbf{P} = (1 - \mathbf{M} - \mathbf{I}) \circ (\mathbf{x}\mathbf{x}^T) $$

**Metabolic Budget**: Calculate $E_{max} = \lceil \rho_{max} \cdot N^2 \rceil$.

**The Duel**: If $|E| \ge E_{max}$, a candidate edge $(u,v)$ with potential $P_{uv}$ is instantiated only if it is strictly stronger than the weakest existing edge $(i,j)$.
$$ P_{uv} > |W_{ij}| \implies \text{Prune } (i,j), \text{ Sprout } (u,v) $$

## 4. Hyperparameters

| Symbol | Recommended | Role |
| :--- | :--- | :--- |
| $\alpha$ | $0.1$ | Leakage Rate |
| $\eta$ | $0.01$ | Learning Rate |
| $\epsilon$ | $0.005$ | Survival Threshold |
| $\tau$ | $0.1$ | Sprouting Threshold |
| $\rho_{max}$ | $0.5$ | Max Graph Density |
