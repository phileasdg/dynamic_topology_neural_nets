(* ::Package:: *)

(* ::Title:: *)
(*Guide: Emergent XOR*)


(* ::Chapter:: *)
(*Experimental parameters*)


(* ::Text:: *)
(*Objective: Test if a random 10-node network can learn XOR logic through reinforcement.*)
(*Comparison: We run two protocols on the same seed brain.*)
(*Protocol A (The Teacher): Phased, Supervised Training (Clamped Outputs).*)
(*Protocol B (The Explorer): Random Noise, Reinforcement Learning (Unsupervised).*)
(*Constraint: 100 Steps Max.*)
(**)
(*Parameters:*)
(*Network: 10 Neurons, Barabasi-Albert (k=3).*)
(*Activation: Tanh (Default).*)
(*LearningRate: 0.2*)
(*LeakRate: 0.1*)
(*SurvivalThreshold: 0.005 (A), 0.001 (B)*)
(*SproutingThreshold: 0.1 (Default)*)
(*WeightAssignmentFunction: 0.001& (Default)*)


(* ::Chapter:: *)
(*Setup*)


If[$InputFileName =!= "", SetDirectory[DirectoryName[$InputFileName]]];
If[$InputFileName === "", SetDirectory[NotebookDirectory[]]];

Echo[Directory[], "Current Directory: "];
Get["../../tools/dynamic_topology_neural_nets.wl"];
Get["../../tools/helper_functions.wl"];


(* ::Chapter:: *)
(*Initialization*)


(* ::Text:: *)
(*Initialize the Brain. We will use this same starting state for both protocols.*)


SeedRandom[1234];
ClearAll[brain, n, k];
n = 10;
k = 3;

(* Random 10-node graph *)
brain = InitializeBrain[{n, k},
	"InitialActivationFunction" -> (RandomVariate[NormalDistribution[0, 0.1]] &)]


(* ::Chapter:: *)
(*Protocol A*)


(* ::Text:: *)
(*## ORIGINAL PROTOCOL ##*)


(*Echo["Starting Protocol A: The Teacher (Phased)..."];

(* Define Phases *)
(* Phase 1: Train A (20 Steps) *)
inputsA1 = Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 10 -> 1.0}], {20}];
rewardsA1 = ConstantArray[1.0, 20];

(* Phase 2: Train B (20 Steps) *)
inputsA2 = Table[ReplacePart[ConstantArray[0., n], {2 -> 1.0, 10 -> 1.0}], {20}];
rewardsA2 = ConstantArray[1.0, 20];

(* Phase 3: Train AB Inhibition (20 Steps) *)
(* Clamped Output ensures Hebbian rule sees (1,1,1). Negative reward flips it to inhibition. *)
inputsA3 = Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0, 10 -> 1.0}], {20}];
rewardsA3 = ConstantArray[-2.0, 20];

(* Phase 4: Test (60 Steps) *)
(* Unclamped testing *)
inputsA4 = Join[
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}],           (* A Only *)
	Table[ReplacePart[ConstantArray[0., n], {2 -> 1.0}], {20}],           (* B Only *)
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0}], {20}]  (* AB *)
];
rewardsA4 = ConstantArray[0., 60];

allInputsA = Join[inputsA1, inputsA2, inputsA3, inputsA4];
allRewardsA = Join[rewardsA1, rewardsA2, rewardsA3, rewardsA4];

(* Run Simulation A *)
ClearAll[historyA];
historyA = FoldList[
	Step[#1, #2[[1]], #2[[2]], 
		"LeakRate" -> 0.1, 
		"LearningRate" -> 0.2
	]&, 
	brain, 
	Transpose[{allInputsA, allRewardsA}]
];

Echo[Length[historyA], "HistoryA Length: "];
Echo[Head[Last[historyA]], "Head of Last HistoryA: "];
If[Head[Last[historyA]] === Association,
	Echo[Keys[Last[historyA]], "Keys: "];
];*)


