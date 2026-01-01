(* ::Package:: *)

(* ::Title:: *)
(*Experiment 2: Pure Reinforcement*)


(* ::Section:: *)
(*Experimental parameters*)


(* ::Text:: *)
(*System Dynamics Matrix: Input=0, Reward=1*)


(* ::Section:: *)
(*Hypotheses*)


(* ::Subsection:: *)
(*Testable bullets*)


(* ::Item:: *)
(*Weights will reinforce along internal loops, tending towards saturation. *)


(* ::Item:: *)
(*Neural activations amplify.*)


(* ::Item:: *)
(*Edges sprout to support these self-generated echoes, crowding out others.*)


(* ::Subsection:: *)
(*Description*)


(* ::Text:: *)
(*If I feed the brain no sensory input but provide high reward, the system faces a bifurcation point. If neural activation decay (LeakRate) dominates, the energy dissipates before self-sustaining loops can form. However, if reinforcement (LearningRate) is strong enough to overcome this decay, internal echoes will amplify and the neural activations corresponding to nodes along these pathways will saturate. Since the initial state is random noise, the system effectively learns and reinforces that noise.*)


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


Options[NeuralNet]


(* ::Text:: *)
(*We initialize a random directed Barabasi-Albert graph. This gives us a scale-free structure to start with.*)


SeedRandom[1234];
ClearAll[brain]
brain = InitializeBrain[{20,2},"InitialActivationFunction"->(RandomVariate[NormalDistribution[0,.5]]&)]
Echo[EdgeCount[brain["network"]], "Initial Edges:"];|
Echo[Mean[Abs[brain["activation"]]], "Initial Mean Activation:"];


(* ::Section:: *)
(*Simulation*)


(* ::Text:: *)
(*We will run two scenarios to demonstrate the variable dynamics.*)


(* ::Subsection:: *)
(*Scenario A: Metabolic Stability (High Leak, Low Learning)*)


(* ::Text:: *)
(*Run for 50 steps with LeakRate = 0.15 and LearningRate = 0.01.*)


