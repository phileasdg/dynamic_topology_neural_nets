(* ::Package:: *)

(* ::Title:: *)
(*Generating random directed graphs*)


(* ::Section:: *)
(*Methods for random directed graph generation*)


(* ::Text:: *)
(*(These are just a few approaches I have tried)*)


(* ::Subsection::Closed:: *)
(*Built-ins (RandomGraph)*)


?RandomGraph


RandomGraph[{10, 20}, DirectedEdges -> True]


(* ::Subsection::Closed:: *)
(*Sampling ordered pairs from a list of n vertices without replacement:*)


ClearAll[permutationCount]
permutationCount[(*list size:*)n_,(*tuple size:*)m_]:=n!/(n-m)!


ClearAll[sampleOrderedPairs]
(*Attempt to pick m ordered pairs from a list of n elements*)
sampleOrderedPairs[
	(*list size:*)n_,
	(*desired number of ordered pairs:*)m_]:=With[
	{vertices=Range[n]},
	NestWhile[
		With[{(*Replace with RandomChoice to allow self-loops:*)
			choice=RandomSample[vertices,2]},
			If[FreeQ[#,choice],Union[#,{choice}],#]]&,
		{},Length[#]<Min[m,permutationCount[n,2]
		(*Uncomment if allowing self-loops:*)(*+n*)]&,1]]


(*Example:*)
sampleOrderedPairs[10,20]
%//Length


(* ::Text:: *)
(*Since the algorithm ensures that the resulting list is duplicate-free, we can use this function as a way of generating edges of a random directed graph:*)


Graph[DirectedEdge@@@sampleOrderedPairs[10,100]]


(* ::Text:: *)
(*But these graphs are not guaranteed to have just one connected component.*)


(* ::Subsection::Closed:: *)
(*Trail random walks (no visiting any edge twice, but crossings allowed): *)


(*SeedRandom[0];*)
ClearAll[walkTrail]
walkTrail[v_Integer,e_Integer,initEdges_List:{}]:=Catch[With[{vertices=Range[v]},
	DeleteCases[Last[NestWhile[With[
		{vertex=#1,edges=#2},
		{nextVertex=If[#=!={},RandomChoice[#],False]&@Complement[
			(*Replace with vertices if allowing self-loops:*)
			DeleteCases[vertices,vertex],
			(*Fine the edges starting at the current vertex that already exist:*)
			Cases[edges,vertex\[DirectedEdge]_][[All,2]]]},
		{nextVertex,Append[edges,vertex\[DirectedEdge]nextVertex]}]&@@##&,
		{If[
			#=!={},First[RandomChoice[#]],
			Throw[Failure["NoStartingEdge",Association["MessageTemplate"->"No free edge was found."]]]
			]&@Position[
				VertexDegree[Graph[vertices,initEdges]],
				_?(#<2(v-1)(*Remove the -1 if allowing self loops:*)&)],
			initEdges},
		And[Length[#2]<e,#1=!=False]&@@##&,1,
		e(*Uncomment if allowing self-loops:*)(*+v*)]],_\[DirectedEdge]False]
	]]


(*Example:*)
walkTrail[10,100]


(*Example:*)
{DuplicateFreeQ[#],Length[#],Graph[#]}&@walkTrail[10,100]


(* ::Text:: *)
(*This method is guaranteed to produce a graph with a single connected component.*)


(* ::Text:: *)
(*One limitation of this method is that it is not guaranteed to produce a path containing as many edges as are requested by the user, even if such a path exists, because the walking options are constrained to a single walk. The walker can get stuck. The next method attempts to address this limitation.*)


(* ::Text:: *)
(*We can animate the graph construction process like this:*)


SeedRandom[1234];
Catch[With[{v=10,e=100,initEdges={}},{vertices=Range[v]},
	MapAt[{#1,DeleteCases[#2,_\[DirectedEdge]False]}&@@#&,NestWhileList[With[
		{vertex=#1,edges=#2},
		{nextVertex=If[#=!={},RandomChoice[#],False]&@Complement[
			(*Replace with vertices if allowing self-loops:*)
			DeleteCases[vertices,vertex],
			(*Fine the edges starting at the current vertex that already exist:*)
			Cases[edges,vertex\[DirectedEdge]_][[All,2]]]},
		{nextVertex,Append[edges,vertex\[DirectedEdge]nextVertex]}]&@@##&,
		{If[
			#=!={},First[RandomChoice[#]],
			Throw[Failure["NoStartingEdge",Association["MessageTemplate"->"No free edge was found."]]]
			]&@Position[
				VertexDegree[Graph[vertices,initEdges]],
				_?(#<2(v-1)(*Remove the -1 if allowing self loops:*)&)],
			initEdges},
		And[Length[#2]<e,#1=!=False]&@@##&,1,
		e(*Uncomment if allowing self-loops:*)(*+v*)],-1][[All,-1]]
	]]//
	Map[Graph[#]&,#]&//ListAnimate


(* ::Subsection::Closed:: *)
(*Multiple trail random walks*)


SeedRandom[1];
ClearAll[multipleWalkTrail]
multipleWalkTrail[v_Integer,e_Integer]:=With[{
	edges=walkTrail[v,e],
	maxEdges=Min[(permutationCount[v,2]
	(*Uncomment if allowing self-loops:*)(*+v*)),e]},
	If[Length[edges]>maxEdges,edges,NestWhile[
		If[Length[edges]<maxEdges,walkTrail[v,e,#],#]&,
		edges,Length[#]<Min[(permutationCount[v,2]
	(*Uncomment if allowing self-loops:*)(*+v*)),e]&,1,10(*v*)]]]


(*Example:*)
multipleWalkTrail[10,100]


(*Example:*)
{DuplicateFreeQ[#],Length[#],Graph[#]}&@multipleWalkTrail[10,100]


(* ::Text:: *)
(*This is a pretty effective method, but I'm not sure what the effects of sampling this way might be on the distribution of results.*)


(* ::Text:: *)
(*We can recover the different paths sampled in this process and visualize them on a graph:*)


(*SeedRandom[0];*)
ClearAll[multipleWalkTrailList]
multipleWalkTrailList[v_Integer,e_Integer,maxWalkAttempts_:\[Infinity]]:=
	Flatten[Map[Thread,Thread[#->ColorData[96]/@Range[Length[#]]]]]&@
		Prepend[MapApply[Complement[#2,#1]&,Partition[#,2,1]],First[#]]&@With[{
			edges=walkTrail[v,e],
			maxEdges=Min[(permutationCount[v,2]
			(*Uncomment if allowing self-loops:*)(*+v*)),e]},
			NestWhileList[
				If[Length[#]<maxEdges,walkTrail[v,e,#],#]&,
				edges,Length[#]<Min[(permutationCount[v,2]
			(*Uncomment if allowing self-loops:*)(*+v*)),e]&,1,maxWalkAttempts]]


(*Example:*)
Graph[Range[VertexCount[Keys[#]]],Keys[#],EdgeStyle->#]&@multipleWalkTrailList[5,100]


(* ::Subsection::Closed:: *)
(*Random adjacency matrix graphs*)


With[{v=10},AdjacencyGraph[RandomInteger[1,{v,v}](1-IdentityMatrix[v])]]


(* ::Text:: *)
(*The approach above does not let us control the number of edges, and it is not guaranteed to yield a single connected component. This next one does:*)


Module[{n=10,k=20,flatIndices, rows, cols},
  (* 1. Sample k unique positions from the hypothetical flattened off-diagonal space *)
  flatIndices = RandomSample[1 ;; n*(n - 1), k];

  (* 2. Map 1D indices to Row indices *)
  rows = Ceiling[flatIndices / (n - 1)];

  (* 3. Map 1D indices to Column indices *)
  (* Initially map to 1 through n-1 *)
  cols = Mod[flatIndices - 1, n - 1] + 1;
  
  (* 4. The "Skip Diagonal" Logic *)
  (* If the calculated col index is >= the row index, we shift it by +1 *)
  cols += UnitStep[cols - rows];

  (* 5. Construct SparseArray *)
  SparseArray[Transpose[{rows, cols}] -> 1, {n, n}]
]//AdjacencyGraph


(* ::Text:: *)
(*We can build on this method to control the distribution from which edges are sampled. However, as the code is set up currently, the edges are sampled from a uniform distribution, which is equivalent to using RandomGraph without a specified built-in graph distribution.*)


(* ::Subsection::Closed:: *)
(*Growing a single connected component at random*)


(* ::Text:: *)
(*This next approach does allow both the number of vertices and the desired number of edges to be specified. Although the resulting graph may have fewer edges than requested if the requested number is greater than the total possible number of edges on a graph with the specified number of vertices. This method also guarantees that the resulting graph will have a single connected component.*)


ClearAll[nonZeroRows]
nonZeroRows[m_?MatrixQ]:=(MemberQ[#1,_?(#1=!=0&)]&)/@Normal[m]

(*Example:*)
(*nonZeroRows[{{1,0,1},{0,0,0},{0,1,0}}]*)


ClearAll[nonZeroColumns]
nonZeroColumns[m_?MatrixQ]:=(MemberQ[#1,_?(#1=!=0&)]&)/@Transpose[Normal[m]]

(*Example:*)
(*nonZeroColumns[{{1,0,1},{0,0,0},{0,1,0}}]*)


SeedRandom[1234];
With[{v=20,e=50},{vertices=Range[v]},NestWhile[
	#+SparseArray[If[#=!={},RandomChoice[#],{}]&@
		Position[(1-IdentityMatrix[v])Boole[Outer[
			Or,nonZeroRows[#],nonZeroColumns[#]]]-#,1]->1,
		Dimensions[#]]
		&,
	SparseArray[RandomInteger[{1,v},2]->1,{v,v}],
	Total[Flatten[#]]<Min[v^2(*Remove the -v if allowing self-loops:*)-v,e]&,1,e-1]]
	
%//AdjacencyGraph//{#,VertexCount[#],EdgeCount[#],DuplicateFreeQ[EdgeList[#]]}&


(* ::Text:: *)
(*To guarantee that resulting graph will have a single connected component the process must guarantee that every edge in the graph connects to at least another edge, and that there is a path between every vertex when the graph is taken as undirected (this is just what it means for a graph to be a single  connected component). In the implementation above, I tackled the problem by requiring that during the sampling process, edges can only be added if they connect to another edge. *)


(* ::Text:: *)
(*We can animate the graph construction process like this:*)


SeedRandom[1234];
With[{v=20,e=50},{vertices=Range[v]},NestWhileList[
	#+SparseArray[If[#=!={},RandomChoice[#],{}]&@
		Position[(1-IdentityMatrix[v])Boole[Outer[
			Or,nonZeroRows[#],nonZeroColumns[#]]]-#,1]->1,
		Dimensions[#]]
		&,
	SparseArray[({#,RandomChoice[DeleteCases[vertices,#]]}&@RandomInteger[{1,v}])->1,{v,v}],
	Total[Flatten[#]]<Min[v^2(*Remove the -v if allowing self-loops:*)-v,e]&,1,e-1]]//
	Map[Graph[EdgeList[AdjacencyGraph[#]]]&,#]&//ListAnimate
