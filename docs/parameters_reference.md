# Parameter Reference

This reference guide details the valid parameter ranges and effects for the Dynamic Topology Neural Nets library.

## 1. Simulation Parameters

### `LearningRate`
*   **Standard Range**: `0.01` to `0.2`
*   **Theoretical Limit**: `(-Infinity, +Infinity)`
    *   *Constraint*: Must be **Positive** for stable learning.
    *   **Negative values**: Mathematically valid input, but causes the Oja stabilization term to flip signs, creating a positive feedback loop that drives weights to infinity (instability).

### `LeakRate`
*   **Standard Range**: `0.1` to `0.5`
*   **Theoretical Limit**: `[0, 1]`
    *   *Constraint*: Must be between 0 and 1 for stable decay.
    *   **< 0**: Causes exponential growth of old state.
    *   **> 1**: Causes state flip and oscillation.

### `RewardSignal`
*   **Standard Range**: `[-5.0, 5.0]` (Typically `+1` for success, `-1` or `-5` for failure)
*   **Theoretical Limit**: `(-Infinity, +Infinity)`
    *   *Effect*: A pure scalar multiplier for the weight update magnitude. 
    *   **Negative Reward**: Reverses the plasticity rule. It weakens connections that were active.

---

## 2. Structural Parameters

### `SurvivalThreshold`
*   **Standard Range**: `0.001` to `0.05`
*   **Theoretical Limit**: `[0, Infinity)`
    *   *Effect*: Weights with magnitude `|w|` below this value are pruned.

### `SproutingThreshold`
*   **Standard Range**: `0.1` to `0.3`
*   **Theoretical Limit**: `[-1, 1]`
    *   *Effect*: Cutoff for Hebbian potential (activity correlation) to form a **NEW** synapse.

### `SproutingRate`
*   **Standard Range**: `1` to `10`
*   **Theoretical Limit**: `[0, Infinity]` (Integer)
    *   *Effect*: Max new synapses created per step.

---

## 3. Signal Parameters

### `Neuron Activations`
*   **Standard Range**: `[-1, 1]` (TanH)

### `SensoryInput`
*   **Standard Range**: `[-1, 1]`

---

## 4. Concept Guide: Core Interactions (Signals, Plasticity, & Weights)

The interaction between neuron states and weights drives the network's logic.

### Signal (State)
*   **Definition**: The current activation value of a neuron (usually between -1 and +1).
*   **Role**: **Information Flow**. It represents the "thought" or data currently passing through the network.
*   **Significance**: A negative signal is not "bad", it is just a value. In a Signed network (Tanh), -1 is as strong as +1.

### Reward (Feedback)
*   **Definition**: A scalar value given to the network after a step.
*   **Role**: **Plasticity Control**. It tells the learning rule whether to reinforce or punish the current activity patterns.
*   **Significance**: A negative reward triggers "unlearning" or "inhibition learning".

### Positive Weights (Correlation)
*   **Definition**: A positive weight (`+1.0`) connects two neurons.
*   **Behavior**: When Neuron A fires, it excites Neuron B.
*   **Role**: **Pattern Matching**. The network sums up evidence. "If I see ears AND tail AND fur, it is a cat."
*   **Double Negative**: Note that if A is -1 and B is -1, they have a positive correlation. They agree.

### Negative Weights (Anti-Correlation / Inhibition)
*   **Definition**: A negative weight (`-1.0`) connects two neurons.
*   **Behavior**: When Neuron A fires, it suppresses (inhibits) Neuron B.
*   **Role**: **Constraint Satisfaction / Logic**.
    *   **Competition**: "If I choose Left, I must NOT choose Right."
    *   **Logic (XOR)**: "If A and B are both on, suppress the output."
    *   **Disinhibition**: "A inhibits B. B inhibits C. Therefore, A essentially excites C."

### Memory: Activations vs Weights

Memory in this system is split into two distinct timescales:

*   **Activations ("Working Memory")**:
    *   **Timescale**: Instantaneous to Short-term (controlled by `LeakRate`).
    *   **Mechanism**: If `LeakRate` is low, a neuron retains its activation state over multiple steps, effectively "remembering" a recent input.
    *   **Analogy**: The numbers currently written on a whiteboard. Wiped easily.

*   **Weights ("Long-Term Memory")**:
    *   **Timescale**: Long-term to Permanent (controlled by `LearningRate`).
    *   **Mechanism**: The physical strength of connections. These persist even if the network is "asleep" (all activations = 0).
    *   **Analogy**: The wiring of the brain itself. Hard to change, lasts forever.

### Learning Processes: Concurrent Dynamics

There are three distinct learning processes running in parallel, each operating at a different speed:

1.  **State Dynamics (Fastest)**
    *   **What it updates**: Neuron **Activations**.
    *   **Mechanism**: `UpdateActivations` (Leaky Integrate-and-Fire).
    *   **Goal**: "Thinking" or Working Memory. Propagating signals momentarily.
    *   **Key Parameter**: `LeakRate` (0 = perfect memory, 1 = instant forgetting).

2.  **Hebbian Plasticity (Medium Speed)**
    *   **What it updates**: Connection **Weights**.
    *   **Mechanism**: `AdaptWeights` (Hebbian + Oja's stabilization).
    *   **Goal**: Encoding correlations and logic ("If A then B").
    *   **Key Parameter**: `LearningRate`, `RewardSignal`.

3.  **Structural Plasticity (Slowest)**
    *   **What it updates**: The **Topology** (Graph Structure).
    *   **Mechanism**: `SproutSynapses` (Growth) and `PruneSynapses` (Death).
    *   **Goal**: Optimizing architecture. Deleting noise and bridging gaps.
    *   **Key Parameters**: `SurvivalThreshold`, `SproutingThreshold`.

| Concept | Positive (+) | Negative (-) | Type |
| :--- | :--- | :--- | :--- |
| **Reward** | "Reinforce this." (Do it again) | "Punish this." (Stop/Invert) | Plasticity |
| **Signal** | "My State is +1." | "My State is -1." | State |
| **Weight** | "I agree with you." (Correlation) | "I oppose you." (Inhibition) | Structure |