(* ::Text:: *)
(*## TRYING NEW THINGS ##*)


Echo["Starting Protocol A: The Teacher (Phased)..."];


(* ::Section:: *)
(*Training*)


(* ::Subsection:: *)
(*Phase 1*)


(* Define Phases *)
ClearAll[inputsA1,rewardsA1]
(* Phase 1: Train A (20 Steps) *)
inputsA1 = Table[ReplacePart[ConstantArray[0., n], {2->-1.,1 -> 1., 10 -> 1.}], {20}];
rewardsA1 = ConstantArray[1.0, 20];


ClearAll[historyA1]
historyA1=FoldList[
	Step[#1, #2[[1]], #2[[2]], 
		"LeakRate" -> 0.01, 
		"LearningRate" -> 0.1
	]&, 
	brain, 
	Transpose[{inputsA1, rewardsA1}]
];


(* ::Subsection:: *)
(*Phase 1 training dynamics*)


(* ::Subsubsection::Closed:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


ClearAll[activationsPlot]
activationsPlot=Framed[ListPlot[
	Transpose[historyA1[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activations over time (protocol A)\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium,GridLines->{{20,40,60,80,100},None}],
	Background->White,FrameStyle->Transparent]


ClearAll[raster]
raster=Framed[ArrayPlot[historyA1[[All,"activation"]],
	PlotLabel->Style["Activation history (protocol A)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Subsubsection::Closed:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


ClearAll[edgePlot]
edgePlot=Framed[
	ListPlot[
		Normal[Dataset[historyA1][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time (Teacher)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Subsubsection::Closed:: *)
(*Weights*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* First and last state weight comparison: *)
ClearAll[weightsPlot]
weightsPlot=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyA1[[{1,-1},"weights"]]],
	Text[Style["Weights: Start vs End (Teacher)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Subsection:: *)
(*Phase 2*)


(* Phase 2: Train B (20 Steps) *)
inputsA2 = Table[ReplacePart[ConstantArray[0., n], {1->-1.,2 -> 1., 10 -> 1.}], {20}];
rewardsA2 = ConstantArray[1.0, 20];


(* ::Subsubsection:: *)
(*Phase 3*)


(* Phase 3: Train AB Inhibition (20 Steps) *)
(* Clamped Output ensures Hebbian rule sees (1,1,1). Negative reward flips it to inhibition. *)
inputsA3 = Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0, 10 -> 1.0}], {20}];
rewardsA3 = ConstantArray[-4.0, 20];


(* ::Subsection:: *)
(*Testing*)


(* ::Subsubsection:: *)
(*Input A*)


(* ::Subsubsection:: *)
(*Input B*)


(* ::Subsubsection:: *)
(*Input AB*)


(* Phase 4: Test (60 Steps) *)
(* Unclamped testing *)
inputsA4 = Join[
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}],           (* A Only *)
	Table[ReplacePart[ConstantArray[0., n], {2 -> 1.0}], {20}],           (* B Only *)
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0}], {20}]  (* AB *)
];
rewardsA4 = ConstantArray[0., 60];

allInputsA = Join[inputsA1, inputsA2, inputsA3, inputsA4];
allRewardsA = Join[rewardsA1, rewardsA2, rewardsA3, rewardsA4];

(* Run Simulation A *)
ClearAll[historyA];
historyA = FoldList[
	Step[#1, #2[[1]], #2[[2]], 
		"LeakRate" -> 0.01, 
		"LearningRate" -> 0.1
	]&, 
	brain, 
	Transpose[{allInputsA, allRewardsA}]
];

Echo[Length[historyA], "HistoryA Length: "];
Echo[Head[Last[historyA]], "Head of Last HistoryA: "];
If[Head[Last[historyA]] === Association,
	Echo[Keys[Last[historyA]], "Keys: "]
];


Manipulate[Module[{inputs1,rewards1,inputs2,rewards2,inputs3,rewards3,inputs4,rewards4,allInputs,allRewards,history},(* Define Phases *)
(* Phase 1: Train A (20 Steps) *)
inputs1 = Table[ReplacePart[ConstantArray[0., n], {2->phase1two,1->phase1one,10->phase1ten}], {20}];
rewards1 = ConstantArray[reward1, 20];

(* Phase 2: Train B (20 Steps) *)
inputs2 = Table[ReplacePart[ConstantArray[0., n], {1->phase2one,2->phase2two,10->phase2ten}], {20}];
rewards2 = ConstantArray[reward2, 20];

(* Phase 3: Train AB Inhibition (20 Steps) *)
(* Clamped Output ensures Hebbian rule sees (1,1,1). Negative reward flips it to inhibition. *)
inputs3 = Table[ReplacePart[ConstantArray[0., n], {1->phase3one,2->phase3two,10->phase3ten}], {20}];
rewards3 = ConstantArray[reward3, 20];

(* Phase 4: Test (60 Steps) *)
(* Unclamped testing *)
inputs4 = Join[
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}],           (* A Only *)
	Table[ReplacePart[ConstantArray[0., n], {2 -> 1.0}], {20}],           (* B Only *)
	Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0}], {20}]  (* AB *)
];
rewards4 = ConstantArray[0., 60];

