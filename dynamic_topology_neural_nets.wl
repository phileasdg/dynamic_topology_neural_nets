(* ::Package:: *)

(* ::Subsection:: *)
(*Network initialisation*)


(* ::Text:: *)
(*Generate random initial edge weights from a chosen statistical distribution:*)


ClearAll[InitializeEdgeWeights]
InitializeEdgeWeights::usage = "InitializeEdgeWeights[graph, distribution] generates random initial edge weights for a graph based on a statistical distribution.";
InitializeEdgeWeights[g_Graph,distribution_:NormalDistribution[0,0.11]]:=
	With[{adj=AdjacencyMatrix[g]},adj*RandomVariate[distribution,Dimensions[adj]]]


(* ::Text:: *)
(*Fan-in normalization (initial penalty to higher degree nodes):*)


ClearAll[FanInNormalize]
FanInNormalize::usage = "FanInNormalize[vertexDegrees, weights, scalingFunction] normalizes weights based on the fan-in (degree) of the target neurons to stabilize signal propagation.";
FanInNormalize[vertexDegrees_List,weights_?ArrayQ,scalingFunction_:(*Xavier/He initialization*)Sqrt]:=
	SparseArray[MapIndexed[1/scalingFunction[Max[Extract[vertexDegrees,#2],1]]*#1&,weights]]


(* ::Text:: *)
(*Neural network state representation:*)


ClearAll[NeuralNet]
NeuralNet::usage = "NeuralNet[graph, opts] initializes a new neural network state association from a graph topology.";

Options[NeuralNet]={"Biases"->0,"SensorySensitivity"->1,"SensoryInput"->0,"MaxDensity"->.5};

NeuralNet[network_Graph/;VertexList[network]===Range[VertexCount[network]],OptionsPattern[]]:=AssociationThread[
	{"network","weights","biases","activation",(*"networkSkeleton",*)"sensorySensitivity","sensoryInput","maxDensity"},
	{network,
	(*Initial weights are random gaussian variables around zero:*)
	FanInNormalize[VertexDegree[network],InitializeEdgeWeights[network]],
	(*Initial bias is 0:*)OptionValue["Biases"],
	(*Initial activations are either zero or noise:*)(*Table[0,VertexCount[network]]*)RandomVariate[NormalDistribution[0,.25],VertexCount[network]],
	(*(*The network skeleton is the the adjacency matrix of the network:*)AdjacencyMatrix[network],*)
	(*Default sensory sensitivity is 1/1 signal received to signal perceived for all neurons:*)OptionValue["SensorySensitivity"],
	(*Default sensory input is 0:*)0,
	(*Default density is .5:*)OptionValue["MaxDensity"]
	}]
	



(* ::Subsection:: *)
(*Neural pulses*)


(* ::Text:: *)
(*Compute the pre-activation of... [TODO: write this bit]*)


ClearAll[PreActivation]
PreActivation::usage = "PreActivation[brainState] computes the total input z = W.a + S.I + b for all neurons.";
PreActivation[brainState_Association]:=(brainState["weights"] . brainState["activation"])+
	(brainState["sensorySensitivity"]*brainState["sensoryInput"])+brainState["biases"]


(* ::Text:: *)
(*Update activation via leaky integration:*)


ClearAll[UpdateActivations]
UpdateActivations::usage = "UpdateActivations[brainState, leakRate, activationFunction] updates neuron activations using a leaky integrate-and-fire dynamic.";
UpdateActivations[brainState_Association,Optional[leakRate_?NumericQ,.1],activationFunction_:Tanh]:=<|#,
	"activation"->(1-leakRate)#activation+leakRate*activationFunction[PreActivation[#]]|>&@brainState


(* ::Subsection:: *)
(*Hebbian learning*)


(* ::Text:: *)
(*Local learning (Hebbian) with Oja's rule:*)


ClearAll[OjaUpdate]
OjaUpdate::usage = "OjaUpdate[weights, activation] computes the weight update matrix using a Hebbian rule stabilized by Oja's decay term.";
OjaUpdate[weights_?ArrayQ,activation_List]:=(*Hebbian learning:*)Outer[Times,activation,activation]-(*Oja stabilisation:*)(activation^2 weights)


(* ::Text:: *)
(*Trace:*)


ClearAll[AdaptWeights]
AdaptWeights::usage = "AdaptWeights[brainState, reward, learningRate] applies the plasticity update to the network weights.";
AdaptWeights[brainState_Association,Optional[rewardSignal_?NumericQ,0],Optional[learningRate_?NumericQ,.01]]:=<|#,
	"weights"->Clip[AdjacencyMatrix[#network](#weights+(rewardSignal*learningRate*OjaUpdate[#weights,#activation]))]|>&@brainState


(* ::Subsection:: *)
(*Structural neural network adaptation*)


(* ::Subsubsection:: *)
(*Pruning (synaptic death)*)


(* ::Text:: *)
(*Prune weak synapses:*)


ClearAll[PruneSynapses]
PruneSynapses::usage = "PruneSynapses[brainState, threshold] removes synapses (edges) whose weight magnitude falls below the survival threshold.";
PruneSynapses[brainState_Association,Optional[survivalThreshold_?NumericQ,.005]]:=With[
	{survivalMask=UnitStep[Abs[brainState["weights"]]-survivalThreshold]},
	<|#,"network"->AdjacencyGraph[VertexList[#network],survivalMask],"weights"->#weights*survivalMask(*,"networkSkeleton"->survivalMask*)|>&@brainState]


(* ::Subsubsection:: *)
(*Sprouting (synaptic birth)*)


(* ::CodeText:: *)
(*Compute the potentiality matrix: *)


ClearAll[PotentialityMatrix]
PotentialityMatrix::usage = "PotentialityMatrix[brainState] computes the Hebbian potential (activation outer product) for all non-existent edges.";
PotentialityMatrix[brainState_]:=With[
	{nonEdgeMask=1-AdjacencyMatrix[brainState["network"]]-IdentityMatrix[VertexCount[brainState["network"]]]},
	nonEdgeMask*Outer[Times,brainState["activation"],brainState["activation"]]]


(* ::CodeText:: *)
(*Sprout new synapses:*)


ClearAll[SproutSynapses];
SproutSynapses::usage = "SproutSynapses[brainState, rate, threshold] adds new synapses based on the potentiality matrix, respecting the maximum density constraint.";
SproutSynapses[brainState_Association,Optional[sproutingRate_?NumericQ,1],Optional[sproutingThreshold_?NumericQ,.1],weightAssignmentFunction_:(0.001&)]:=Module[{w,net,n,maxEdges,rawCandidates,currentEdgeCount,overflow,gladiators,arena,survivors,toAdd,toKill,newW,newNet},newW=brainState["weights"];
	newNet=brainState["network"];
	n=Length[brainState["activation"]];
	(*1. Calculate Ceiling*)
	maxEdges=Ceiling[brainState["maxDensity"]*n^2];
	(*2. Identify Candidates (The Void)*)(*Using Normal[] to ensure we map over zeros correctly*)
	rawCandidates=Select[Flatten[MapIndexed[{#2,#1}&,Normal[(#*UnitStep[#])&@(PotentialityMatrix[brainState]-sproutingThreshold)],{2}],1],Positive[Last[#]]&];
	(*SAFE FILTERING:Handle asking for more than exist*)
	If[Length[rawCandidates]>sproutingRate,rawCandidates=TakeLargestBy[rawCandidates,Last,sproutingRate];];
	If[Length[rawCandidates]===0,Return[brainState]];
	(*3. The Arena Logic*)currentEdgeCount=EdgeCount[newNet];
	overflow=Max[0,(currentEdgeCount+Length[rawCandidates])-maxEdges];
	If[overflow>0,
	(*Find Gladiators*)
	gladiators=Map[{First[#],Abs[Last[#]]}&,TakeSmallestBy[Select[ArrayRules[newW],Last[#]!=0&],Abs[Last[#]]&,overflow]];
	(*The Duel*)
	arena=Join[rawCandidates,gladiators];
	(*Safe TakeLargest for survivors*)
	survivors=If[Length[arena]>Length[rawCandidates],TakeLargestBy[arena,Last,Length[rawCandidates]],arena];
	(*Sort bodies*)
	toAdd=Select[survivors,MemberQ[rawCandidates,#]&];
	(*Fix:Ensure we match on indices only for killing*)
	toKill=Select[gladiators,!MemberQ[First/@survivors,First[#]]&];,(*Under Budget*)toAdd=rawCandidates;
	toKill={};];
	(*4. Execute Updates*)
	(*Prune*)
	If[Length[toKill]>0,newW=ReplacePart[newW,(First/@toKill)->0.];
	newNet=EdgeDelete[newNet,DirectedEdge@@@(First/@toKill)];];
	(*Sprout*)
	If[Length[toAdd]>0,newNet=EdgeAdd[newNet,DirectedEdge@@@(First/@toAdd)];
	newW=newW+SparseArray[Thread[(First/@toAdd)->Map[weightAssignmentFunction,Last/@toAdd]],Dimensions[newW]];];
	<|brainState,"network"->newNet,"weights"->newW(*,"networkSkeleton"->AdjacencyMatrix[newNet]*)|>]


(* ::Text:: *)
(*Note: if sproutingRate is larger than the number of candidates that actually pass the threshold, the function will just return the list of all candidates that passed.*)


(* ::Subsection:: *)
(*Simulation loop*)


(* ::CodeText:: *)
(*Proof of concept:*)


(* ::Input:: *)
(*(*sampleBrain//updateActivations//adaptWeights//pruneSynapses//sproutSynapses*)*)


(* ::CodeText:: *)
(*Compute the next simulation step function:*)


ClearAll[Step]
Step::usage = "Step[brainState, sensoryInput, rewardSignal, opts] executes one full simulation cycle: activation update -> weight adaptation -> structural plasticity.";
Options[Step]={
	"LeakRate"->.1,
	"ActivationFunction"->Tanh,
	"LearningRate"->0.01,
	"SurvivalThreshold"->.005,
	"SproutingRate"->1,
	"SproutingThreshold"->.1,
	"WeightAssignmentFunction"->(.001&)};

Step[brainState_Association,Optional[sensoryInput_,0],Optional[rewardSignal_?NumericQ,1],OptionsPattern[]]:=
	SproutSynapses[
		PruneSynapses[
			AdaptWeights[
				UpdateActivations[
					Append[brainState,"sensoryInput"->sensoryInput],
					OptionValue["LeakRate"],OptionValue["ActivationFunction"]],
				rewardSignal,OptionValue["LearningRate"]],
			OptionValue["SurvivalThreshold"]
			],
		OptionValue["SproutingRate"],OptionValue["SproutingThreshold"],OptionValue["WeightAssignmentFunction"]
		]/;Or[ListQ[sensoryInput],NumericQ[sensoryInput]]
