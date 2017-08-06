#############################################################################
##
##  SimplicialSurface package
##
##  Copyright 2012-2016
##    Markus Baumeister, RWTH Aachen University
##    Alice Niemeyer, RWTH Aachen University 
##
## Licensed under the GPL 3 or later.
##
#############################################################################


##############################################################################
##
##          Methods for labelled access
##
InstallMethod( Vertices, "for a polygonal complex", [IsPolygonalComplex],
	function(complex)
		return VerticesAttributeOfPolygonalComplex( complex );
	end
);

# methods to compute number of vertices, edges, faces
InstallMethod( NrOfVertices, "for a polygonal complex", [IsPolygonalComplex],
    function(complex)
            return Length( Vertices(complex) );
    end
);

InstallMethod( NrOfEdges, "for a polygonal complex", [IsPolygonalComplex],
    function(complex)
            return Length( Edges(complex) );
    end
);

InstallMethod( NrOfFaces, "for a polygonal complex", [IsPolygonalComplex],
    function(complex)
            return Length( Faces(complex) );
    end
);

##
##              End of labelled access
##
##############################################################################


##############################################################################
##
##          Methods for basic access (*Of*)
##

##
## Connection between labelled access and *Of*-attributes (via scheduler)
##

BindGlobal( "__SIMPLICIAL_BoundEntriesOfList",
    function( list )
	return Filtered( [1..Length(list)], i -> IsBound( list[i] ) );
    end
);

## EdgesOfVertices
InstallMethod( "Edges", 
    "for a polygonal complex with EdgesOfVertices",
    [IsPolygonalComplex and HasEdgesOfVertices],
    function(complex)
        return Union(EdgesOfVertices(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Edges", "EdgesOfVertices");

InstallMethod( "VerticesAttributeOfPolygonalComplex", 
    "for a polygonal complex with EdgesOfVertices",
    [IsPolygonalComplex and HasEdgesOfVertices],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(EdgesOfVertices(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "VerticesAttributeOfPolygonalComplex", "EdgesOfVertices");



## FacesOfVertices
InstallMethod( "Faces", "for a polygonal complex with FacesOfVertices",
    [IsPolygonalComplex and HasFacesOfVertices],
    function(complex)
        return Union(FacesOfVertices(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Faces", "FacesOfVertices");

InstallMethod( "VerticesAttributeOfPolygonalComplex", 
    "for a polygonal complex with FacesOfVertices",
    [IsPolygonalComplex and HasFacesOfVertices],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(FacesOfVertices(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "VerticesAttributeOfPolygonalComplex", "FacesOfVertices");


## VerticesOfEdges
InstallMethod( "VerticesAttributeOfPolygonalComplex", 
    "for a polygonal complex with VerticesOfEdges",
    [IsPolygonalComplex and HasVerticesOfEdges],
    function(complex)
        return Union(VerticesOfEdges(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "VerticesAttributeOfPolygonalComplex", "VerticesOfEdges");

InstallMethod( "Edges", "for a polygonal complex with VerticesOfEdges",
    [IsPolygonalComplex and HasVerticesOfEdges],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(VerticesOfEdges(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Edges", "VerticesOfEdges");


## FacesOfEdges
InstallMethod( "Faces", "for a polygonal complex with FacesOfEdges",
    [IsPolygonalComplex and HasFacesOfEdges],
    function(complex)
        return Union(FacesOfEdges(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Faces", "FacesOfEdges");

InstallMethod( "Edges", "for a polygonal complex with FacesOfEdges",
    [IsPolygonalComplex and HasFacesOfEdges],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(FacesOfEdges(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Edges", "FacesOfEdges");


## VerticesOfFaces
InstallMethod( "VerticesAttributeOfPolygonalComplex", 
    "for a polygonal complex with VerticesOfFaces",
    [IsPolygonalComplex and HasVerticesOfFaces],
    function(complex)
        return Union(VerticesOfFaces(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "VerticesAttributeOfPolygonalComplex", "VerticesOfFaces");

InstallMethod( "Faces", "for a polygonal complex with VerticesOfFaces",
    [IsPolygonalComplex and HasVerticesOfFaces],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(VerticesOfFaces(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Faces", "VerticesOfFaces");



## EdgesOfFaces
InstallMethod( "Edges", "for a polygonal complex with EdgesOfFaces",
    [IsPolygonalComplex and HasEdgesOfFaces],
    function(complex)
        return Union(EdgesOfFaces(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Edges", "EdgesOfFaces");

InstallMethod( "Faces", "for a polygonal complex with EdgesOfFaces",
    [IsPolygonalComplex and HasEdgesOfFaces],
    function(complex)
        return __SIMPLICIAL_BoundEntriesOfList(EdgesOfFaces(complex));
    end
);
AddPropertyIncidence( "SIMPLICIAL_ATTRIBUTE_SCHEDULER",
    "Faces", "EdgesOfFaces");

##
##  Implement "faster" access to *Of*-attributes by adding an argument
##

## EdgesOfVertices
InstallMethod("EdgesOfVertexNC", 
    "for a polygonal complex and a positive integer",
    [IsPolygonalComplex, IsPosInt],
    function(complex, vertex)
        return EdgesOfVertices(complex)[vertex]    
    end
);
InstallMethod("EdgesOfVertex",
    "for a polygonal complex and a positive integer",
    [IsPolygonalComplex, IsPosInt],
    function(complex, vertex)
        if not vertex in Vertices(complex) then
            Error("EdgesOfVertex: Given vertex does not lie in complex.");
        fi;
        return EdgesOfVertex(complex,vertex);
    end
);



##
##          End of basic access (*Of*)
##
##############################################################################
