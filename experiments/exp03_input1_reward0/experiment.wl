(* ::Package:: *)

(* ::Title:: *)
(*Experiment 3: Latent Learning*)


(* ::Section:: *)
(*Experimental parameters*)


(* ::Text:: *)
(*Input : 1 (Constant Global)*)
(*Reward : 0*)
(*LeakRate : 0.1*)
(*SproutingThreshold : 0.01*)
(*WeightAssignmentFunction : 0.01 (Pioneers)*)
(*Steps : 50*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Item:: *)
(*Activations saturate to input pattern. *)


(* ::Item:: *)
(*Weights don't change (Hebbian learning inactive).*)


(* ::Item:: *)
(*Edges sprout rapidly ($P > \tau$) but remain at pioneer strength ($\delta$).*)


(* ::Subsection:: *)
(*Description*)


(* ::Text:: *)
(*If I feed a strong constant signal but no reward, Hebbian learning is inactive, so weights don't change; however, the Potentiality Matrix will reflect the correlations of the driven activations; if these exceed the threshold, edges will sprout to connect the pattern, but they will remain weak pioneer connections."*)


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


SeedRandom[1234];
ClearAll[brain];
brain = InitializeBrain[{20,2},"InitialActivationFunction"->(RandomVariate[NormalDistribution[0,.25]]&)]
Echo[EdgeCount[brain["network"]], "Initial Edges:"];
Echo[Mean[Abs[brain["activation"]]], "Initial Mean Activation:"];
initialMeanWeight = Mean[Abs[Flatten[Normal[brain["weights"]]]]];

(* Define a Constant Input: All neurons active *)
inputPattern = Table[1, 20];


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
(*1. Raster: Visualizing the global saturation.*)


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


(* ::Text:: *)
(*1. Raster: Visualizing the global activity.*)


raster=Framed[ArrayPlot[history[[All,"activation"]],
	PlotLabel->Style["Activation history (Global Latent)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise this as a time series:*)


activationsPlot=Framed[ListPlot[
	Transpose[history[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activation\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The activations saturated globally, stabilizing around 0.76. This corresponds to Tanh[1.0] (Input=1), as the latent weights are too weak to amplify the signal further. The network is "lighting up" entirely, limited only by the input magnitude.*)


(* ::Subsubsection:: *)
(*Network structure*)


(* ::Text:: *)
(*Question: How did the network structure change over time?*)


(* ::Text:: *)
(*At a glance:*)


With[{
	frames=Normal[Dataset[history][All,"network"]],
	diffs=MapApply[{
		"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
		"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&,Partition[Map[Sort@*EdgeList,history[[All,"network"]]],2,1]]},
	Manipulate[{
		Labeled[frames[[t]],Text[Style["Network at t = "<>ToString[t],14]],Top],
		If[t>1,Labeled[Dataset[Association[diffs[[t-1]]]],Text[Style["Changes since t-1:\n",14]],Top],Nothing]},
		{t,1,50,1}]]


(* ::Text:: *)
(*First and last state network comparison:*)


graphPlot=Rule[
	Labeled[GraphPlot[#1,ImageSize->Small],Text[Style["Start",14]],Top],
	Labeled[GraphPlot[#2,ImageSize->Small],Text[Style["End",14]],Top]]&@@history[[{1,-1},"network"]]


(* ::Text:: *)
(*Edge differences between the first and last graphs: *)


Dataset[Association[{
	"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
	"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&@@
		Map[EdgeList,history[[{1,-1},"network"]]]]]


(* ::Text:: *)
(*Answer: The network became extremely dense. Because all neurons were active, the correlation condition ($P > \tau$) was met for almost every pair of nodes, leading to massive sprouting. The graph effectively transitions toward a complete graph (clique).*)


(* ::Subsubsection:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


edgePlot=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count (Global Sprouting)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->300],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The edge count skyrocketed until it hit the MaxDensity limit or saturated the graph. This demonstrates "Global Latent Learning" - the topology reflects the global correlation of the input.*)


(* ::Subsubsection:: *)
(*Weights*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* ::Text:: *)
(*3. Weights: Did they remain light (latent)?*)


(* ::Text:: *)
(*At a glance:*)


With[{frames=Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic,
		PlotLabel->Style["Neural network weights\n",14]]&,
	Normal[Dataset[history][All,"weights"]]]},
	Manipulate[frames[[t]],{t,1,50,1}]]


(* ::Text:: *)
(*First and last state weight comparison:*)


weightsPlot=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	history[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also track the Total Synaptic Weight to see if the brain is gaining "mass":*)


totalWeightPlot=Framed[
	ListPlot[
		Normal[Dataset[history][All, Total[Flatten[Abs[#"weights"]]]&]],
		PlotLabel->Style["Total Synaptic Weight\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Total Weight",14]},
		PlotStyle->Orange,
		Filling->Axis,ImageSize->300],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Total weight increased due to the sheer number of new edges, but individual edge weights remained at the pioneer level. The "mass" of the brain increased, but the "strength" of individual connections did not traverse the Hebbian learning curve.*)


(* ::Subsection:: *)
(*Export plots:*)


Export["img/activation.png", activationsPlot];
Export["img/raster.png", raster];
Export["img/edge.png", edgePlot];
Export["img/weights.png", weightsPlot];
Export["img/total_weight.png", totalWeightPlot];
Export["img/graph.png", Rasterize[graphPlot]];
Echo["Plots saved."];


(* ::Subsection:: *)
(*Verification of specific claims*)


ClearAll[finalAct, correlation, c1, finalMaxWeight, c2, initialEdges, finalEdges, c3, verificationPassed];


(* ::Subsubsection:: *)
(*Claim 1: Activations saturate globally*)


finalAct = Last[history]["activation"];
(* Check mean activation is high (> 0.7). Tanh[1] ~ 0.76. *)
meanFinalAct = Mean[Abs[finalAct]];
c1 = meanFinalAct > 0.7;

Echo["---------------------------------------------------"];
Echo[meanFinalAct, "Claim 1 Mean Activation (Expected > 0.7): "];
If[c1,
	Echo["[PASS] Claim 1: Activations saturated globally (Tanh limit)."],
	Echo["[FAIL] Claim 1: Activations did not saturate."]
];


(* ::Subsubsection:: *)
(*Claim 2: Weights don't change (Hebbian learning inactive)*)


(* We check if the max weight is still small (pioneer level ~0.01) *)
finalMaxWeight = Max[Abs[Flatten[Normal[Last[history]["weights"]]]]];
(* Use 0.1 as a safe upper bound; pioneers are 0.01 *)
c2 = finalMaxWeight < 0.1; 

Echo["---------------------------------------------------"];
Echo[finalMaxWeight, "Claim 2 Max Weight (Expected < 0.1): "];
If[c2,
	Echo["[PASS] Claim 2: Weights remained latent/pioneer (Individual weights low)."],
	Echo["[FAIL] Claim 2: Weights grew (Hebbian leak?)."]
];


(* ::Subsubsection:: *)
(*Claim 3: Edges sprout globally*)


initialEdges = EdgeCount[brain["network"]];
finalEdges = EdgeCount[Last[history]["network"]];
(* Expect significant growth, e.g., > 50% increase or hitting density cap *)
c3 = finalEdges > initialEdges * 1.5;

Echo["---------------------------------------------------"];
Echo[{initialEdges, finalEdges}, "Claim 3 Edge Change (Expected Significant Increase): "];
If[c3,
	Echo["[PASS] Claim 3: Topology grew significantly (Global Sprouting)."],
	Echo["[FAIL] Claim 3: Topology did not grow significantly."]
];
Echo["---------------------------------------------------"];


verificationPassed = c1 && c2 && c3;


(* ::Subsection:: *)
(*Conclusion*)


If[verificationPassed, 
	Echo["[CONCLUSION] Hypothesis CONFIRMED: Global Latent Learning observed."], 
	Echo["[CONCLUSION] Hypothesis Falsified."]
];

