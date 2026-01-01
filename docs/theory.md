# Theory & Mathematical Model: Dynamic Topology Neural Nets

## 1. Network Structure
The brain is modeled as a directed graph $G = (V, E)$ where vertices represent neurons and edges represent synapses.

### State Representation
The state of the network is maintained as an Association containing:
- **Network ($G$)**: The graph topology (Adjacency Graph).
- **Weights ($W$)**: A sparse matrix of synaptic weights.
- **Biases ($b$)**: Vector of bias values for each neuron.
- **Activation ($a$)**: Vector of current activation levels for each neuron.
- **Sensory Input ($I$)**: External input vector.
- **Sensory Sensitivity ($S$)**: Vector or scalar modulating input impact.

---

## 2. Initialization

### Topology
The network topology can be initialized using various graph distributions.
- **Barabási-Albert**: Scale-free network generation ($P(k) \sim k^{-3}$), preferentially attaching new nodes to high-degree existing nodes.

### Weight Initialization via Fan-In Normalization
To maintain signal stability, initial weights are normalized based on the fan-in (in-degree) of neurons.
$$ W_{ij} \sim \mathcal{N}(0, \sigma) \cdot \frac{1}{\sqrt{\max(k_{in}, 1)}} $$
This prevents activation explosion/vanishing in early steps, similar to Xavier/He initialization.

---

## 3. Dynamics

### Pre-Activation ($z$)
The total input to a neuron is the sum of recurrent network input, sensory input, and bias.
$$ z = W \cdot a + S \cdot I + b $$

### Activation Update
Neurons update their state using a **Leaky Integrate-and-Fire** inspired mechanism with a continuous activation function (e.g., Tanh).
$$ a_{t+1} = (1 - \lambda) a_t + \lambda \phi(z_t) $$
Where:
- $\lambda$: Leak rate (e.g., 0.1). High $\lambda$ means faster forgetting.
- $\phi$: Activation function (default `Tanh`).

---

## 4. Synaptic Plasticity (Learning)

The network employs local Hebbian learning stabilized by Oja's rule to prevent unbounded weight growth.

### Oja's Rule variant
$$ \Delta W = \eta (a \otimes a - a^2 \odot W) $$
$$ W_{t+1} = \text{Clip}(W_t + R \cdot \Delta W) $$
Where:
- $\eta$: Base learning rate.
- $R$: Reward signal (modulates plasticity).
- $\otimes$: Outer product ($a_i a_j$, Hebbian term).
- $\odot$: Element-wise multiplication.
- $a^2 \odot W$: Decay term ($a_i^2 w_{ij}$), penalizing large weights when activation is high.

---

## 5. Structural Plasticity

The network topology itself evolves over time, allowing the brain to rewire itself.

### Pruning (Synaptic Death)
Synapses that become too weak are removed to conserve resources.
$$ \text{If } |W_{ij}| < \theta_{survival}, \text{ then } W_{ij} \to 0, \text{Edge}_{ij} \to \text{Removed} $$

### Sprouting (Synaptic Birth)
New synapses can form between unconnected neurons that fire together (HeBBian potentiality).

**Potentiality Matrix ($P$)**:
$$ P_{ij} = \begin{cases} a_i a_j & \text{if } (i,j) \notin E \\ 0 & \text{otherwise} \end{cases} $$

**Selection**:
1. Identify **Candidates**: Non-existent edges where $P_{ij} > \theta_{sprout}$.
2. **Cap Density**: Ensure total edges do not exceed density limit ($\rho_{max}$).
3. **Competition**: If candidates > available slots, existing weak edges ("Gladiators") compete with new candidates based on magnitude vs. potential.
4. **Update**: Add stronger candidates, remove weaker existing edges if necessary (homeostatic regulation of density).
