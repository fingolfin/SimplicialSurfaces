##
##	Test the consistency of a simplicial surface fan
##	
TestFanConsistency := function( fan, messageFanOrigin )
	local testFan, inv, subsets, red, sub;


	if not IsSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " is not a simplicial surface fan.\n" );
	fi;

	# Test the begin
	if BeginOfFan(fan) <> BeginOfFanAttributeOfSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " has inconsistent begin.\n");
	fi;
	
	# Test the begin
	if EndOfFan(fan) <> EndOfFanAttributeOfSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " has inconsistent end.\n");
	fi;

	# Test the permutation
	if PermutationOfFan(fan) <> PermutationOfFanAttributeOfSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " has inconsistent permutation.\n");
	fi;

	# Test the corona
	if CoronaOfFan(fan) <> CoronaOfFanAttributeOfSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " has inconsistent corona.\n");
	fi;
	if PermutationOfFan(fan) <> () then
		if MovedPoints( PermutationOfFan(fan) ) <> CoronaOfFan(fan) then
			Print( messageFanOrigin );
			Print( " has a corona that is inconsistent with the permutation.\n");
		fi;
	fi;


	# Test detailed constructor
	testFan := SimplicialSurfaceFan( BeginOfFan(fan), EndOfFan(fan),
		PermutationOfFan(fan) : Corona:=CoronaOfFan(fan) );
	if fan <> testFan then
		Print( messageFanOrigin );
		Print( " is not equal to a fan with the same attributes.\n" );
	fi;


	# Test the inverse
	if InverseOfFan(fan) <> InverseOfFanAttributeOfSimplicialSurfaceFan(fan) then
		Print( messageFanOrigin );
		Print( " has inconsistent inverse.\n");
	fi;
	inv := InverseOfFan(fan);
	if not IsSimplicialSurfaceFan(inv) then
		Print( messageFanOrigin );
		Print( ": The inverse is not a fan.\n" );
	fi;
	if BeginOfFan(inv) <> EndOfFan(fan) then
		Print( messageFanOrigin );
		Print( ": Begin of inverse is not end of original.\n" );
	fi;
	if EndOfFan(inv) <> BeginOfFan(fan) then
		Print( messageFanOrigin );
		Print( ": End of inverse is not begin of original.\n" );
	fi;
	if CoronaOfFan(inv) <> CoronaOfFan(fan) then
		Print( messageFanOrigin );
		Print( ": Corona of inverse is not corona of original.\n" );
	fi;
	if PermutationOfFan(inv)^(-1) <> PermutationOfFan(fan) then
		Print( messageFanOrigin );
		Print( ": Permutation of inverse is not inverse permutation of original.\n" );
	fi;


	# Test the reduced fan for all subsets of the corona
	subsets := Combinations( CoronaOfFan( fan ) );
	for sub in subsets do
		red := ReducedFan( fan, sub );
		if not IsSimplicialSurfaceFan(red) then
			Print( messageFanOrigin );
			Print( ": The reduct to " );
			Print( sub );
			Print( " is not a fan.\n" );
		fi;
		if BeginOfFan(red) <> BeginOfFan(fan) then
			Print( messageFanOrigin );
			Print( ": The reduct to " );
			Print( sub );
			Print( " has a different begin than the original fan.\n" );
		fi;
		if EndOfFan(red) <> EndOfFan(fan) then
			Print( messageFanOrigin );
			Print( ": The reduct to " );
			Print( sub );
			Print( " has a different end than the original fan.\n" );
		fi;
		if CoronaOfFan(red) <> sub then
			Print( messageFanOrigin );
			Print( ": The reduct to " );
			Print( sub );
			Print( " has a different corona than " );
			Print( sub );
			Print( ".\n" );
		fi;	
	od;
end;


##
##	Test attributes of simplicial surface fans
##	beginOfFan		BeginOfFan
##	endOfFan			EndOfFan
##	permutation		PermutationOfFan
##	corona		CoronaOfFan
##
TestFanAttributes := function(fan, messageFanOrigin, beginOfFan, endOfFan,
	permutation, corona)

	TestFanConsistency( fan, messageFanOrigin );

	if BeginOfFan(fan) <> beginOfFan then
		Print( messageFanOrigin );
		Print( " does not have Begin " );
		Print( beginOfFan );
		Print( ".\n" );
	fi;

	if EndOfFan(fan) <> endOfFan then
		Print( messageFanOrigin );
		Print( " does not have End " );
		Print( endOfFan );
		Print( ".\n" );
	fi;

	if PermutationOfFan(fan) <> permutation then
		Print( messageFanOrigin );
		Print( " does not have permutation " );
		Print( permutation );
		Print( ".\n" );
	fi;

	if CoronaOfFan(fan) <> corona then
		Print( messageFanOrigin );
		Print( " does not have corona " );
		Print( corona );
		Print( ".\n" );
	fi;
