(* ::Package:: *)

(* ::Title:: *)
(*Experiment 1: Silence*)


(* ::Section:: *)
(*Experimental parameters*)


(* ::Text:: *)
(*System Dynamics Matrix: Input=0, Reward=0*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Item:: *)
(*Weights don't change unless their corresponding edge is pruned or a new edge is sprouted.*)


(* ::Item:: *)
(*Activations leak to zero at the specified LeakRate.*)


(* ::Item:: *)
(*Edges with weights under the SurvivalThreshold are pruned.*)


(* ::Item:: *)
(*Sprouting is active, but unlikely due to the rarity of candidate correlations to turn into edges.*)


(* ::Subsection:: *)
(*Description*)


(* ::Text:: *)
(*If I feed the brain no sensory input and no reward, the existing weights do not undergo Hebbian learning, but the metabolism continues to run, so neuron activations leak at the specified LeakRate; meanwhile, edges under the SurvivalThreshold are pruned, and vertices whose residual activations correlate will sprout new connections with tiny pioneer weights at the specified SproutingRate within the MaxDensity capacity."*)


(* ::Section:: *)
(*Setup*)


(* Set directory to script location *)
If[$InputFileName =!= "", SetDirectory[DirectoryName[$InputFileName]]];
If[$InputFileName === "", SetDirectory[NotebookDirectory[]]];

Echo[Directory[], "Current Directory: "];
Get["../../dynamic_topology_neural_nets.wl"];
Get["../helper_functions.wl"];
Get["../analysis_tools.wl"];


(* ::Section:: *)
(*Initialization*)


(* ::Text:: *)
(*We initialize a random directed Barabasi-Albert graph. This gives us a scale-free structure to start with.*)


SeedRandom[1234];
ClearAll[brain];
brain = InitializeBrain[]
Echo[EdgeCount[brain["network"]], "Initial Edges:"];
Echo[Mean[Abs[brain["activation"]]], "Initial Mean Activation:"];


(* ::Section:: *)
(*Simulation*)


(* ::Text:: *)
(*Run for 50 steps with standard LeakRate (0.1).*)


Echo["Running Simulation..."];
ClearAll[nSteps, history];
nSteps = 50;
history = NestList[
	Step[#, 0, 0, "LeakRate" -> 0.1, "SurvivalThreshold" -> 0.005]&, 
	brain, 
	nSteps
];


(* ::Text:: *)
(*Preview the last brain state of the simulation:*)


Last[history]


(* ::Section:: *)
(*Analysis*)


(* ::Text:: *)
(*We expect that weights should only change as a result of the pruning process. We can inspect this visually and find that this appears to be the case:*)


With[{frames=Map[
	ArrayPlot[#,ImageSize->Medium,PlotLegends->Automatic,PlotLabel->Style["Neural network weights\n",14]]&,
	Normal[Dataset[history][All,"weights"]]]},
	Manipulate[frames[[t]],{t,1,50,1}]]


weightsPlot=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	history[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (50 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We expect that activations should leak to zero, and they do:*)


decayPlot=Framed[ListPlot[
	Transpose[history[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activation decay\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]}],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot like this:*)


raster=Framed[ArrayPlot[history[[All,"activation"]],
	PlotLabel->Style["Activation history:\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We expect that new axons are very unlikely to grow, and that existing weak edges will be pruned, which we can confirm:*)


edgePlot=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Section:: *)
(*Conclusion*)


(* ::Subsection:: *)
(*Export plots:*)


Export["weights.png", weightsPlot];
Export["decay.png", decayPlot];
Export["edge.png", edgePlot];
Export["raster.png", raster];
Echo["Plots saved to experiment folder."];


(* ::Subsection:: *)
(*Verification of specific claims*)


ClearAll[c1, c2, c3, verificationPassed];


(* ::Subsubsection:: *)
(*Claim 1: Activations leak to zero*)


finalActivation = Mean[Abs[Last[history]["activation"]]];
c1 = finalActivation < 0.01;
If[c1, 
	Echo[N[finalActivation], "[PASS] Claim 1: Activations leaked to zero (Final): "],
	Echo[N[finalActivation], "[FAIL] Claim 1: Activations did not leak (Final): "]
];


(* ::Subsubsection:: *)
(*Claim 2: Weights are very stable overall*)


initialMeanWeight = Mean[Abs[Flatten[Normal[brain["weights"]]]]];
finalMeanWeight = Mean[Abs[Flatten[Normal[Last[history]["weights"]]]]];
c2 = finalMeanWeight <= initialMeanWeight * 1.05;
If[c2,
	Echo[N[finalMeanWeight], "[PASS] Claim 2: Weights did not grow (" <> ToString[N[initialMeanWeight]] <> " -> ): "],
	Echo[N[finalMeanWeight], "[FAIL] Claim 2: Weights grew significantly! Final: "]
];


(* ::Subsubsection:: *)
(*Claim 3: Sprouting finds no correlations*)


initialEdges = EdgeCount[brain["network"]];
finalEdges = EdgeCount[Last[history]["network"]];
c3 = finalEdges <= initialEdges;
If[c3,
	Echo[finalEdges, "[PASS] Claim 3: Topology did not grow (" <> ToString[initialEdges] <> " -> ): "],
	Echo[finalEdges, "[FAIL] Claim 3: Topology grew! Sprouting found correlations. Final: "]
];


(* ::Subsection:: *)
(*Results*)


verificationPassed = c1 && c2 && c3;

If[verificationPassed,
	Echo["Hypothesis Behavior CONFIRMED (Metabolic Decay).", "[CONCLUSION] "],
	Echo["Hypothesis Falsified (System did not decay).", "[CONCLUSION] "]
];
