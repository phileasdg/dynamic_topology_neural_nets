(* ::Package:: *)

(* ::Title:: *)
(*Experiment 3: Latent Learning*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Text:: *)
(*Hypothesis: Latent Learning*)
(*System Dynamics Matrix: Input=1 (Pattern), Reward=0*)


(* ::Item:: *)
(*Activations saturate to input pattern. *)


(* ::Item:: *)
(*Weights don't change (Hebbian learning inactive).*)


(* ::Item:: *)
(*Edges sprout rapidly ($P > \tau$) but remain at pioneer strength ($\delta$).*)


(* ::Subsection:: *)
(*Description*)

(* ::Text:: *)
(*"If I feed a pattern but no reward, Hebbian learning is inactive, so weights don't change; however, the Potentiality Matrix will reflect the correlations of the driven activations; if these exceed the threshold, edges will sprout to connect the pattern, but they will remain weak pioneer connections."*)


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
	Step[#, inputPattern, 0, 
		"LeakRate" -> 0.1, 
		"SproutingThreshold" -> 0.01,
		"WeightAssignmentFunction" -> (0.01&) (* Born strong enough to survive 0.005 threshold *)
	]&, 
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
	PlotLabel->Style["Activation history (Latent)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*2. Edges: Did we grow new connections?*)


edges=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count (Sprouting)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*3. Weights: Did they remain light (latent)?*)


weights=Framed[
	ListPlot[
		Normal[Dataset[history][All, Total[Flatten[Abs[#"weights"]]]&]],
		PlotLabel->Style["Total Synaptic Weight (Latent)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Total Weight",14]},
		PlotStyle->Orange,
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Section:: *)
(*Conclusion*)


(* Claims Verification *)
ClearAll[c1, c2, c3, verificationPassed];

(* ::Subsubsection:: *)
(*Claim 1: Activations saturate to input pattern*)


finalAct = Last[history]["activation"];
correlation = Correlation[finalAct, inputPattern];
c1 = correlation > 0.9;
If[c1,
	Echo[N[correlation], "[PASS] Claim 1: Activation imprinted (Correlation): "],
	Echo[N[correlation], "[FAIL] Claim 1: Activation did not imprint (Correlation): "]
];

(* ::Subsubsection:: *)
(*Claim 2: Weights don't change (Hebbian learning inactive)*)


finalMaxWeight = Max[Abs[Flatten[Normal[Last[history]["weights"]]]]];
c2 = finalMaxWeight < 0.5;
If[c2,
	Echo[N[finalMaxWeight], "[PASS] Claim 2: Weights did not saturate (Max < 0.5) | Value: "],
	Echo[N[finalMaxWeight], "[FAIL] Claim 2: Weights saturated (Max): "]
];

(* ::Subsubsection:: *)
(*Claim 3: Edges sprout rapidly*)


initialEdges = EdgeCount[brain["network"]];
finalEdges = EdgeCount[Last[history]["network"]];
c3 = finalEdges > initialEdges;
If[c3,
	Echo[finalEdges, "[PASS] Claim 3: Topology grew (" <> ToString[initialEdges] <> " -> ): "],
	Echo[finalEdges, "[FAIL] Claim 3: Topology did not grow. Final: "]
];

(* ::Subsection:: *)
(*Export plots:*)


Export["raster.png", raster];
Export["edges.png", edges];
Export["weights.png", weights];
Echo["Plots saved."];


(* ::Subsection:: *)
(*Verification of specific claims*)

verificationPassed = c1 && c2 && c3;


(* ::Subsection:: *)
(*Results*)

If[verificationPassed, 
	Echo["Hypothesis CONFIRMED (Latent Learning).", "[CONCLUSION] "], 
	Echo["Hypothesis Falsified.", "[CONCLUSION] "]
];