end;

##
##	Check whether the given fan is the fan of a given simplicial surface (at a
##	certain edge), as well as for the coloured variant.
TestFanEdge := function(fan, messageFanOrigin, surface, edge, colSurf, edgeClass )
	local wrongEdge;

	# Check whether the correct edge is recognized
	if EdgeForFanOfSimplicialSurface( surface, fan ) <> edge then
		Print( messageFanOrigin );
		Print( " does not belong to edge " );
		Print( edge );
		Print( " of the given simplicial surface.\n" );
	fi;
	if edge <> fail and not IsEdgeForFanOfSimplicialSurface( surface, fan, edge ) then
		Print( messageFanOrigin );
		Print( " does not recognize that it belongs to edge " );
		Print( edge );
		Print( " of the given simplicial surface.\n" );
	fi;
	# Check whether all other edges are rejected
	for wrongEdge in Difference( Edges(surface), [edge] ) do
		if IsEdgeForFanOfSimplicialSurface( surface, fan, wrongEdge ) then
			Print( messageFanOrigin );
			Print( " does not reject the edge " );
			Print( wrongEdge );
			Print( " of the given simplicial surface.\n" );
		fi;
	od;


	# Check whether the correct edge class is recognized
	if EdgeEquivalenceNumberForFanOfColouredSimplicialSurface( colSurf, fan ) <> edgeClass then
		Print( messageFanOrigin );
		Print( " does not belong to the edge class " );
		Print( edgeClass );
		Print( " of the given coloured simplicial surface.\n" );
	fi;
	if edgeClass <> fail and not IsEdgeEquivalenceNumberForFanOfColouredSimplicialSurface( colSurf, fan, edgeClass ) then
		Print( messageFanOrigin );
		Print( " does not recognize that it belongs to edge class " );
		Print( edgeClass );
		Print( " of the given coloured simplicial surface.\n" );
	fi;
	# Check whether all other edge classes are rejected
	for wrongEdge in Difference( EdgeEquivalenceNumbersAsSet(colSurf), [edgeClass] ) do
		if IsEdgeEquivalenceNumberForFanOfColouredSimplicialSurface( colSurf, fan, wrongEdge ) then
			Print( messageFanOrigin );
			Print( " does not reject the edge class " );
			Print( wrongEdge );
			Print( " of the given coloured simplicial surface.\n" );
		fi;
	od;
end;