allInputs = Join[inputs1, inputs2, inputs3, inputs4];
allRewards = Join[rewards1, rewards2, rewards3, rewards4];

(* Run Simulation A *)
history = FoldList[
	Step[#1, #2[[1]], #2[[2]], 
		"LeakRate" -> leakRate, 
		"LearningRate" -> learningRate
	]&, 
	brain, 
	Transpose[{allInputs, allRewards}]
]]//Framed[ListPlot[
	Transpose[#[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activations over time (protocol A)\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Large,GridLines->{{20,40,60,80,100},None}],
	Background->White,FrameStyle->Transparent]&,
	Style["Simulation parameters", {Bold,12}],
	{{leakRate,0.01},0,1},
	{{learningRate,0.1},0,1},
	Delimiter,
	Style["Rewards (plasticity control)", {Bold,12}],
	{{reward1, 1.0, "Phase 1 reward"}, -5, 5},
	{{reward2, 1.0, "Phase 2 reward"}, -5, 5},
	{{reward3, -4.0, "Phase 3 reward"}, -5, 5},
	Delimiter,
	Style["Phase 1 inputs (train A)", {Bold,12}],
	{{phase1one,1, "Node 1 input"},-1,1},
	{{phase1two,-1, "Node 2 input"},-1,1},
	{{phase1ten,1, "Target output"},-1,1},
	Delimiter,
	Style["Phase 2 inputs (train B)", {Bold,12}],
	{{phase2one,-1, "Node 1 input"},-1,1},
	{{phase2two,1, "Node 2 input"},-1,1},
	{{phase2ten,1, "Target output"},-1,1},
	Delimiter,
	Style["Phase 3 inputs (train AB)", {Bold,12}],
	{{phase3one,1, "Node 1 input"},-1,1},
	{{phase3two,1, "Node 2 input"},-1,1},
	{{phase3ten,1, "Target output"},-1,1}]


(* ::Section:: *)
(*Testing*)


(* ::Subsection:: *)
(*Phase 1*)


(* ::Subsubsection:: *)
(*Input A*)


Manipulate[
	Module[{network=Last[historyA1],inputs,rewards,history},
		inputs = (*Signal to A:*)Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}];
		rewards = ConstantArray[0., 20];
		history = FoldList[
			Step[#1, #2[[1]], #2[[2]], 
				"LeakRate" -> leakRate, 
				"LearningRate" -> learningRate
			]&, 
			network,
			Transpose[{inputs, rewards}]
		]]//Framed[ListPlot[
		Transpose[#[[All,"activation"]]],
		Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
		PlotLabel->Style["Neural activations over time (protocol A)\n",14],
		Frame->True,
		FrameLabel->{Style["Time",14],Style["Activation",14]},
		PlotRange->All,ImageSize->Medium,GridLines->{{20,40,60,80,100},None}],
		Background->White,FrameStyle->Transparent]&,
		Style["Simulation parameters", {Bold,12}],
	{{leakRate,0.01},0,1},
	{{learningRate,0.1},0,1}]