Echo["Running Scenario A: (high leak, low learning rate)..."];
ClearAll[historyA]
historyA = NestList[
	Step[#, 0, 1, "LeakRate" -> 0.15, "LearningRate" -> 0.01]&, 
	brain, 
	50
];


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


ClearAll[activationsPlotA]
activationsPlotA=Framed[ListPlot[
	Transpose[historyA[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activation decay\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot:*)


ClearAll[rasterA]
rasterA=Framed[ArrayPlot[historyA[[All,"activation"]],
	PlotLabel->Style["Activation history\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The activations all decayed towards zero.*)


(* ::Subsubsection:: *)
(*Network structure*)


(* ::Text:: *)
(*Question: How did the network structure change over time?*)


(* ::Text:: *)
(*At a glance:*)


With[{
	frames=Normal[Dataset[historyA][All,"network"]],
	diffs=MapApply[{
		"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
		"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&,Partition[Map[Sort@*EdgeList,historyA[[All,"network"]]],2,1]]},
	Manipulate[{
		Labeled[frames[[t]],Text[Style["Network at t = "<>ToString[t],14]],Top],
		If[t>1,Labeled[Dataset[Association[diffs[[t-1]]]],Text[Style["Changes since t-1:\n",14]],Top],Nothing]},
		{t,1,50,1}]]


(* ::Text:: *)
(*First and last state network comparison:*)


ClearAll[graphPlotA]
graphPlotA=Rule[
	Labeled[GraphPlot[#1,ImageSize->Small],Text[Style["Start",14]],Top],
	Labeled[GraphPlot[#2,ImageSize->Small],Text[Style["End",14]],Top]]&@@historyA[[{1,-1},"network"]]


(* ::Text:: *)
(*Edge differences between the first and last graphs: *)


Dataset[Association[{
	"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
	"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&@@
		Map[EdgeList,historyA[[{1,-1},"network"]]]]]


(* ::Text:: *)
(*Answer: At step 1, one edge is pruned, and one sprouted. At step 2, one more is sprouted, and at step 7, one more is pruned. Overall, it takes pruning one edge and sprouting another to go from the starting network to the final network.*)


(* ::Subsubsection:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


ClearAll[edgePlotA]
edgePlotA=Framed[
	ListPlot[
		Normal[Dataset[historyA][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The edge count grew by one at step 3 and dropped by one at step 8. There were no further changes to the network's structure throughout the simulation run. The edge count is overall very stable throughout the simulation.*)


(* ::Subsubsection:: *)
(*Weights*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* ::Text:: *)
(*At a glance:*)


With[{frames=Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic,
		PlotLabel->Style["Neural network weights\n",14]]&,
	Normal[Dataset[historyA][All,"weights"]]]},
	Manipulate[frames[[t]],{t,1,50,1}]]


(* ::Text:: *)
(*First and last state weight comparison:*)


ClearAll[weightsPlotA]
weightsPlotA=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyA[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (50 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The weights only changed in the first step as a consequence of edge pruning. They are static throughout the simulation.*)


(* ::Subsection:: *)
(*Scenario B: Runaway Reinforcement (Low Leak, High Learning)*)


(* ::Text:: *)
(*Run for 50 steps with LeakRate = 0.05 and LearningRate = 0.2.*)


Echo["Running Scenario B: Runaway Reinforcement..."];
ClearAll[historyB]
historyB = NestList[
	Step[#, 0, 1, "LeakRate" -> 0.05, "LearningRate" -> 0.2]&, 
	brain, 
	50
];


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


ClearAll[activationsPlotB]
activationsPlotB=Framed[ListPlot[
	Transpose[historyB[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activation bifurcation\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot:*)


ClearAll[rasterB]
rasterB=Framed[ArrayPlot[historyB[[All,"activation"]],
	PlotLabel->Style["Activation history\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: For some neurons, the activations decayed to zero, while for others, activations saturated. This is consistent with our expectation that if reinforcement (LearningRate) overcomes activations decay (LeakRate), activations will amplify along the strongest existing feedback pathways.*)


(* ::Subsubsection:: *)
(*Network structure*)


(* ::Text:: *)
(*Question: How did the network structure change over time?*)


(* ::Text:: *)
(*At a glance:*)


With[{
	frames=Normal[Dataset[historyB][All,"network"]],
	diffs=MapApply[{
		"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
		"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&,Partition[Map[Sort@*EdgeList,historyB[[All,"network"]]],2,1]]},
	Manipulate[{
		Labeled[frames[[t]],Text[Style["Network at t = "<>ToString[t],14]],Top],
		If[t>1,Labeled[Dataset[Association[diffs[[t-1]]]],Text[Style["Changes since t-1:\n",14]],Top],Nothing]},
		{t,1,50,1}]]


(* ::Text:: *)
(*First and last state network comparison:*)


ClearAll[graphPlotB]
graphPlotB=Rule[
	Labeled[GraphPlot[#1,ImageSize->Small],Text[Style["Start",14]],Top],
	Labeled[GraphPlot[#2,ImageSize->Small],Text[Style["End",14]],Top]]&@@historyB[[{1,-1},"network"]]


(* ::Text:: *)
(*Edge differences between the first and last graphs: *)


Dataset[Association[{
	"Edges pruned:"->If[{}==#,None,#]&@Complement[(*at t-1:*)#1,(*at t:*)#2],
	"Edges sprouted:"->If[{}==#,None,#]&@Complement[(*at t:*)#2,(*at t-1:*)#1]}&@@
		Map[EdgeList,historyB[[{1,-1},"network"]]]]]


(* ::Text:: *)
(*Answer: The network structure evolved strong feedback loops. Edges that participate in self-reinforcing loops are strengthened and preserved, while edges that do not contribute to these active pathways are pruned away. Crucially, new edges sprouted to bridge gaps and reinforce these emergent loops, leading to a denser topology centered on the active pathways.*)
(**)
(*Overall, it takes pruning 10 edges and sprouting another 22 to go from the starting network to the final network.*)


(* ::Subsubsection:: *)
(*Edges (axons)*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


ClearAll[edgePlotB]
edgePlotB=Framed[
	ListPlot[
		Normal[Dataset[historyB][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The edge count grew by from 37 to 51 from step 4 to 25. The ascent is punctuated with small dips from steps 11 to 12 and 16 to 18. Between step 30 to 50, the edge count seems to stabilize at 49.*)


(* ::Subsubsection:: *)
(*Weights*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* ::Text:: *)
(*At a glance:*)


With[{frames=Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic,
		PlotLabel->Style["Neural network weights\n",14]]&,
	Normal[Dataset[historyB][All,"weights"]]]},
	Manipulate[frames[[t]],{t,1,50,1}]]


(* ::Text:: *)
(*First and last state weight comparison:*)


ClearAll[weightsPlotB]
weightsPlotB=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyB[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (50 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Weights reinforced along active paths, leading to saturation. Weaker weights were pruned.*)


(* ::Subsection:: *)
(*Comparison*)


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Compare activation time series:*)


ClearAll[compActivations]
compActivations = Framed[
	Labeled[Column[{
		Labeled[
			Framed[activationsPlotA,FrameStyle->LightGray],
			Text[Style["Scenario A",14]], Top], 
		Labeled[
			Framed[activationsPlotB,FrameStyle->LightGray],
			Text[Style["Scenario B",14]], Top]}], 
		Style[Text["Activations plot comparison\n"], 16], Top],
		Background->White, FrameStyle->Transparent]


(* ::Text:: *)
(*Compare rasters:*)


ClearAll[compRasters]
compRasters = Framed[Labeled[Row[{
		Labeled[Framed[rasterA,FrameStyle->LightGray], Text[Style["Scenario A",14]], Top], 
		Labeled[Framed[rasterB,FrameStyle->LightGray], Text[Style["Scenario B",14]], Top]}, Spacer[20]], 
    Text[Style["Spacetime activity scenario comparison\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Edges*)


(* ::Text:: *)
(*Compare edge plots:*)


ClearAll[compEdges]
compEdges = Framed[
	Labeled[Row[{
		Labeled[Framed[edgePlotA,FrameStyle->LightGray], Text[Style["Scenario A",14]], Top], 
		Labeled[Framed[edgePlotB,FrameStyle->LightGray], Text[Style["Scenario B",14]], Top]}, Spacer[20]],
		Text[Style["Topology Growth: Stability vs Runaway Reinforcement\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Weights*)


(* ::Text:: *)
(*Compare weights:*)


ClearAll[compWeights]
compWeights = Framed[
	Labeled[Column[{
		Labeled[Framed[weightsPlotA,FrameStyle->LightGray], Text[Style["Scenario A",14]], Top], 
		Labeled[Framed[weightsPlotB,FrameStyle->LightGray], Text[Style["Scenario B",14]], Top]}, Spacer[20]],
		Text[Style["Weight Evolution: Stability vs Runaway Reinforcement\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Section:: *)
(*Conclusion*)


(* ::Subsection:: *)
(*Export plots*)


(*Export scenario a plots:*)
Export["activationA.png", activationsPlotA];
Export["graphA.png",Rasterize[graphPlotA]];
Export["rasterA.png", rasterA];
Export["edgeA.png", edgePlotA];
Export["weightsA.png", weightsPlotA];

(*Export scenario b plots:*)
Export["activationB.png", activationsPlotB];
Export["graphB.png",Rasterize[graphPlotB]];
Export["rasterB.png", rasterB];
Export["edgeB.png", edgePlotB];
Export["weightsB.png", weightsPlotB];

(*Export comparisons*)
Export["comparison_activations.png", compActivations];
Export["comparison_rasters.png", compRasters];
Export["comparison_edges.png", compEdges];
Export["comparison_weights.png", compWeights];

Echo["Plots saved to experiment folder."];


(* ::Subsection:: *)
(*Verification of specific claims*)


(* ::Text:: *)
(*We want to confirm the our bifurcation hypothesis.*)


(* ::Text:: *)
(*1. Stability (Scenario A) : The system should dissipate energy . Final activation < Initial activation .*)


(* ::Text:: *)
(*2. Runaway Reinforcement (Scenario B) : The system should trap and amplify energy. Significant portion of neurons (> 15 %) should saturate/max out .   *)


ClearAll[initialMagA, finalMagA, decayedA, countSaturated, saturationRatioB, saturatedB, verificationPassed];


(* ::Subsubsection:: *)
(*Scenario A: Metabolic Stability*)


(* ::Text:: *)
(*We check if the mean activation has decayed relative to the initial state.*)


(* 1. Scenario A: Decay Check *)
initialMagA = Mean[Abs[First[historyA]["activation"]]];
finalMagA = Mean[Abs[Last[historyA]["activation"]]];
decayedA = finalMagA < initialMagA;

Echo["---------------------------------------------------"];
Echo[finalMagA, "Scenario A Final Mean Activation (Expected < Initial): "];
If[decayedA, 
	Echo["[PASS] Scenario A: System correctly dissipated energy (Decay observed)."],
	Echo["[FAIL] Scenario A: System failed to decay."]
];


(* ::Subsubsection:: *)
(*Scenario B: Runaway Reinforcement*)


(* ::Text:: *)
(*We check if a significant portion of neurons (> 15%) have saturated (activation > 0.9).*)


(* 2. Scenario B: Saturation Check *)
(* We define 'saturation' as a neuron reaching > 0.9 activation (near the tanh limit of 1.0) *)
countSaturated[state_] := Count[Abs[state["activation"]], a_ /; a > 0.9];
saturationRatioB = countSaturated[Last[historyB]] / VertexCount[First[historyB]["network"]];
(* 
   The threshold (> 15%) is chosen to detect the subset of neurons that have fully saturated (> 0.9) 
   within the 50-step window. Visual inspection of time-series shows a larger portion of the 
   network is recruiting (rising activation) but has not yet crossed the saturation threshold. 
*)
saturatedB = saturationRatioB > 0.15;

Echo["---------------------------------------------------"];
Echo[saturationRatioB, "Scenario B Saturation Ratio (Expected > 0.15): "];
If[saturatedB,
	Echo["[PASS] Scenario B: System correctly entered self-reinforcing state (Runaway Reinforcement observed)."],
	Echo["[FAIL] Scenario B: System failed to saturate."]
];


(* ::Subsubsection:: *)
(*Conclusion*)


(* ::Text:: *)
(*If both scenarios behave as expected, the hypothesis is confirmed.*)


Echo["---------------------------------------------------"];
verificationPassed = decayedA && saturatedB;

If[verificationPassed,
	Echo["[CONCLUSION] Hypothesis CONFIRMED: Dynamics show clear bifurcation between Stability and Runaway Reinforcement."],
	Echo["[CONCLUSION] Hypothesis Falsified: Bifurcation not observed."]
];




