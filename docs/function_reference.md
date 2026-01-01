# Function Reference & Design Intuition

This document provides a deep dive into every core function in the codebase. For each function, we explore **how it works** (the mechanism) and **why it exists** (the design intuition).

---

## 1. Initialization

### `InitializeEdgeWeights`
- **Signature**: `InitializeEdgeWeights[graph, distribution]`
- **Mechanism**: Multiplies the binary adjacency matrix of the graph by random values drawn from the `distribution` (default: $\mathcal{N}(0, 0.11)$).
- **Intuition**: We need to break symmetry. If all weights were equal, all neurons would learn the exact same thing. Small random weights allow unique features to emerge. We use a zero-mean distribution so that the network starts in a "neutral" state, ready to be pushed positive or negative by data.

### `FanInNormalize`
- **Signature**: `FanInNormalize[vertexDegrees, weights, scalingFunction]`
- **Mechanism**: Divides the incoming weights of each neuron by $\sqrt{k_{in}}$ (where $k_{in}$ is the number of incoming connections).
- **Intuition**: **Signal Stability**. In a network with variable connectivity (some nodes have 1 input, some have 100), nodes with many inputs would receive massive signals that "blow up" their activation, instantly saturating them at -1 or +1. This prevents any useful information processing (the "vanishing gradient" problem).
- **Why Sqrt?**: Assuming inputs are independent random variables, the variance of the sum scales linearly with $N$. Dividing weights by $\sqrt{N}$ brings the variance of the sum back to 1. This ensures that signals flow through the network at a consistent "volume" regardless of how dense the connections are.

### `NeuralNet`
- **Signature**: `NeuralNet[graph, opts]`
- **Mechanism**: The factory function. It assembles the graph, weights, biases, and state vectors into a single `Association` (the "BrainState"). It also calls `FanInNormalize` during this setup.
- **Intuition**: **Data-Oriented Design**. Instead of having objects with internal state, we bundle the entire state of the simulation into one immutable data structure. This makes debugging trivial—you can inspect the entire brain at any timestep just by looking at this one variable.

---

## 2. Activation Dynamics (The "Mind")

### `PreActivation`
- **Signature**: `PreActivation[brainState]`
- **Mechanism**: Calculates $z = W \cdot A + S \cdot I + b$.
    - $W \cdot A$: Recurrent input from other neurons.
    - $S \cdot I$: Sensory input from the outside world.
    - $b$: Internal bias (threshold).
- **Intuition**: This represents the total electrical potential hitting the neuron's cell membrane. It sums up "what my neighbors are telling me" plus "what I see" plus "how excitable I am (bias)".

### `UpdateActivations`
- **Signature**: `UpdateActivations[brainState, leakRate, activationFunction]`
- **Mechanism**: Applies a **Leaky Integrate-and-Fire** dynamic:
  $$A_{new} = (1 - \lambda)A_{old} + \lambda \cdot \text{Tanh}(z)$$
- **Intuition**: **Temporal Continuity**. Real neurons don't switch states instantly. They have capacitance. The `leakRate` ($\lambda$) determines the time constant of the system.
    - Low $\lambda$: The neuron is "memorious" and slow to change (long-term integration).
    - High $\lambda$: The neuron is "reactive" and follows the input closely.
    - **Why Tanh?**: Only Tanh (or similar sigmoids) squashes the output between -1 and 1. Without this non-linearity, a deep neural network is mathematically equivalent to a single linear layer (useless). Tanh is centered at 0, which helps with keeping weights centered during learning.

---

## 3. Synaptic Plasticity (The "Learning")

### `OjaUpdate`
- **Signature**: `OjaUpdate[weights, activation]`
- **Mechanism**: computes the change in weights $\Delta W$.
  $$ \Delta W = A_{post} \cdot A_{pre} - (A_{post})^2 \cdot W $$
- **Intuition**: **Stability**. Standard Hebbian learning ($A_{post} \cdot A_{pre}$) is unstable—weights grow largely indefinitely ("runaway feedback"). Oja's rule adds a "decay term" proportional to the weight itself and the squared output.
    - If $W$ gets too big, the decay term ($A^2 W$) overpowers the learning term, shrinking the weight.
    - This forces the weight vector to converge to unit length, effectively performing Principal Component Analysis (PCA) on the input stream. It extracts the "most energetic" features of the data without exploding.

### `AdaptWeights`
- **Signature**: `AdaptWeights[brainState, reward, learningRate]`
- **Mechanism**: Applies the `OjaUpdate` scaled by a global `rewardSignal`.
- **Intuition**: **Reinforcement**. We don't just want to learn correlations (unsupervised); we want to learn *useful* correlations. The `rewardSignal` acts as a global modulator (dopamine).
    - High Reward: "Remember what just happened! Wire these neurons together!"
    - Zero/Negative Reward: "Ignore this" or "Unlearn this."

---

## 4. Structural Plasticity (The "Growth")

### `PotentialityMatrix`
- **Signature**: `PotentialityMatrix[brainState]`
- **Mechanism**: Computes $A_i \cdot A_j$ (correlation) for all pairs $(i, j)$ that are **NOT** currently connected.
- **Intuition**: **"What if?"** This matrix asks: "If there *were* a connection here, would it be strengthened?" It identifies "latent synapses"—mental connections that *should* exist because the concepts are related, but don't exist yet.

### `PruneSynapses`
- **Signature**: `PruneSynapses[brainState, threshold]`
- **Mechanism**: Deletes edges where $|w_{ij}| < \theta$.
- **Intuition**: **Energy Conservation**. Maintaining a synapse costs biological energy (or computational memory). If a synapse conveys almost no signal (near-zero weight), it is useless noise. Pruning it frees up resources (density "budget") for new, potentially more useful connections.

### `SproutSynapses`
- **Signature**: `SproutSynapses[brainState, rate, pool_size, ...]`
- **Mechanism**:
    1. Finds "Candidates": Non-existent edges with high potentiality.
    2. Checks "Budget": Allowed max density ($\rho$).
    3. **Competition**: If candidates > specific budget, the strongest potential edges fight the weakest existing edges ("Gladiators"). This ensures the network stays within a fixed complexity bound while constantly rotating in fresh connections.
- **Intuition**: **Exploration**. The network constantly tries out new wiring patterns based on correlations. If a new connection proves useful, it will be strengthened (by Oja's rule) and survive subsequent pruning. If it was a fluke, Oja's rule will drive it to zero, and `PruneSynapses` will kill it. This creates a "Darwinian" evolution of neural circuits inside the brain.

### `Step`
- **Signature**: `Step[...]`
- **Mechanism**: The master wrapper that calls `UpdateActivations`, then `AdaptWeights`, then `PruneSynapses`, then `SproutSynapses`.
- **Intuition**: A single "moment" of time. Note the order:
    1. **Think** (Update Activations)
    2. **Learn** (Adapt weights based on thoughts)
    3. **Evolve** (Change structure based on learning)