##
##	Test the consistency of a folding complex
##	
TestFoldingComplexConsistency := function( complex, messageOrigin )
	local altCom, edgeNr, colSurf, faceNr, face, name, faces, edge, faceClasses;

	if not IsFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " is not a folding complex.\n" );
	fi;


	# Check simplicial surface
	if UnderlyingSimplicialSurface(complex) <> UnderlyingSimplicialSurfaceAttributeOfFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " has inconsistent underlying simplicial surface.\n" );
	fi;

	# Check coloured simplicial surface
	if UnderlyingColouredSimplicialSurface(complex) <> UnderlyingCSSAttributeOfFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " has inconsistent underlying coloured simplicial surface.\n" );
	fi;
	colSurf := UnderlyingColouredSimplicialSurface(complex);

	# Check fans
	if Fans(complex) <> FansAttributeOfFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " has inconsistent fans.\n" );
	fi;
	for edgeNr in EdgeEquivalenceNumbersAsSet(colSurf) do
		if FanOfEdgeEquivalenceClass(complex, edgeNr) <> FanOfEdgeEquivalenceClassNC(complex, edgeNr) then
			Print( messageOrigin );
			Print( " has an inconsistent NC-fan at the edge position " );
			Print( edgeNr );
			Print( ".\n" );
		fi;
		if FanOfEdgeEquivalenceClass(complex, edgeNr) <> Fans(complex)[edgeNr] then
			Print( messageOrigin );
			Print( " has an inconsistent fan at the edge position " );
			Print( edgeNr );
			Print( ".\n" );
		fi;
	od;
	for edge in EdgeEquivalenceNumbersAsSet(colSurf) do
		faceClasses := EdgesByFaces( QuotientSimplicialSurface(colSurf) )[edge];
		faces := Union( List(faceClasses, nr -> FaceEquivalenceClassByNumber( colSurf, nr ) ));
		for face in faces do
			for name in NamesOfFace( UnderlyingSimplicialSurface(complex), face ) do
				if ApplyFanToOrientedFace(complex,edge,name) <> ApplyFanToOrientedFaceNC(complex,edge,name) then
					Print( messageOrigin );
					Print( " has an inconsistent application of fan at edge " );
					Print( edge );
					Print( " to the oriented face " );
					Print( name );
					Print( ".\n" );
				fi;
			od;
		od;
	od;

	# Check border pieces
	if BorderPieces(complex) <> BorderPiecesAttributeOfFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " has inconsistent border pieces.\n" );
	fi;
	for faceNr in FaceEquivalenceNumbersAsSet(colSurf) do
		if BorderPiecesOfFaceEquivalenceClass(complex, faceNr) <> BorderPiecesOfFaceEquivalenceClassNC(complex, faceNr) then
			Print( messageOrigin );
			Print( " has an inconsistent NC-border piece at the face position " );
			Print( faceNr );
			Print( ".\n" );
		fi;
		if BorderPiecesOfFaceEquivalenceClass(complex, faceNr) <> BorderPieces(complex)[faceNr] then
			Print( messageOrigin );
			Print( " has an inconsistent border piece at the face position " );
			Print( faceNr );
			Print( ".\n" );
		fi;
	od;

	# Check constructor by fans and border pieces
	altCom := FoldingComplexByFansAndBorders( 
				UnderlyingColouredSimplicialSurface(complex), 
				Fans(complex), BorderPieces(complex) );
	if complex <> altCom then
		Print( messageOrigin );
		Print( " is not defined by fans and borders.\n");
	fi;

	# Check orientation covering
	if OrientationCovering(complex) <> OrientationCoveringAttributeOfFoldingComplex(complex) then
		Print( messageOrigin );
		Print( " has inconsistent orientation covering.\n" );
	fi;
	if not IsSimplicialSurface( OrientationCovering(complex) ) then
		Print( messageOrigin );
		Print( " has an orientation covering that is not a simplicial surface.\n" );
	fi;
end;





