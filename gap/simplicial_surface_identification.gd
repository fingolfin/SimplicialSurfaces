##############################################################################
##
#W  simplicial_surface_identification.gd          SimplicialSurfaces           Markus Baumeister
##
##
#Y  Copyright (C) 2016-2017, Markus Baumeister, Lehrstuhl B für Mathematik,
#Y  RWTH Aachen
##
##  This file is free software, see license information at the end.
##
##  This file contains the declaration part for the identifications of the 
##	SimplicialSurfaces package. An identification is an isomorphism between
##	two faces (and the incident vertices and edges) and is used to fold a
##	simplicial surface with equivalence.
##
##	An identification consists of three maps - one for vertices, edges and
##	faces. It can be applied to any simplicial surface (with equivalence) where
##	it the application is well-defined.
##

DeclareCategory( "IsSimplicialSurfaceIdentification",
					IsComponentObjectRep and IsAttributeStoringRep );


##
##	Define a new family for identifications. The family
##	defines a necessary condition that has to be fulfilled for objects to be 
##	equal to each other. The argument IsSimplicialSurfaceIdentification 
##	guarantees that only objects that lie in this category can be part of the 
##	family.
##
SimplicialSurfaceIdentificationFamily := 
    NewFamily("SimplicialSurfaceIdentificationFamily",  IsObject, 
				IsSimplicialSurfaceIdentification);



#############################################################################
##
##
#!  @Section Constructors for simplicial surface identifications
#!
#!
#!

#!	@Description
#!	Return a simplicial surface identification based on three maps.
#!	@Arguments three bijective maps: for vertices, edges and faces
#!	@Returns a simplicial surface identification
DeclareOperation( "SimplicialSurfaceIdentification", [IsMapping and 
		IsBijective, IsMapping and IsBijective, IsMapping and IsBijective]);

#!	@Description
#!	Return a simplicial surface identification which is constructed from three
#!	lists. The vertex-list has the form [[p_1,q_1],[p_2,q_2],[p_3,q_3]] and
#!	corresponds to the map p_i -> q_i. Analogously for the other two lists.
#!
#!	The NC-version does not check if the lists fulfill this format or if the
#!	number of elements match or if the resulting maps are bijective.
#!
#!	@Arguments three lists of tuples of positive integers
#!	@Returns a simplicial surface identification
DeclareOperation( "SimplicialSurfaceIdentificationByLists", [IsList,IsList,IsList]);
DeclareOperation( "SimplicialSurfaceIdentificationByListsNC", [IsList,IsList,IsList]);



#############################################################################
##
##
#!  @Section Attributes and properties of simplicial surface identifications
#!
#!

#!	@Description
#!	Return the vertex map.
#!	@Arguments a simplicial surface identification
#!	@Returns a bijective map
DeclareAttribute( "VertexMapAttributeOfSimplicialSurfaceIdentification",
		IsSimplicialSurfaceIdentification);
DeclareOperation( "VertexMap", [IsSimplicialSurfaceIdentification] );


#!	@Description
#!	Return the edge map.
#!	@Arguments a simplicial surface identification
#!	@Returns a bijective map
DeclareAttribute( "EdgeMapAttributeOfSimplicialSurfaceIdentification",
		IsSimplicialSurfaceIdentification);
DeclareOperation( "EdgeMap", [IsSimplicialSurfaceIdentification] );


#!	@Description
#!	Return the face map.
#!	@Arguments a simplicial surface identification
#!	@Returns a bijective map
DeclareAttribute( "FaceMapAttributeOfSimplicialSurfaceIdentification",
		IsSimplicialSurfaceIdentification);
DeclareOperation( "FaceMap", [IsSimplicialSurfaceIdentification] );




#############################################################################
##
##
#!  @Section Functions for simplicial surface identifications
#!
#!
#!

#!	@Description
#!	Return if the given simplicial surface identification is well-defined
#!	with respect to the given simplicial surface.
#!	This method checks if the maps of the identification can be applied to
#!	the vertices, edges and faces of the simplicial surface. It also
#!	checks whether the maps are compatible with each other, i.e. if they
#!	commute with the incidence relation of the simplicial surface.
#!	@Arguments a simplicial surface, a simplicial surface identification
#!	@Returns true or false
DeclareOperation( "IsWellDefinedIdentification", 
	[IsSimplicialSurface, IsSimplicialSurfaceIdentification] );


#!	@Description
#!	Return if the given simplicial surface identification is constant on the
#!	intersection for the given simplicial surface with equivalence.
#!	TODO explain what this means
#!	@Arguments a simplicial surface with equivalence, a simplicial surface 
#!	identification
#!	@Returns true or false
DeclareOperation( "IsConstantOnIntersection", 
	[IsSimplicialSurfaceWithEquivalence, IsSimplicialSurfaceIdentification] );


#!	@Description
#!	Return if the given simplicial surface identification can be applied to
#!	the given simplicial surface with equivalence and result in another
#!	simplicial surface with equivalence. To be more precise we check the
#!	property of corollary 2.37 in my master thesis.
#!	@Arguments a simplicial surface with equivalence, a simplicial surface 
#!	identification
#!	@Returns true or false
DeclareOperation( "IsApplicableExtension", 
	[IsSimplicialSurfaceWithEquivalence, IsSimplicialSurfaceIdentification] );

#!	@Description
#!	Extend the equivalence relation of the simplicial surface with
#!	equivalence with a simplicial surface identification.
#!
#!	The NC-version does not run the test IsApplicableExtension.
#!
#!	@Arguments a simplicial surface with equivalence, a simplicial surface
#!		identification
#!	@Returns a simplicial surface with equivalence
DeclareOperation( "ExtendByIdentification",
	[IsSimplicialSurfaceWithEquivalence, IsSimplicialSurfaceIdentification] );
DeclareOperation( "ExtendByIdentificationNC",
	[IsSimplicialSurfaceWithEquivalence, IsSimplicialSurfaceIdentification] );


#
###  This program is free software: you can redistribute it and/or modify
###  it under the terms of the GNU General Public License as published by
###  the Free Software Foundation, either version 3 of the License, or
###  (at your option) any later version.
###
###  This program is distributed in the hope that it will be useful,
###  but WITHOUT ANY WARRANTY; without even the implied warranty of
###  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###  GNU General Public License for more details.
###
###  You should have received a copy of the GNU General Public License
###  along with this program.  If not, see <http://www.gnu.org/licenses/>.
###