################################################################################
################################################################################
#####					Test two connected triangles
################################################################################
################################################################################


TestIsomorphicTwoConTri := function( surface, messageSurfaceOrigin )
	local check;

	check := SimplicialSurfaceByDownwardIncidence( [1,2,3,4], 5, [1,4],
		[ [1,2],[1,3],[3,2],[4,3],[2,4] ],
		[ [1,2,3], , , [3,5,4] ] );
	if not IsIsomorphic( surface, check ) then
		Print( messageSurfaceOrigin );
		Print( " is not isomorphic to two connected triangles.\n");
	fi;
end;


##
##	Test whether a simplicial surface is isomorphic to two connected triangles.
##
TestIsTwoConnectedTriangles := function( surface, messageSurfaceOrigin )
	local snipp;

	TestSimplicialSurfaceAttributes( surface, messageSurfaceOrigin,
		4, 		# number of vertices
		5, 		# number of edges
		2,		# number of faces
		true,	# do the edges look like on a surface?
		true,	# do the vertices look like on a surface?
		true,	# is every face a triangle?
		false,	# is it closed?
		true,	# is it orientable?
		true, 	# is it connected?
		[1,1,2,2],		# the sorted degrees
		[,2,2],			# the vertex symbol
		2,		# the number of anomaly classes
		true	# does ear-removal reduce the surface?
	);
	

	snipp := SnippOffEars(surface);
	if NrOfVertices(snipp) > 0 or NrOfEdges(snipp) > 0 or NrOfFaces(snipp) > 0 then
		Print( messageSurfaceOrigin );
		Print( " should be destroyed by removal of ears.\n");
	fi;

	TestIsomorphicTwoConTri( surface, messageSurfaceOrigin);

end;



##########################################################################
## This method tests the functionality for the example of two connected 
## triangles and the representation of a simplicial surface
TestTwoConnectedTriangles := function()
	local surf, name;

	name := "TwoConTri";

	surf := SimplicialSurfaceByVerticesInFaces( 4,2, [[1,2,3],[3,2,4]] );

	TestIsTwoConnectedTriangles( surf, Concatenation(name," definition") );

	# We also test the simplest version of the coloured simplicial surfaces
	TestColouredSimplicialSurfaceConsistency( 
		ColouredSimplicialSurface( surf ), 
		Concatenation(name," as coloured simplicial surface") );
end;


##
##	Test whether a wild simplicial surface is a tetrahedron.
##
TestIsWildTwoConnectedTriangles := function( surface, messageSurfaceOrigin )
	local vertexGroup, invGroup;

	# Check if it fulfills the criteria of a janus head (necessary to check
	# since some methods might have been overwritten).
	TestIsTwoConnectedTriangles( surface, messageSurfaceOrigin );
	TestSimplicialSurfaceConsistency( surface, messageSurfaceOrigin );

	#TODO how to check?


	# Check vertex group
	vertexGroup := VertexGroup(surface);
	vertexGroup := vertexGroup[1] / vertexGroup[2];
	if Size( vertexGroup ) <> 2 then
		Print( messageSurfaceOrigin );
		Print( " should have vertex group C_2.\n");
	fi;


	# Check group generated from the involutions
	invGroup := GroupOfWildSimplicialSurface( surface );
	if Size( invGroup ) <> 2 then
		Print( messageSurfaceOrigin );
		Print( " should have generated group C_2.\n");
	fi;
end;


##########################################################################
## This method tests the functionality for the example of a tetrahedron
## and the representation as a wild simplicial surface
TestWildTwoConnectedTriangles := function()
	local surf, name, sig1, sig2, sig3, mrType, gens;

	name := "TwoConTri (wild)";

	sig1 := (1,2);
	sig2 := ();
	sig3 := ();
	mrType :=  [ [0,0], [1,1], [1,1] ];

	gens := [sig1,sig2,sig3];


	# TODO
	
end;


##
##	Test simplicial surface identifications
##
TestTwoConnectedTrianglesIdentification := function()
	local surf, name, id, vertexMap, edgeMap, faceMap;

	surf := SimplicialSurfaceByDownwardIncidenceWithOrientation( [1,2,3,4], 5, [1,4],
		[ [1,2],[1,3],[3,2],[4,3],[2,4] ],
		[ [1,2,3], , , [3,5,4] ] );
	surf := ColouredSimplicialSurface( surf );


	# Try a correct identification by maps
	vertexMap := GeneralMappingByElements( Domain( [1,2,3] ), Domain( [2,3,4] ), 
		[ DirectProductElement([1,4]), DirectProductElement([2,2]), DirectProductElement([3,3]) ]);
	edgeMap := GeneralMappingByElements( Domain( [1,2,3] ), Domain( [3,4,5] ), 
		[ DirectProductElement([1,4]), DirectProductElement([2,5]), DirectProductElement([3,3]) ]);
	faceMap := GeneralMappingByElements( Domain( [1] ), Domain( [4] ), 
		[ DirectProductElement([1,4]) ]);
	id := SimplicialSurfaceIdentification( vertexMap, edgeMap, faceMap );
	TestSimplicialSurfaceIdentificationConsistency( id, "Unique identification of TwoConTri (by maps)" );
	TestColouredIdentificationConsistency( surf, id, "Unique identification of TwoConTri (by maps) and TwoConTri" );

	# Try an incorrect identification by maps
	vertexMap := GeneralMappingByElements( Domain( [1,2,4] ), Domain( [2,3,4] ), 
		[ DirectProductElement([1,4]), DirectProductElement([2,2]), DirectProductElement([4,3]) ]);
	edgeMap := GeneralMappingByElements( Domain( [1,2,3] ), Domain( [3,4,5] ), 
		[ DirectProductElement([1,4]), DirectProductElement([2,5]), DirectProductElement([3,3]) ]);
	faceMap := GeneralMappingByElements( Domain( [1] ), Domain( [4] ), 
		[ DirectProductElement([1,4]) ]);
	id := SimplicialSurfaceIdentification( vertexMap, edgeMap, faceMap );
	TestSimplicialSurfaceIdentificationConsistency( id, "Incorrect identification of TwoConTri (by maps)" );
	TestColouredIdentificationConsistency( surf, id, "Incorrect identification of TwoConTri (by maps) and TwoConTri" );

	# Try a correct identification by lists
	id := SimplicialSurfaceIdentificationByLists( [ [1,4],[2,2],[3,3] ], [ [1,4],[2,5],[3,3] ], [ [1,4] ] );
	TestSimplicialSurfaceIdentificationConsistency( id, "Unique identification of TwoConTri (by lists)" );
	TestColouredIdentificationConsistency( surf, id, "Unique identification of TwoConTri (by lists) and TwoConTri" );

	# Try an incorrect identification by lists
	id := SimplicialSurfaceIdentificationByLists( [ [1,4],[2,2],[3,3] ], [ [1,4],[2,5],[3,3] ], [ [1,2] ] );
	TestSimplicialSurfaceIdentificationConsistency( id, "Incorrect identification of TwoConTri (by lists)" );
	TestColouredIdentificationConsistency( surf, id, "Incorrect identification of TwoConTri (by lists) and TwoConTri" );
end;