##
##	Test the consistency of a folding plan
##
TestFoldingPlanConsistency := function(plan, messageOrigin)
	local orFaceMap, planByMaps, orFaceList, planById, planByLists, vertexList,
		edgeList, faceList;

	if not IsFoldingPlan(plan) then
		Print( messageOrigin );
		Print( " is not a folding plan.\n" );
	fi;


	# Check oriented face map
	if OrientedFaceMap(plan) <> OrientedFaceMapAttributeOfFoldingPlan(plan) then
		Print( messageOrigin );
		Print( " has an inconsistent oriented face map.\n" );
	fi;
	orFaceMap := OrientedFaceMap(plan); 
	if not IsMapping(orFaceMap) or not IsBijective(orFaceMap) then
		Print( messageOrigin );
		Print( " has an oriented face map that is not bijective.\n" );
	fi;

	# Check identification
	if Identification(plan) <> IdentificationAttributeOfFoldingPlan(plan) then
		Print( messageOrigin );
		Print( " has an inconsistent identification.\n" );
	fi;
	if not IsSimplicialSurfaceIdentification( Identification(plan) ) then
		Print( messageOrigin );
		Print( " has an identification that is not a simplicial surface identification.\n" );
	fi;


	# Check vertex map
	if VertexMap(plan) <> VertexMap( Identification(plan) ) then
		Print( messageOrigin );
		Print( " has a different vertex map than its identification.\n" );
	fi;

	# Check edge map
	if EdgeMap(plan) <> EdgeMap( Identification(plan) ) then
		Print( messageOrigin );
		Print( " has a different edge map than its identification.\n" );
	fi;

	# Check face map
	if FaceMap(plan) <> FaceMap( Identification(plan) ) then
		Print( messageOrigin );
		Print( " has a different face map than its identification.\n" );
	fi;


	
	# Check folding plan constructor by maps
	planByMaps := FoldingPlanByMaps( VertexMap(plan), EdgeMap(plan), FaceMap(plan), OrientedFaceMap(plan) );
	if planByMaps <> FoldingPlanByMapsNC( VertexMap(plan), EdgeMap(plan), FaceMap(plan), OrientedFaceMap(plan) ) then
		Print( messageOrigin );
		Print( " has an inconsistent (NC) constructor by maps.\n" );
	fi;
	if planByMaps <> plan then
		Print( messageOrigin );
		Print( " can't be reconstructed by its maps.\n" );
	fi;

	# Check folding plan constructor by identification and oriented face list
	orFaceList := __SIMPLICIAL_CreateListFromMap( OrientedFaceMap( plan ) );
	planById := FoldingPlanByIdentification( Identification(plan), orFaceList );
	if planById <> FoldingPlanByIdentificationNC( Identification(plan), orFaceList ) then
		Print( messageOrigin );
		Print( " has an inconsistent (NC) constructor by identification.\n" );
	fi;
	if planById <> plan then
		Print( messageOrigin );
		Print( " can't be reconstructed by its identification.\n" );
	fi;

	# Check folding plan constructor by lists
	vertexList := __SIMPLICIAL_CreateListFromMap( VertexMap( plan ) );
	edgeList := __SIMPLICIAL_CreateListFromMap( EdgeMap( plan ) );
	faceList := __SIMPLICIAL_CreateListFromMap( FaceMap( plan ) );
	planByLists := FoldingPlanByLists( vertexList, edgeList, faceList, orFaceList );
	if planByLists <> FoldingPlanByListsNC( vertexList, edgeList, faceList, orFaceList ) then
		Print( messageOrigin );
		Print( " has an inconsistent (NC) constructor by lists.\n" );
	fi;
	if planByLists <> plan then
		Print( messageOrigin );
		Print( " can't be reconstructed by its lists.\n" );
	fi;
end;


##
##	Test the consistency of a folding plan together with a folding complex.
##	This method only checks the interaction
##	of these two objects, not the consistency of the objects themselves.
##	
TestFoldingComplexPlanConsistency := function( complex, plan, messageConnection )
	local wellDef, applicable, extension;

	wellDef := IsWellDefinedFoldingPlan( complex, plan );
	applicable := IsApplicableFoldingPlan( complex, plan );

	# Check if wellDef is consistent for both inputs
	if wellDef <> IsWellDefinedFoldingPlan( UnderlyingSimplicialSurface(complex), plan ) then
		Print( messageConnection );
		Print( ": well-defined is inconsistent.\n" );
	fi;


	#
	# To check applicable we proceed in several steps
	#

	# if wellDef is false, then applicable is false
	if not wellDef and applicable then
		Print( messageConnection );
		Print( " is not well-defined but applicable.\n" );
	fi;

	# if wellDef is true, then the NC-version may be called
	if wellDef then
		if applicable <> IsApplicableFoldingPlanNCWellDefined(complex, plan) then
			Print( messageConnection );
			Print( " has inconsistent applicability (controlling for well-definedness).\n" );
		fi;
	fi;

	
	# if applicable is true, we can extend the surface
	extension := ApplyFoldingPlan(complex, plan);

	# if the folding plan is not well defined, the extension fails
	if not wellDef and extension <> fail then
		Print( messageConnection );
		Print( " is not well-defined but can be extended.\n" );
	fi;
	# if the folding plan is well defined, the NC-version may be called
	if wellDef and extension <> ApplyFoldingPlanNCWellDefined(complex,plan) then
		Print( messageConnection );
		Print( " has inconsistent extension (controlling for well-definedness).\n" );
	fi;

	# if the folding plan is not applicable, the extension fails
	if not applicable and extension <> fail then
		Print( messageConnection );
		Print( " is not applicable but can be extended.\n" );
	fi;
	# if the folding plan is applicable, the NC-version may be called
	if applicable and extension <> ApplyFoldingPlanNCApplicable(complex,plan) then
		Print( messageConnection );
		Print( " has inconsistent extension (controlling for applicability).\n" );
	fi;


	# check extension itself
	if extension <> fail and not IsFoldingComplex(extension) then
		Print( messageConnection );
		Print( " has an extension that is not a folding complex.\n" );
	fi;

end;