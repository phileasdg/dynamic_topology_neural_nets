(* ::Package:: *)

(* Ensure we are in the script's directory *)
SetDirectory[NotebookDirectory[]];
Get["dynamic_topology_neural_nets.wl"];

SeedRandom[1234];
Print["\n=== Starting Verification Run ==="];


(* Initialization Logic *)
Print["Initializing Brain with BarabasiAlbertGraphDistribution..."];
brain = With[{n = 10, k = 3},
  NeuralNet[
   RandomGraph[BarabasiAlbertGraphDistribution[n, k]] //
     (*Convert edges to directed edges and indexed vertices::*)
     (Graph[Sort[VertexList[#]], MapApply[DirectedEdge, #]] &@
        EdgeList[#] &) //
    (*Delete any existing edges between node 1 and node n:*)
    EdgeDelete[#, _?(MatchQ[#, 
          1 \[DirectedEdge] n | n \[DirectedEdge] 1] &)] &
   ]];

If[FailureQ[brain],
  Print["[Unsuccessful] Failed to initialize brain: ", brain];
  Exit[1];
];

Print["[Success] Brain initialized."];
Print["Vertices: ", VertexCount[brain["network"]]];
Print["Edges: ", EdgeCount[brain["network"]]];
Print["Weights Dimensions: ", Dimensions[brain["weights"]]];


Print["\nRunning single simulation step..."];
(* sensoryInput=0, rewardSignal=1 *)
stepResult = Step[brain, 0, 1]

Print["[Success] Step completed."];
Print["New Edge Count: ", EdgeCount[stepResult["network"]]];
Print["New Weights mean: ", Mean[Flatten[stepResult["weights"]]]];

Print["\n=== Verification Complete ===\n"];



