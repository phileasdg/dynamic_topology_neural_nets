(* ::Package:: *)

(* ::Title:: *)
(*Analysis Tools*)


(* ::Section:: *)
(*Tools for tracking metrics over time*)


(* ::Text:: *)
(*Plot a scalar value (like total energy or edge count) over the course of the simulation:*)


ClearAll[PlotScalarHistory]
PlotScalarHistory::usage = "PlotScalarHistory[history, extractorFunction, label] plots a scalar metric over time.";
PlotScalarHistory[history_List, extractor_, label_String, color_:Blue] := ListPlot[
  extractor /@ history,
  PlotLabel -> label,
  Frame -> True,
  FrameLabel -> {"Time (Steps)", label},
  PlotStyle -> {Thick, color},
  Joined -> False,
  Background->White,
  ImageSize -> Medium
];


(* ::Section:: *)
(*Tools for visualizing neuron activity patterns*)


(* ::Text:: *)
(*Visualize vector histories (like activation patterns) as a 2D heat map:*)


ClearAll[PlotHistoryHeatmap]
PlotHistoryHeatmap::usage = "PlotHistoryHeatmap[history, key] visualizes the evolution of a vector property (e.g., 'activation') over time as a heatmap.";
PlotHistoryHeatmap[history_List, key_String] := Module[{data},
  (* Extract data: List of Vectors *)
  data = #[[key]] & /@ history;
  
  (* Rows = Time Steps, Cols = Neurons *)
  Labeled[ArrayPlot[data,
   PlotLabel -> Style[Capitalize[key] <> " History\n",14],
   FrameLabel-> {None,Style["Neuron Index",14]},
   ColorFunction -> "TemperatureMap",
   PlotLegends -> Automatic,
   AspectRatio -> True,
   ImageSize -> Medium
   ],Text[Style["Time",14]],Left]
];


(* ::Section:: *)
(*Tools for inspecting brain structure & weights*)


(* ::Text:: *)
(*Plot the adjacency matrix of weights:*)


ClearAll[PlotWeightMatrix]
PlotWeightMatrix::usage = "PlotWeightMatrix[brain] plots the synaptic weight matrix.";
PlotWeightMatrix[brain_Association] := MatrixPlot[
  Normal[brain["weights"]],
  PlotLabel -> "Synaptic Weights",
  ColorFunction -> "TemperatureMap",
  FrameLabel -> {"Post-synaptic (Row)", "Pre-synaptic (Col)"},
  ImageSize -> Medium
];


(* ::Text:: *)
(*Visualize the graph topology directly:*)


ClearAll[PlotGraphTopology]
PlotGraphTopology::usage = "PlotGraphTopology[brain] plots the network graph with edge styling.";
PlotGraphTopology[brain_Association] := GraphPlot[
  brain["network"],
  VertexLabels -> "Name",
  EdgeStyle -> Directive[Arrowheads[Medium], Opacity[0.5]],
  PlotLabel -> "Network Topology",
  ImageSize -> Medium
];



(* ::Section:: *)
(*Tools for generating summary dashboards*)


(* ::Text:: *)
(*Combine multiple plots into a single report column:*)


ClearAll[AnalyzeSimulation]
AnalyzeSimulation::usage = "AnalyzeSimulation[history] generates a dashboard of standard analysis plots.";
AnalyzeSimulation[history_List] := Column[{
   (* 1. Dynamics: Activations *)
   PlotHistoryHeatmap[history, "activation"],
   
   (* 2. Structure: Edge Count *)
   PlotScalarHistory[history, EdgeCount[#["network"]]&, "Edge Count", Red],
   
   (* 3. Energetics: Total Weight *)
   PlotScalarHistory[history, Total[Flatten[Abs[#["weights"]]]]&, "Total Synaptic Weight", Orange]
}, Spacings -> 2];
