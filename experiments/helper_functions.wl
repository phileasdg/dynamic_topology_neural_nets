(* ::Package:: *)

(* ::Section:: *)
(* Initialization Helpers *)

(* Ensure NeuralNet is defined before calling this *)
ClearAll[InitializeBrain]
InitializeBrain::usage = "InitializeBrain[] created a directed Barabasi-Albert graph with sorted vertices, ensuring no self-loops, and initializes a NeuralNet.";
InitializeBrain[] := With[{n = 20, k = 2},
  NeuralNet[
   (*Generate a Barabasi Albert graph with the chosen parameters:*)
   RandomGraph[BarabasiAlbertGraphDistribution[n, k]] //
     (*Convert edges to directed edges and indexed vertices::*)
     (Graph[Sort[VertexList[#]], MapApply[DirectedEdge, #]] &@
        EdgeList[#] &) //
    (*Delete any existing edges between node 1 and node n:*)
    EdgeDelete[#, _?(MatchQ[#, 
          1 \[DirectedEdge] n | n \[DirectedEdge] 1] &)] &
   ]];
