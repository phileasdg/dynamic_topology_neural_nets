# Theoretical Rationale: Dynamic Topology Neural Networks

## The Problem with Fixed Topology
Deep Learning has achieved remarkable success with **fixed topology** networks (CNNs, Transformers). However, these architectures are:
1.  **Rigid**: The flow of information is pre-determined by the engineer.
2.  **Inefficient**: They typically rely on dense matrix multiplications, often processing zeros or irrelevant correlations.
3.  **Biologically Implausible**: Biological brains are effectively sparse and **plastic**—they constantly grow and prune connections based on experience.

## The Solution: Structural Plasticity
This project explores **Structural Plasticity**—the ability of the network to change its own wiring diagram.

### 1. Sparse vs. Dense
By allowing the network to start sparse and only grow connections where correlations exist, we aim to find more efficient sub-circuits for specific tasks. This is related to the **Lottery Ticket Hypothesis**, which suggests that dense networks contain sparse subnetworks that can perform just as well. This project effectively searches for those tickets *dynamically* via local rules.

### 2. Hebbian Learning as a Driver for Topology
Donald Hebb's famous axiom: *"Neurons that fire together, wire together."*
In traditional ANNs, this is modeled by changing weights. In this model, we take it literally:
- **Fire together, wire together**: Even if no connection exists, if two neurons are consistently active together (driven by other paths), a synapse should form (`SproutSynapses`).
- **Out of sync, lose your link**: If a connection is not utilized or becomes decorrelated, it should wither and die (`PruneSynapses`).

## Stability & Homeostasis
A major challenge in dynamic networks is **Runaway feedback**.
- If correlations create edges $\to$ edges increase flow $\to$ flow increases correlations... the network explodes.
- **Control Mechanisms**:
    - **Oja's Rule**: Stabilizes weight growth by adding a decay term proportional to $y^2$.
    - **Leaky Integration**: Prevents activation saturation.
    - **Density Limits**: We impose a hard ceiling on connection density to simulate physical space/energy constraints.

## Goal
The ultimate goal is to create a "Liquid Brain" that flows into the shape of the problem it is solving, minimizing energy (edges) while maximizing predictive power.
