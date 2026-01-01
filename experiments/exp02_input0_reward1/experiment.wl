(* ::Package:: *)

(* ::Title:: *)
(*Experiment 2: Pure Reinforcement*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Text:: *)
(*Hypothesis: Runaway Hallucination*)
(*System Dynamics Matrix: Input=0, Reward=1*)


(* ::Item:: *)
(*Weights reinforcing internal loops grow toward saturation. *)


(* ::Item:: *)
(*Activations amplify.*)


(* ::Item:: *)
(*Edges sprout to support these self-generated echoes, crowding out others.*)


(* ::Subsection:: *)
(*Description*)


(* ::Text:: *)
(*"If I feed the brain no sensory input but provide high reward, any residual activity triggers a positive feedback loop; if this reinforcement strengthens weights faster than the signal decays, internal echoes will amplify and overcome the metabolic LeakRate, causing self-reinforcing loops to dominate while inactive edges are displaced by competitive replacement."*)


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
meanMagStart = initialMeanWeight;


(* ::Section:: *)
(*Simulation*)


(* ::Text:: *)
(*Run with standard LeakRate (0.1) and LearningRate (0.01).*)


Echo["Running Simulation..."];
ClearAll[nSteps, history];
nSteps = 50;
history = NestList[
	Step[#, 0, 1, "LeakRate" -> 0.1, "LearningRate" -> 0.01]&, 
	brain, 
	nSteps
];



(* ::Text:: *)
(*Preview the last brain state of the simulation:*)


Last[history]


(* ::Section::Closed:: *)
(*Analysis*)


finalBrain = Last[history];
finalWeights = Flatten[Normal[finalBrain["weights"]]];
meanMagStart = initialMeanWeight;
meanMagEnd = Mean[Abs[finalWeights]];

Echo[ToString[meanMagStart] <> " -> " <> ToString[meanMagEnd], "Mean Weight Mag: "];


(* ::Text:: *)
(*Did the weights polarize, grow, or otherwise change throughout the simulation?*)


weightDistPlot=Framed[PairedHistogram[
	Flatten[Normal[brain["weights"]]], 
	finalWeights, 
	PlotLabel -> Style["Weight shift (start vs end)\n",14],
	Frame->True,
	FrameLabel->{Style["Weight magnitude",14],Style["Count",14]}],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*2. Raster: Are there stable loops?*)


rasterPlot=Framed[ArrayPlot[history[[All,"activation"]],
	PlotLabel->Style["Activation history:\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*3. Edges: Did we grow new connections?*)


edgePlot=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis],
	Background->White,FrameStyle->Transparent]


(* ::Section:: *)
(*Analysis II (TODO)*)


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


(* Verification of Specific Claims *)
(* Note: We expect these to FAIL if the 'Stability' hypothesis is correct over 'Hallucination' *)

ClearAll[c1, c2, c3, verificationPassed];


(* ::Subsubsection:: *)
(*Claim 1: Weights reinforcing internal loops grow toward saturation*)


c1 = meanMagEnd > meanMagStart * 1.1;
If[c1,
	Echo[N[meanMagEnd], "[PASS] Claim 1: Weights grew (" <> ToString[N[meanMagStart]] <> " -> ): "],
	Echo[N[meanMagEnd], "[FAIL] Claim 1: Weights did not grow significantly. Final: "]
];


(* ::Subsubsection:: *)
(*Claim 2: Activations amplify*)


initialActivation = Mean[Abs[brain["activation"]]];
finalActivation = Mean[Abs[Last[history]["activation"]]];
c2 = finalActivation > initialActivation * 1.1;
If[c2,
	Echo[N[finalActivation], "[PASS] Claim 2: Activations amplified (" <> ToString[N[initialActivation]] <> " -> ): "],
	Echo[N[finalActivation], "[FAIL] Claim 2: Activations did not amplify. Final: "]
];


(* ::Subsubsection:: *)
(*Claim 3: Edges sprout to support these self-generated echoes*)


initialEdges = EdgeCount[brain["network"]];
finalEdges = EdgeCount[Last[history]["network"]];
c3 = finalEdges > initialEdges;
If[c3,
	Echo[finalEdges, "[PASS] Claim 3: Topology grew (" <> ToString[initialEdges] <> " -> ): "],
	Echo[finalEdges, "[FAIL] Claim 3: Topology did not grow. Final: "]
];


(* ::Subsection:: *)
(*Export plots:*)


Export["weights.png", weightDistPlot];
Export["raster.png", rasterPlot];
Export["edges.png", edgePlot];
Echo["Plots saved to experiment folder."];


(* ::Subsection:: *)
(*Verification of specific claims*)


verificationPassed = c1 && c2 && c3;


(* ::Subsection:: *)
(*Results*)


If[verificationPassed,
	Echo["'Runaway Hallucination' Hypothesis CONFIRMED.", "[CONCLUSION] "],
	Echo["'Runaway Hallucination' Hypothesis REFUTED.", "[CONCLUSION] "]; 
	Echo["The system exhibited metabolic stability. The default parameters prioritize homeostatic decay over runaway positive feedback.", "Observation: "]
];




