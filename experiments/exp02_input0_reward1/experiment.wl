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
(*If I feed the brain no sensory input but provide high reward, the system faces a bifurcation point. If metabolic decay (LeakRate) dominates, the energy dissipates before self-sustaining loops can form [(metabolic stability)]. However, if reinforcement (LearningRate) is fast enough to overcome decay, internal echoes will amplify into a self-sustaining [seizure] [(runaway hallucination)].*)


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


(* ::Text:: *)
(*We initialize a random directed Barabasi-Albert graph. This gives us a scale-free structure to start with.*)


SeedRandom[1234];
ClearAll[brain];
brain = InitializeBrain["InitialActivationFunction"->(RandomVariate[NormalDistribution[0,.25]]&)]
Echo[EdgeCount[brain["network"]], "Initial Edges:"];
Echo[Mean[Abs[brain["activation"]]], "Initial Mean Activation:"];


initialMeanWeight = Mean[Abs[Flatten[Normal[brain["weights"]]]]];
meanMagStart = initialMeanWeight;


(* ::Section:: *)
(*Simulation*)


(* ::Text:: *)
(*We will run two scenarios to demonstrate the variable dynamics.*)


(* ::Subsection:: *)
(*Scenario A: Metabolic Stability (High Leak, Low Learning)*)


(* ::Text:: *)
(*Run for 50 steps with LeakRate = 0.15 and LearningRate = 0.01.*)


Echo["Running Scenario A: Stability..."];
brainA = InitializeBrain["InitialActivationFunction" -> (RandomReal[{-0.1, 0.1}] &)];
historyA = NestList[
	Step[#, 0, 1, "LeakRate" -> 0.15, "LearningRate" -> 0.01]&, 
	brainA, 
	50
];

rasterA = ArrayPlot[historyA[[All,"activation"]],
	PlotLabel->"Scenario A: Stability\n(Leak=.15, Learn=.01)\n",
	ColorFunction->"ThermometerColors", FrameTicks->None,
	ImageSize->Medium,PlotLegends->Automatic];


(* ::Subsubsection::Closed:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


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


rasterA=Framed[ArrayPlot[historyA[[All,"activation"]],
	PlotLabel->Style["Activation history\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: It seems that they all decayed towards zero.*)


(* ::Subsubsection::Closed:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


edgePlotA=Framed[
	ListPlot[
		Normal[Dataset[historyA][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->300],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Some edges were pruned in the first step. There were no further changes to the network's structure throughout the simulation run.*)


(* ::Subsubsection::Closed:: *)
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


weightsPlotA=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyA[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (50 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The weights only changed in the first step as a consequence of edge pruning. They are static throughout the simulation.*)


(* ::Subsection:: *)
(*Scenario B: Runaway Hallucination (Low Leak, High Learning)*)


(* ::Text:: *)
(*Run for 50 steps with LeakRate = 0.05 and LearningRate = 0.1.*)


Echo["Running Scenario B: Hallucination..."];
brainB = InitializeBrain["InitialActivationFunction" -> (RandomReal[{-0.1, 0.1}] &)];
historyB = NestList[
	Step[#, 0, 1, "LeakRate" -> 0.05, "LearningRate" -> 0.1]&, 
	brainB, 
	50
];

rasterB = ArrayPlot[historyB[[All,"activation"]],
	PlotLabel->"Scenario B: Hallucination\n(Leak=.05, Learn=.1)\n",
	ColorFunction->"ThermometerColors", FrameTicks->None,
	ImageSize->Medium,PlotLegends->Automatic];


(* ::Subsubsection::Closed:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


activationsPlotB=Framed[ListPlot[
	Transpose[historyB[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activation decay\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot:*)


rasterB=Framed[ArrayPlot[historyB[[All,"activation"]],
	PlotLabel->Style["Activation history\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: They still decayed towards zero, but they took longer to do so.*)


(* ::Subsubsection::Closed:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


edgePlotB=Framed[
	ListPlot[
		Normal[Dataset[historyB][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon count\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->300],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Some edges were pruned in the first step. There were no further changes to the network's structure throughout the simulation run.*)


(* ::Subsubsection::Closed:: *)
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


weightsPlotB=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyB[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (50 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The weights only changed in the first step as a consequence of edge pruning. They are static throughout the simulation.*)


(* ::Subsection:: *)
(*Comparison*)


(* ::Subsubsection::Closed:: *)
(*Activations*)


(* ::Text:: *)
(*Compare activation time series:*)


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


compRasters = Framed[Labeled[Row[{
		Labeled[rasterA, Text[Style["Scenario A",14]], Top], 
		Labeled[rasterB, Text[Style["Scenario B",14]], Top]}, Spacer[20]], 
    Text[Style["Spacetime activity scenario comparison\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Subsubsection::Closed:: *)
(*Edges*)


(* ::Text:: *)
(*Compare edge plots:*)


(* Compare Edges *)
compEdges = Framed[
	Labeled[Row[{
		Labeled[edgePlotA, Text[Style["Scenario A",14]], Top], 
		Labeled[edgePlotB, Text[Style["Scenario B",14]], Top]}, Spacer[20]],
		Text[Style["Topology Growth: Stability vs Hallucination\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Subsubsection::Closed:: *)
(*Weights*)


(* Compare Weights *)
compWeights = Framed[
	Labeled[Column[{
		Labeled[weightsPlotA, Text[Style["Scenario A",14]], Top], 
		Labeled[weightsPlotB, Text[Style["Scenario B",14]], Top]}, Spacer[20]],
		Text[Style["Weight Evolution: Stability vs Hallucination\n", 16]], Top],
    Background->White, FrameStyle->Transparent]


(* ::Section:: *)
(*Conclusion*)


(* ::Subsection:: *)
(*Export plots*)


(*Export scenario a plots:*)
Export["activationA.png", activationsPlotA];
Export["rasterA.png", rasterA];
Export["edgeA.png", edgePlotA];
Export["weightsA.png", weightsPlotA];

(*Export scenario b plots:*)
Export["activationB.png", activationsPlotB];
Export["rasterB.png", rasterB];
Export["edgeB.png", edgePlotB];
Export["weightsB.png", weightsPlotB];

(*Export comparisons*)
Export["comparison_activations.png", compActivations];
Export["comparison_rasters.png", compRasters];
Export["comparison_edges.png", compEdges];
Export["comparison_weights.png", compWeights];

Echo["Plots saved to experiment folder."];


(* ::Text:: *)
(*We verify that Scenario A decayed while Scenario B saturated.*)


initialMagA = Mean[Abs[brainA["activation"]]];
finalMagA = Mean[Abs[Last[historyA]["activation"]]];
decayedA = finalMagA < initialMagA;

initialMagB = Mean[Abs[brainB["activation"]]];
finalMagB = Mean[Abs[Last[historyB]["activation"]]];
saturatedB = finalMagB > initialMagB;

Echo[finalMagA, "Scenario A Final Activation (Should be Low): "];
Echo[finalMagB, "Scenario B Final Activation (Should be High): "];

If[decayedA && saturatedB,
	Echo["Hypothesis CONFIRMED: Dynamics depend on critical parameter threshold.", "[CONCLUSION] "],
	Echo["Hypothesis Mixed/Failed.", "[CONCLUSION] "]
];



