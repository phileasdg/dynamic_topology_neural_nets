Echo[Clip[{-0.5, 0.5, 1.5}], "Clip Default: "];
Echo[Clip[{-0.5, 0.5, 1.5}, {-1, 1}], "Clip Explicit: "];

Get["dynamic_topology_neural_nets.wl"];
brain = NeuralNet[Graph[{1->2}], "InitialActivationFunction"->(1.0&)];

(* Force weight 1->2 to be positive *)
w0 = brain["weights"][[1,2]];
Echo[w0, "Initial Weight: "];

(* Apply Negative Reward *)
(* Step[brain, input, reward, opts] *)
(* Input 0, Reward -1.0, LearningRate 0.1 *)
brainUpdated = Step[brain, {0,0}, -1.0, "LearningRate"->0.1];
w1 = brainUpdated["weights"][[1,2]];

Echo[w1, "Updated Weight (Reward -1): "];
Echo[w1 < w0, "Weight Decreased? "];
