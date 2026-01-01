(* ::Package:: *)

(* ::Title:: *)
(*Experiment 4: Hebbian Imprinting*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Text:: *)
(*Hypothesis: Hebbian Imprinting*)
(*System Dynamics Matrix: Input=1 (Pattern), Reward=1*)


(* ::Item:: *)
(*Activations saturate. *)


(* ::Item:: *)
(*Weights grow rapidly toward +/- 1. *)


(* ::Item:: *)
(*Structure locks the input pattern into physical memory.*)


(* ::Subsection:: *)
(*Description*)

(* ::Text:: *)
(*"If I feed the brain a consistent pattern and high reward, the existing weights grow rapidly toward saturation, neuron activations saturate to reflect the input, edges become strong and immune to pruning, and vertices whose activations correlate are added and immediately reinforced."*)


(* ::Section:: *)
(*Setup*)


(* Set directory to script location *)
If[$InputFileName =!= "", SetDirectory[DirectoryName[$InputFileName]]];
If[$InputFileName === "", SetDirectory[NotebookDirectory[]]];

Echo[Directory[], "Current Directory: "];
Get["../../dynamic_topology_neural_nets.wl"];
Get["../helper_functions.wl"];
Get["../analysis_tools.wl"];
SeedRandom[1234];


(* ::Section:: *)
(*Initialization*)


ClearAll[brain];
brain = InitializeBrain[]
Echo[EdgeCount[brain["network"]], "Initial Edges:"];
initialMeanWeight = Mean[Abs[Flatten[Normal[brain["weights"]]]]];

(* Define a Pattern: First 5 neurons active *)
inputPattern = Table[If[i <= 5, 1, 0], {i, 20}];


(* ::Section:: *)
(*Simulation*)


Echo["Running Simulation..."];
ClearAll[nSteps, history];
nSteps = 50;
history = NestList[
	Step[#, inputPattern, 1, "LeakRate" -> 0.1, "LearningRate" -> 0.01]&, 
	brain, 
	nSteps
];

(* ::Text:: *)
(*Preview the last brain state of the simulation:*)


Last[history]


(* ::Section:: *)
(*Analysis*)


(* ::Text:: *)
(*1. Raster: Visualizing the imprinted pattern.*)


raster=Framed[ArrayPlot[history[[All,"activation"]],
	PlotLabel->Style["Activation history (Imprinted)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*2. Weights: Did they grow heavy (Hebbian)?*)


weights=Framed[
	ListPlot[
		Normal[Dataset[history][All, Total[Flatten[Abs[#"weights"]]]&]],
		PlotLabel->Style["Total Synaptic Weight (Hebbian)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Total Weight",14]},
		PlotStyle->Orange,
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*3. Edges: Did we grow new connections?*)


edges=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count (Locked)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Section:: *)
(*Conclusion*)


(* Claims Verification *)
ClearAll[c1, c2, c3, verificationPassed];

(* ::Subsubsection:: *)
(*Claim 1: Weights grow rapidly*)


finalMeanWeight = Mean[Abs[Flatten[Normal[Last[history]["weights"]]]]];
c1 = finalMeanWeight > initialMeanWeight * 1.5;
If[c1,
	Echo[N[finalMeanWeight], "[PASS] Claim 1: Weights grew (" <> ToString[N[initialMeanWeight]] <> " -> ): "],
	Echo[N[finalMeanWeight], "[FAIL] Claim 1: Weights did not grow significantly. Final: "]
];

(* ::Subsubsection:: *)
(*Claim 2: Activations saturate to input pattern*)


finalAct = Last[history]["activation"];
correlation = Correlation[finalAct, inputPattern];
c2 = correlation > 0.9;
If[c2,
	Echo[N[correlation], "[PASS] Claim 2: Activation imprinted (Correlation): "],
	Echo[N[correlation], "[FAIL] Claim 2: Activation did not imprint. Final: "]
];

(* ::Subsubsection:: *)
(*Claim 3: Structure locks (Edges strong)*)


initialEdges = EdgeCount[brain["network"]];
finalEdges = EdgeCount[Last[history]["network"]];
c3 = finalEdges >= initialEdges;
If[c3,
	Echo[finalEdges, "[PASS] Claim 3: Topology verified (" <> ToString[initialEdges] <> " -> ): "],
	Echo[finalEdges, "[FAIL] Claim 3: Topology collapsed. Final: "]
];

(* ::Subsection:: *)
(*Export plots:*)


Export["raster.png", raster];
Export["weights.png", weights];
Export["edges.png", edges];
Echo["Plots saved."];


(* ::Subsection:: *)
(*Verification of specific claims*)

verificationPassed = c1 && c2 && c3;


(* ::Subsection:: *)
(*Results*)

If[verificationPassed, 
	Echo["Hypothesis CONFIRMED (Hebbian Imprinting).", "[CONCLUSION] "], 
	Echo["Hypothesis Falsified.", "[CONCLUSION] "]
];



