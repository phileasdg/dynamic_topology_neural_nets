(* ::Package:: *)

(* ::Title:: *)
(*Guide: Pavlovian Conditioning*)


(* ::Section:: *)
(*Experimental parameters*)


(* ::Text:: *)
(*Phases :*)
(*1. Baseline (20 steps) : Random noise input, Reward = 0.*)
(*2. Conditioning (20 steps) : Simultaneously drive the Conditioned Stimulus (CS, e.g. "Bell", Node 1) and Unconditioned Stimulus (US, e.g. "Food", Node N), Reward = 1.*)
(*3. Testing (10 steps) : Pulse CS (Node 1) only, Reward = 0.*)
(**)
(*Parameters :*)
(*Network : 10 Neurons, Barabasi-Albert Scale-Free Graph (k = 3)*)
(*Structure : Edge 1 -> N explicitly removed at start .*)
(*LeakRate : 0.1*)
(*LearningRate : 0.1*)
(*Steps : 50*)
(*InitialActivationFunction: (RandomVariate[NormalDistribution[0, 0.5]] &)*)


(* ::Section:: *)
(*Setup*)


(* Set directory to script location *)
If[$InputFileName =!= "", SetDirectory[DirectoryName[$InputFileName]]];
If[$InputFileName === "", SetDirectory[NotebookDirectory[]]];

Echo[Directory[], "Current Directory: "];
Get["../../dynamic_topology_neural_nets.wl"];
Get["../../experiments/helper_functions.wl"];
Get["../../experiments/analysis_tools.wl"];


(* ::Section:: *)
(*Initialization*)


(* ::Text:: *)
(*We create a small, "lobotomized" brain where Node 1 (CS) and Node N (US) are guaranteed not to have a direct connection initially.*)


SeedRandom[0];
ClearAll[brain, n, k];
n = 10;
k = 3;

(* InitializeBrain automatically removes 1->N and N->1 edges *)
brain = InitializeBrain[{n, k}, 
	"InitialActivationFunction" -> (RandomVariate[NormalDistribution[0, 0.5]] &)]

Echo[EdgeCount[brain["network"]], "Initial Edges:"];


(* ::Section:: *)
(*Protocol*)


ClearAll[inputsA, inputsB, inputsC, allInputs, rewardsA, rewardsB, rewardsC, allRewards];

(* Phase A: Baseline (20 ticks) - Noise *)
inputsA = RandomReal[{0, 0.1}, {20, n}];
rewardsA = ConstantArray[0, 20];

(* Phase B: Conditioning (20 ticks) - Force 1 & N, Reward *)
(* CS = Node 1, US = Node 10. We drive both strong. *)
inputsB = Table[
	ReplacePart[ConstantArray[0., n], {1 -> 1.0, n -> 1.0}] + RandomReal[{-0.05, 0.05}, n], 
	{20}];
rewardsB = ConstantArray[1, 20]; (* Reward high to reinforce the co-activation *)

(* Phase C: Testing (10 ticks) - Pulse 1 only, No Reward *)
(* We pulse the CS (Node 1) to see if it triggers the US (Node 10) via a new path *)
inputsC = Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {60(*10*)}];
rewardsC = ConstantArray[0, 60(*10*)];

(* Combine Protocol *)
allInputs = Join[inputsA, inputsB, inputsC];
allRewards = Join[rewardsA, rewardsB, rewardsC];


(* ::Section:: *)
(*Simulation*)


Echo["Running Conditioning Protocol..."];

ClearAll[history];
history = FoldList[
	Step[#1, #2[[1]], #2[[2]], 
		"LeakRate" -> 0.1, 
		"LearningRate" -> 0.25, (* Strong reinforcement for demonstration *)
		"SproutingThreshold" -> 0.01,
		"WeightAssignmentFunction" -> (0.01&) (* Pioneers born strong enough to survive *)
	]&, 
	brain, 
	Transpose[{allInputs, allRewards}]
];


(* ::Section:: *)
(*Global Dynamics*)


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