Manipulate[
	Module[{inputs,rewards,history},(* Define Phases *)
		inputs = (*Signal to A:*)Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}];
		rewards = ConstantArray[0., 20];
		
		(* Run Simulation A *)
		history = FoldList[
			Step[#1, #2[[1]], #2[[2]], 
				"LeakRate" -> leakRate, 
				"LearningRate" -> learningRate
			]&, 
			<|#,"activation"->0*#activation|>&@Last[historyA1], 
			Transpose[{inputs, rewards}]
		]]//Framed[ListPlot[
		Transpose[#[[All,"activation"]]],
		Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
		PlotLabel->Style["Neural activations over time (protocol A)\n",14],
		Frame->True,
		FrameLabel->{Style["Time",14],Style["Activation",14]},
		PlotRange->All,ImageSize->Medium,GridLines->{{20,40,60,80,100},None}],
		Background->White,FrameStyle->Transparent]&,
		Style["Simulation parameters", {Bold,12}],
	{{leakRate,0.01},0,1},
	{{learningRate,0.1},0,1}]


<|#,"activation"->0*#activation|>&@Last[historyA1]


Manipulate[
	Module[{inputs,rewards,history},(* Define Phases *)
		inputs = Join[
			(*Input A only:*)Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0}], {20}]
			(*Table[ReplacePart[ConstantArray[0., n], {2 -> 1.0}], {20}],           (* B Only *)
			Table[ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0}], {20}]  (* AB *)*)
		];
		rewards = ConstantArray[0., 20];
		
		(* Run Simulation A *)
		history = FoldList[
			Step[#1, #2[[1]], #2[[2]], 
				"LeakRate" -> leakRate, 
				"LearningRate" -> learningRate
			]&, 
			brain, 
			Transpose[{inputs, rewards}]
		]]//Framed[ListPlot[
		Transpose[#[[All,"activation"]]],
		Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
		PlotLabel->Style["Neural activations over time (protocol A)\n",14],
		Frame->True,
		FrameLabel->{Style["Time",14],Style["Activation",14]},
		PlotRange->All,ImageSize->Medium,GridLines->{{20,40,60,80,100},None}],
		Background->White,FrameStyle->Transparent]&,
		Style["Simulation parameters", {Bold,12}],
	{{leakRate,0.01},0,1},
	{{learningRate,0.1},0,1}]


(* ::Section::Closed:: *)
(*Global Dynamics (Protocol A: The Teacher)*)


(* ::Subsubsection:: *)
(*Activations*)


(* ::Text:: *)
(*Question: In this scenario, how did the activations change over time? *)