ClearAll[activationsPlot]
activationsPlot=Framed[ListPlot[
	Transpose[history[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activations over time\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot:*)


ClearAll[raster]
raster=Framed[ArrayPlot[history[[All,"activation"]],
	PlotLabel->Style["Activation history\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: The raster plot clearly shows the three phases of the experiment. 1) Baseline (first 20 steps): Activations tend towards zero along noisy trajectories. 2) Conditioning (steps 21 to 40): Out of the noise, two horizontal curves shoot up together, corresponding to the CS (Node 1) and US (Node 10) being driven hard. Other neural activations grow as more connections form. 3) Testing (steps 41 to 100): The CS and US activation lines bifurcate, as the CS neuron continues to receive sensory input, and the US neuron fires alongside it, but its activation weakens over time, reaching an apparent fixed point around .73.*)


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
		{t,1,100,1}]]


(* ::Text:: *)
(*First and last state network comparison:*)


ClearAll[graphPlot]
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
(*Answer: For the first 20 ticks (baseline), the number of edges grows, but without a clearly discernible pattern. For the next 20 ticks (conditioning), The overall edge growth rate seems to slow a little, as more edges are pruned than during the previous phase. On the other hand, new edges now seem to be forming in a more orderly way. Finally, in the testing phase, the network enters a limit cycle, pruning one edge to make the other, then pruning the new edge to restore the old one, until the end of the simulation.*)


(* ::Subsubsection:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


ClearAll[edgePlot]
edgePlot=Framed[
	ListPlot[
		Normal[Dataset[history][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: During the baseline phase, from step 2 to 20, edges sprout at a rate of 1 edge per second, from 24 to 41 edges. In the conditioning phase, from step 21 to 40, edges continue to sprout, but edges are pruned more frequently, leading to slower edge count growth. By the end of the conditioning phase, the number of edges has reached a fixed point of 50.*)


(* ::Subsubsection:: *)
(*Weights TODO*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* ::Text:: *)
(*At a glance:*)


With[{frames=Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic,
		PlotLabel->Style["Neural network weights\n",14]]&,
	Normal[Dataset[history][All,"weights"]]]},
	Manipulate[frames[[t]],{t,1,100,1}]]


(* ::Text:: *)
(*First and last state weight comparison:*)


ClearAll[weightsPlot]
weightsPlot=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	history[[{1,-1},"weights"]]],
	Text[Style["Neural network weights at simulation start and end (100 step simulation)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Even some of the weights that were initially the strongest weaken and fade throughout the simulation. On the other hand, the matrix becomes more symmetrical. During the conditioning phase, the edges appear, but the CS and US weights really pick up after the end of the conditioning phase.*)


(* ::Subsection:: *)
(*Pavlovian specifics TODO*)


(* ::Subsubsection:: *)
(*Associative strength (learning curve)*)


(* ::Text:: *)
(*Question: Did the brain learn the specific connection 1 -> N?*)


(* Track the weight of the specific edge 1 -> N and N -> 1 over time *)
weightPath = {Map[#["weights"][[1, n]] &, history],Map[#["weights"][[n, 1]] &, history]};

weightPlot = Framed[
	ListLinePlot[weightPath, 
		PlotLabel -> Style["Neural associative strength\n", 14], 
		Frame -> True, 
		FrameLabel -> {Style["Time", 14], Style["Weight", 14]},
		GridLines -> {{20, 40}, Automatic},  
		ImageSize -> Medium,PlotRange->Full,
		PlotLegends->{"1\[Rule]n","n\[Rule]1"}
	],
	Background -> White, FrameStyle -> Transparent
]


(* ::Text:: *)
(*Answer: The plot tracks the weights of the direct edges between CS (1) an US (10). It is zero during baseline (since the edges don't exist at this point), rises significantly during the conditioning phase (Hebbian learning), and holds steady during Testing (memory retention).*)


(* ::Subsubsection:: *)
(*Anatomy (final state)*)


(* ::Text:: *)
(*Question: Does the final physical structure reflect the learned association?*)


anatomyPlot=Framed[HighlightGraph[history[[-1,"network"]],{1,n,1\[DirectedEdge]n,n\[DirectedEdge]1},
	PlotLabel -> Style["Anatomy after conditioning\n", 14],
	VertexLabels->"Name"],Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*Answer: Yes, as the network did succeed at creating connections between the CS and US neurons, which where initially completely disconnected.*)


(* ::Subsubsection:: *)
(*Activation response (test phase) TODO*)


(* ::Text:: *)
(*Question: Does the brain functionally *behave* as if it has learned?*)


(* Did pulsing Node 1 in Phase C actually fire Node N? *)
(* We look at activations of Node 1 and Node N during the whole run *)
act1 = history[[All, "activation", 1]];
actN = history[[All, "activation", n]];

responsePlot = Framed[
	ListLinePlot[{act1, actN}, 
		PlotLegends -> {"CS (node 1)", "US (node " <> ToString[n] <> ")"},
		PlotLabel -> Style["Neural response\n", 14],
		Frame -> True,
		GridLines -> {{20, 40}, Automatic},
		ImageSize -> Medium
	], 
	Background -> White, FrameStyle -> Transparent
]


(* ::Text:: *)
(*Answer: Yes. In the testing phase, the CS node is pulsed, but the US node is not, and no reward is provided to the network, yet the US node fires at a consistent, sustained rate. The network "hallucinates" US because it was conditioned to associate it with CS. *)


(* ::Subsection:: *)
(*Export plots*)


Export["img/activation.png", activationsPlot];
Export["img/raster.png", raster];
Export["img/graph.png", Rasterize[graphPlot]];
Export["img/edge.png", edgePlot];
Export["img/weights.png", weightsPlot];
Export["img/learning_curve.png", weightPlot];
Export["img/anatomy.png", Rasterize[anatomyPlot]];
Export["img/response.png", responsePlot];
Echo["Plots saved."];


(* ::Subsection:: *)
(*Verification*)


(* 1. Connection Formed: Edge 1->N exists at end *)
finalGraph = history[[-1, "network"]];
hasEdge = MemberQ[EdgeList[finalGraph], 1 \[DirectedEdge] n];

(* 2. Connection Learned: Weight 1->N > 0.15 *)
finalWeight = Last[weightPath[[1]]];
isStrong = finalWeight > 0.15;

(* 3. Response: US (Node N) fires in Phase C (Steps 41-100) when CS is presented *)
(* We check if Node N activation is high during testing *)
avgResponse = Mean[Abs[Take[actN, {41, 100}]]];
responds = avgResponse > 0.5;

Echo["---------------------------------------------------"];
Echo[hasEdge, "Claim 1: Edge 1->N formed: "];
Echo[finalWeight, "Claim 2: Edge 1->N strength (>0.15): "];
Echo[avgResponse, "Claim 3: US Response during Test (>0.5): "];

If[hasEdge && isStrong && responds,
	Echo["[CONCLUSION] Pavlovian Conditioning SUCCESSFUL."],
	Echo["[CONCLUSION] Pavlovian Conditioning FAILED."]
];