ClearAll[activationsPlot]
activationsPlot=Framed[ListPlot[
	Transpose[historyA[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activations over time (protocol A)\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium,GridLines->{{20,40,60,80,100},None}],
	Background->White,FrameStyle->Transparent]


(* ::Text:: *)
(*We can also visualise the evolution of neural activations as a spacetime plot:*)


ClearAll[raster]
raster=Framed[ArrayPlot[historyA[[All,"activation"]],
	PlotLabel->Style["Activation history (protocol A)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Edges*)


(* ::Text:: *)
(*Question: How did the number of edges change over time?*)


ClearAll[edgePlot]
edgePlot=Framed[
	ListPlot[
		Normal[Dataset[historyA][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time (Teacher)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Weights*)


(* ::Text:: *)
(*Question: How did the weights evolve throughout the simulation?*)


(* First and last state weight comparison: *)
ClearAll[weightsPlot]
weightsPlot=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyA[[{1,-1},"weights"]]],
	Text[Style["Weights: Start vs End (Teacher)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Section::Closed:: *)
(*Protocol B: The Explorer*)


Echo["Starting Protocol B: The Explorer (Noise/RL)..."];

(* Variable 'brain' is still the initial state here because FoldList didn't mutate it. *)
historyB = {brain};
inputsBList = {};   (* Keeping for analysis *)
rewardsBList = {};  (* Keeping for analysis *)

Do[
	(* 1. Pick Scenario (A, B, AB, or Silence) *)
	r = RandomReal[];
	currentInput = If[r < 0.25,
		ReplacePart[ConstantArray[0., n], {1 -> 1.0}], (* A *)
		If[r < 0.5,
			ReplacePart[ConstantArray[0., n], {2 -> 1.0}], (* B *)
			If[r < 0.75,
				ReplacePart[ConstantArray[0., n], {1 -> 1.0, 2 -> 1.0}], (* AB *)
				ConstantArray[0., n] (* Silence *)
			]
		]
	];
	
	(* Add Noise *)
	currentInput = currentInput + RandomReal[{-0.05, 0.05}, n];
	
	(* 2. Manual Step Construction for RL *)
	
	(* A. Update Activations (Forward Pass) *)
	(* We modify 'brain' temporarily to check activation *)
	tempBrain = Append[brain, "sensoryInput" -> currentInput];
	tempBrain = UpdateActivations[tempBrain, 0.1]; (* LeakRate *)
	
	(* B. Calculate Reward based on Output(10) *)
	out = tempBrain["activation"][[10]];
	in1 = currentInput[[1]];
	in2 = currentInput[[2]];
	
	currentReward = 0.;
	
	(* Logic: *)
	(* A=High, B=Low, Out=High -> +1 *)
	(* A=Low, B=High, Out=High -> +1 *)
	(* A=High, B=High, Out=High -> -5 *)
	
	If[in1 > 0.5 && in2 < 0.5 && out > 0.5, currentReward = 1.0];
	If[in1 < 0.5 && in2 > 0.5 && out > 0.5, currentReward = 1.0];
	If[in1 > 0.5 && in2 > 0.5 && out > 0.5, currentReward = -4.0];
	
	(* C. Update Weights (Backward Pass) *)
	(* We use the library function AdaptWeights *)
	newBrain = AdaptWeights[tempBrain, currentReward, 0.2]; (* LearningRate *)
	
	(* D. Prune *)
	newBrain = PruneSynapses[newBrain, 0.001]; (* SurvivalThreshold *)
	
	(* Store *)
	brain = newBrain;
	AppendTo[historyB, brain];
	
, {100}]; (* 100 Steps *)


(* ::Section:: *)
(*Global Dynamics (Protocol B: The Explorer)*)


(* ::Subsubsection:: *)
(*Activations*)


ClearAll[activationsPlotB]
activationsPlotB=Framed[ListPlot[
	Transpose[historyB[[All,"activation"]]],
	Joined->True,PlotLegends->Range[VertexCount[brain["network"]]],
	PlotLabel->Style["Neural activations over time (Explorer)\n",14],
	Frame->True,
	FrameLabel->{Style["Time",14],Style["Activation",14]},
	PlotRange->All,ImageSize->Medium],
	Background->White,FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Raster*)


ClearAll[rasterB]
rasterB=Framed[ArrayPlot[historyB[[All,"activation"]],
	PlotLabel->Style["Activation history (Explorer)\n",14],
	FrameLabel->{Style["Time",14],Style["Neuron index",14]},
	ColorFunction->"ThermometerColors",FrameTicks->{True,False},
	ImageSize->Medium,PlotLegends->Automatic],Background->White,FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Edges*)


ClearAll[edgePlotB]
edgePlotB=Framed[
	ListPlot[
		Normal[Dataset[historyB][All,EdgeCount[#"network"]&]],
		PlotLabel->Style["Axon (edge) count over time (Explorer)\n",14],
		Frame->True,FrameLabel->{Style["Time",14],Style["Edge count",14]},
		Filling->Axis,ImageSize->280],
	Background->White,FrameStyle->Transparent]


(* ::Subsubsection:: *)
(*Weights*)


ClearAll[weightsPlotB]
weightsPlotB=Framed[Labeled[(#1->#2)&@@Map[
	ArrayPlot[#,ImageSize->Small,PlotLegends->Automatic]&,
	historyB[[{1,-1},"weights"]]],
	Text[Style["Weights: Start vs End (Explorer)\n",14]],Top],
	Background->White,FrameStyle->Transparent]


(* ::Section:: *)
(*Comparison Analysis*)


(* ::Subsubsection::Closed:: *)
(*Response Check (Ends of Simulation)*)


(* ::Text:: *)
(*Question: Did either protocol succeed in teaching the network the XOR logic?*)
(*Success Criteria: A > 0.5, B > 0.5, A+B < 0.2*)


(* Protocol A Final Stats *)
dataA_A = Map[#["activation"][[10]] &, historyA[[62;;73]]];
Echo[First[dataA_A], "First A_A Sample: "];
(* Protocol A Final Stats *)
(* Using Table loop to avoid Map issues *)
respA_A = Mean[Table[historyA[[i]]["activation"][[10]], {i, 62, 73}]];
Echo[respA_A, "RespA_A: "];

respA_B = Mean[Table[historyA[[i]]["activation"][[10]], {i, 75, 86}]];
respA_AB = Mean[Table[historyA[[i]]["activation"][[10]], {i, 88, 100}]];

(* Protocol B Final Test (We need to run a clean test phase for B) *)
(* running 20 extra steps just for measurement, not training *)
testBrainB = Last[historyB];
testHistoryB = FoldList[
	Step[#1, #2[[1]], 0. (* No Reward *), "LeakRate"->0.1]&, 
	testBrainB, 
	Transpose[{inputsA4, ConstantArray[0, 40]}] (* Reuse A's test sequence *)
];

respB_A = Mean[Table[testHistoryB[[i]]["activation"][[10]], {i, 2, 14}]];
respB_B = Mean[Table[testHistoryB[[i]]["activation"][[10]], {i, 15, 27}]];
respB_AB = Mean[Table[testHistoryB[[i]]["activation"][[10]], {i, 28, 41}]];


(* ::Text:: *)
(*Comparison Table*)


Echo["---------------------------------------------------"];
Echo["RESULTS (Teacher vs Explorer)"];
Echo["---------------------------------------------------"];
Echo[{"Metric", "Teacher (A)", "Explorer (B)"}];
Echo[{"Response A", respA_A, respB_A}];
Echo[{"Response B", respA_B, respB_B}];
Echo[{"Response AB", respA_AB, respB_AB}];
Echo["---------------------------------------------------"];



(* ::Subsubsection::Closed:: *)
(*Visualizations*)


(* ::Text:: *)
(*Question: How does the "Knowledge" accumulate in each protocol?*)
(*Teacher: Expect sharp, stepped improvements as phases change.*)
(*Explorer: Expect noisy, gradual adaptation (or failure).*)


(* 1. Learning Curve Comparison (Output activity over time) *)
activationsA = historyA[[All, "activation", 10]];
activationsB = historyB[[All, "activation", 10]];

learningCurvePlot = Framed[
	ListLinePlot[{activationsA, activationsB}, 
		PlotLegends -> {"Teacher (Phased)", "Explorer (RL)"},
		PlotLabel -> Style["Output Activity during Training\n", 14], 
		Frame -> True, 
		GridLines -> Automatic, 
		ImageSize -> Medium
	],
	Background -> White, FrameStyle -> Transparent
]


(* ::Text:: *)
(*Question: Do they solve it the same way?*)
(*We track the growth of the direct A -> Output connections. In the Explorer, do these connections struggle to form against the noise?*)


(* 2. Weight Evolution (Input->Output) *)
weightA1 = Map[#["weights"][[1, 10]] &, historyA];
weightA2 = Map[#["weights"][[2, 10]] &, historyA];
weightB1 = Map[#["weights"][[1, 10]] &, historyB];
weightB2 = Map[#["weights"][[2, 10]] &, historyB];

weightsCompPlot = Framed[
	ListLinePlot[{weightA1, weightB1}, 
		PlotLegends -> {"Teacher A->Out", "Explorer A->Out"},
		PlotLabel -> Style["Weight Evolution (A -> Out)\n", 14], 
		Frame -> True, 
		ImageSize -> Medium
	],
	Background -> White, FrameStyle -> Transparent
]

(* Export *)
Export["img/xor_learning_curve.png", learningCurvePlot];
Export["img/xor_weights_comp.png", weightsCompPlot];
Export["img/activation.png", activationsPlot];
Export["img/raster.png", raster];
Export["img/edge.png", edgePlot];
Export["img/weights.png", weightsPlot];

Export["img/activation_B.png", activationsPlotB];
Export["img/raster_B.png", rasterB];
Export["img/edge_B.png", edgePlotB];
Export["img/weights_B.png", weightsPlotB];

Echo["Plots saved."];






