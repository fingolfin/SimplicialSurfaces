#############################################################################
##
##  SimplicialSurface package
##
##  Copyright 2012-2018
##    Markus Baumeister, RWTH Aachen University
##    Alice Niemeyer, RWTH Aachen University 
##
## Licensed under the GPL 3 or later.
##
#############################################################################

BindGlobal( "__SIMPLICIAL_WriteSurfaceListIntoFile",
    function(file, surfaces)
        local fileOut, surf, string, veString, efString;

        fileOut := OutputTextFile(file, false); # Replace old file
        SetPrintFormattingStatus(fileOut, false);
        for surf in surfaces do
            if not IsSimplicialSurface(surf) then
                Error("Should not have called this method. I hope the file was not important..");
            fi;
            AppendTo(fileOut, "[SimplicialSurfaceByDownwardIncidenceNC,");

            veString := String(VerticesOfEdges(surf));
            RemoveCharacters(veString, " \n\t\r"); # Removes all whitespace
            AppendTo(fileOut, veString);
            AppendTo(fileOut, ",");

            efString := String(EdgesOfFaces(surf));
            RemoveCharacters(efString, " \n\t\r"); # Removes all whitespace
            AppendTo(fileOut, efString);
            AppendTo(fileOut, "]\n");
        od;
        CloseStream(fileOut);
    end
);


# Return all possible locations of the library
BindGlobal( "__SIMPLICIAL_LibraryLocation",
    function()
        local relPath, absPaths;

        relPath := "pkg/simplicial-surfaces/library/";
        # Find all possible paths where GAP might be and add the relative directory
        absPaths := List( GAPInfo.RootPaths, p -> Concatenation(p, relPath) );
        absPaths := Filtered( absPaths, IsDirectoryPath ); # check which ones actually exist

        return absPaths;
    end
);

BindGlobal("__SIMPLICIAL_LibrarySubFilesDirectories",
    function(path)
        local allFiles, subfolders, subfiles;

        allFiles := Difference( DirectoryContents( path ), [".",".."]);
        subfolders := Filtered(allFiles, f -> 
            IsDirectoryPath(Concatenation(path, f)) and
            not StartsWith(f, "_"));
        subfiles := Filtered(allFiles, f -> 
            not IsDirectoryPath(Concatenation(path, f)) and 
            ForAll([".bin",".swp","~"], e -> not EndsWith(f, e)) and  # temporary and index files
            not StartsWith(f, "_") ); # automated files

        return [subfiles, subfolders];
    end
);

DeclareGlobalFunction("__SIMPLICIAL_InitializeLibraryCacheRecursive");
InstallGlobalFunction("__SIMPLICIAL_InitializeLibraryCacheRecursive",
    function(path, dict)
        local subs, subfiles, subfolders, file, folder, subDict;

        subs := __SIMPLICIAL_LibrarySubFilesDirectories(path);
        subfiles := subs[1];
        subfolders := subs[2];

        # Simple files get initialized by an empty list
        for file in subfiles do
            AddDictionary(dict, file, []);
        od;

        # Subdirectories get initialized by a dictionary filled with empty lists
        for folder in subfolders do
            subDict := NewDictionary("string", true);
            __SIMPLICIAL_InitializeLibraryCacheRecursive(Concatenation(path, folder, "/"), subDict);
            AddDictionary(dict, folder, subDict);
        od;
    end
);

BindGlobal("SIMPLICIAL_LIBRARY_CACHE", NewDictionary("string", true)); #TODO The caching does not interact well with linking to other parts of the library
BindGlobal( "__SIMPLICIAL_InitializeLibraryCache",
    function()
        local libraryPath, files;

        libraryPath := __SIMPLICIAL_LibraryLocation();
        if Length(libraryPath) = 0 then
            return; # don't do anything as long as the user does not want to access the library
        fi;
        libraryPath := libraryPath[1];

        __SIMPLICIAL_InitializeLibraryCacheRecursive(libraryPath, SIMPLICIAL_LIBRARY_CACHE);
    end
);
__SIMPLICIAL_InitializeLibraryCache();


DeclareGlobalFunction("__SIMPLICIAL_ParseLibraryQuery");

# Given: Argument list from AllSimplicialSurfaces
# Returns: List of pairs [function, result OR set of possible results]
InstallGlobalFunction( "__SIMPLICIAL_ParseLibraryQuery", 
    function( argList, fctName )
        local trueArg, ind;

        trueArg := [];
        if Length(argList) = 0 then
            return trueArg;
        fi;

        if not IsFunction( argList[1] ) then
            # The first entry is the result of NumberOfFaces
            if not IsPosInt(argList[1]) and not IsList(argList[1]) and not ForAny(argList[1],IsPosInt) then
                Error(Concatenation(fctName, 
                    ": If the first argument is not a function it has to be the",
                    " result of NumberOfFaces, so either a positive integer or",
                    " a list of positive integers."));
            else
                trueArg[1] := [ NumberOfFaces, argList[1] ];
                ind := 2;
            fi;
        else
            ind := 1;
        fi;

        # Now we add pairs of functions and results
        while ind <= Length(argList) do
            if not IsFunction(argList[ind]) then
                Error(Concatenation(fctName,
                    ": The arguments have to alternate between functions and",
                    " their results. On position ", ind, 
                    " a function was expected but not found."));
            fi;
            if IsBound(argList[ind+1]) and not IsFunction(argList[ind+1]) then
                # The next position is a result
                Add(trueArg, [argList[ind], argList[ind+1]]);
                ind := ind+2;
            else
                # The added function should return true
                Add(trueArg, [argList[ind],true]);
                ind := ind+1;
            fi;
        od;

        return trueArg;
    end
);

# Given a polygonal complex and a query (pair [function, result]),
# check whether the complex satisfies the query
BindGlobal( "__SIMPLICIAL_CheckQuery",
    function(complex, query)
        local checkResult;

        checkResult := query[1](complex);
        return checkResult = query[2] or ( IsList(query[2]) and checkResult in query[2] );
    end
);
BindGlobal( "__SIMPLICIAL_CheckQueryList",
    function(complex, queryList)
        local query;

        for query in queryList do
            if not __SIMPLICIAL_CheckQuery(complex, query) then
                return false;
            fi;
        od;
        return true;
    end
);

DeclareGlobalFunction("__SIMPLICIAL_LibraryConstructBinaryRecursive");
InstallGlobalFunction("__SIMPLICIAL_LibraryConstructBinaryRecursive",    
    function(path)
        local subs, subfiles, subfolders, file, fileIn, posList,
            pos, line, out, folder;

        subs := __SIMPLICIAL_LibrarySubFilesDirectories(path);
        subfiles := subs[1];
        subfolders := subs[2];

        for folder in subfolders do
            __SIMPLICIAL_LibraryConstructBinaryRecursive(Concatenation(path, folder, "/"));
        od;


        for file in subfiles do
            fileIn := InputTextFile(Concatenation(path, file));
            posList := [];
            pos := 1;
            line := "";
            while line <> fail do
                posList[pos] := PositionStream(fileIn);
                pos := pos + 1;
                line := ReadLine(fileIn);
            od;
            CloseStream(fileIn);

            out := OutputTextFile(Concatenation(path, file, ".bin"),false);
            SetPrintFormattingStatus(out, false);
            AppendTo(out, "return ");
            AppendTo(out, String(posList));
            AppendTo(out, ";");
            CloseStream(out);
        od;
    end
);
BindGlobal("__SIMPLICIAL_LibraryConstructBinary",
    function()
        local libraryPath;

        libraryPath := __SIMPLICIAL_LibraryLocation();
        if Length(libraryPath) = 0 then
            return; # do not construct an index
        fi;
        libraryPath := libraryPath[1];

        __SIMPLICIAL_LibraryConstructBinaryRecursive(libraryPath);
    end
);

DeclareGlobalFunction("__SIMPLICIAL_ReadLine");
DeclareGlobalFunction("__SIMPLICIAL_LibraryParseString");

InstallGlobalFunction( "__SIMPLICIAL_LibraryParseString",
    function(string, startingDirectory)
        local split, surf;
    
        split := SplitString(string, "", "|\n");
        if Length(split) = 1 then
            # encode a surface
            surf := EvalString(split[1]);
            return surf;
        elif Length(split) = 2 then
            # encode different location
            if not StartsWith(split[1], startingDirectory) then
                # This is the only relevant case - otherwise we will find this surface if we go down another path
                return [split[1], __SIMPLICIAL_ReadLine(split[1], Int(split[2]), startingDirectory)];
            else
                return fail;
            fi;
        fi;
    end
);

BindGlobal("__SIMPLICIAL_ReadFile",
    function(fileIn, queryList, startingDirectory, listCache)
        local line, pos, result, data, surf, res;

        result := [];
        pos := 1;
        line := ReadLine(fileIn);
        while line <> fail do
            if IsBound(listCache[pos]) then
                data := listCache[pos];
                if IsList(data) then
                    if not StartsWith(data[1], startingDirectory) and __SIMPLICIAL_CheckQueryList(data[2],queryList) then
                        Add(result, data[2]);
                    fi;
                else
                    if __SIMPLICIAL_CheckQueryList(data, queryList) then
                        Add(result, data);
                    fi;
                fi;
            else
                surf := __SIMPLICIAL_LibraryParseString(line, startingDirectory);
                if surf <> fail then
                    if IsList(surf) then
                        listCache[pos] := surf;
                        res := surf[2];
                    else
                        res := surf;
                        listCache[pos] := surf;
                    fi;
                    if __SIMPLICIAL_CheckQueryList(res, queryList) then
                        Add(result, res);
                    fi;
                fi;
            fi;
            pos := pos + 1;
            line := ReadLine(fileIn);
        od;

        return result;
    end
);

InstallGlobalFunction( "__SIMPLICIAL_ReadLine",
    function(file, lineNr, startingDirectory, listCache)
        local fileIn, locFileBinary, binIndex, line, split, surf, index, data;

        if IsBound(listCache[lineNr]) then
            data := listCache[lineNr];
            if IsList(data) then
                # This refers to a different part of the library
                if StartsWith(data[1], startingDirectory) then
                    return fail;
                else
                    return data[2];
                fi;
            else
                return data;
            fi;
        fi;

        fileIn := InputTextFile(file);
        locFileBinary := Concatenation(file, ".bin");
        if IsExistingFile(locFileBinary) and IsReadableFile(locFileBinary) then
            binIndex := ReadAsFunction(locFileBinary)();
            SeekPositionStream(fileIn, binIndex[lineNr]);
        else
            # We go through the file manually (which is time-intensive)
            index := 1;
            while index < lineNr do
                ReadLine(fileIn);
            od;
        fi;

        line := ReadLine(fileIn);
        CloseStream(fileIn);
        surf := __SIMPLICIAL_LibraryParseString(line, startingDirectory);
        if surf = fail then
            return fail;
        elif IsList(surf) then;
            listCache[lineNr] := surf;
            return surf[2];
        else
            listCache[lineNr] := surf;
            return surf;
        fi;
    end
);


DeclareGlobalFunction("__SIMPLICIAL_LibraryConstructIndexRecursive");
InstallGlobalFunction("__SIMPLICIAL_LibraryConstructIndexRecursive",
    function(path)
        local subs, subfiles, subfolders, folder, fct, fctName, file,
            fileBinary, binIndex, fileIn, i, line, surf, res, out,
            indexDirPath, fctFile;

        subs := __SIMPLICIAL_LibrarySubFilesDirectories(path);
        subfiles := subs[1];
        subfolders := subs[2];

        for folder in subfolders do
            __SIMPLICIAL_LibraryConstructIndexRecursive(Concatenation(path, folder, "/"));
        od;

        # Create new directory _index
        indexDirPath := Concatenation(path, "_index/");
        CreateDirIfMissing(indexDirPath);
        for fct in [NumberOfVertices, NumberOfEdges] do
            # Create new subdirectory defined by the name of fct
            fctName := NameFunction(fct);
            fctFile := Concatenation(indexDirPath, fctName, "/");
            CreateDirIfMissing(fctFile);

            for file in subfiles do
                # Check all stored surfaces and note down the results
                fileBinary := Concatenation(path, file, ".bin");
                if IsExistingFile(fileBinary) and IsReadableFile(fileBinary) then
                    binIndex := ReadAsFunction(fileBinary)();
                    fileIn := InputTextFile(Concatenation(path, file));

                    for i in [1..Length(binIndex)-1] do
                        SeekPositionStream(fileIn, binIndex[i]);
                        line := ReadLine(fileIn);
                        surf := __SIMPLICIAL_LibraryParseString(line, path);

                        if IsList(surf) then
                            surf := surf[2];
                        fi;

                        res := fct(surf);
                        out := OutputTextFile(Concatenation(fctFile,String(res)), true);
                        AppendTo(out, file);
                        AppendTo(out, " ");
                        AppendTo(out, String(i));
                        AppendTo(out, "\n");
                        CloseStream(out);
                    od;
                    CloseStream(fileIn);
                fi;
            od;
        od;
    end
);
BindGlobal("__SIMPLICIAL_LibraryConstructIndex",
    function()#TODO maybe add some folders to include/exclude?
        local libraryPath;

        libraryPath := __SIMPLICIAL_LibraryLocation();
        if Length(libraryPath) = 0 then
            return; # do not construct an index
        fi;
        libraryPath := libraryPath[1];

        __SIMPLICIAL_LibraryConstructIndexRecursive(libraryPath);
    end
);

BindGlobal("__SIMPLICIAL_LibraryConstructIndexAndBinary",
    function()
        __SIMPLICIAL_LibraryConstructBinary();
        __SIMPLICIAL_LibraryConstructIndex();
    end
);

BindGlobal("__SIMPLICIAL_IndexQueryResults",
    function( queryName, queryResults )
        local result;

        result := [];
        if queryName in ["NumberOfVertices", "NumberOfEdges"] then
            if IsInt(queryResults) then
                Add(result, String(queryResults));
            else
                Append(result, List(queryResults,String));
            fi;
            return result;
        fi;

        return fail;
    end
);


DeclareGlobalFunction("__SIMPLICIAL_AccessLibraryRecursive");

InstallGlobalFunction( "__SIMPLICIAL_AccessLibraryRecursive",
    function(folder, queryList, startingDirectory, dictCache)
        local allFiles, subfolder, subfolders, subfiles, result,
            subDirName, recogFile, check, selectFile, validFiles,
            indexFile, indexUsed, restrictedList, pos, query, file,
            queryName, queryDirectory, possFiles, res, fileIn, line, split,
            queryResults, resFile, location, locFile, surf, subDict,
            listCache;

        allFiles := __SIMPLICIAL_LibrarySubFilesDirectories(folder);
        subfolders := allFiles[2];
        subfiles := allFiles[1];
        
        result := [];

        # Check all subfolders
        for subfolder in subfolders do
            # Ignore folders whose name starts with "_"
            if StartsWith(subfolder, "_") then
                continue;
            fi;

            # Otherwise we try to figure out whether we need to
            # check this subdirectory
            subDirName := Concatenation(folder, subfolder, "/");
            recogFile := Concatenation( subDirName, "_recog.g");
            if IsExistingFile(recogFile) and IsReadableFile(recogFile) then
                check := ReadAsFunction(recogFile)();
                if not check(queryList) then
                    continue;
                fi;
            fi;
            subDict := LookupDictionary(dictCache, subfolder);
            Append(result, __SIMPLICIAL_AccessLibraryRecursive(subDirName, queryList, startingDirectory, subDict));
        od;


        # Preselect the subfiles by name
        selectFile := Concatenation( folder, "_select.g" );
        if IsExistingFile(selectFile) and IsReadableFile(selectFile) then
            check := ReadAsFunction(selectFile)();
            validFiles := check(queryList, subfiles);
        else
            validFiles := subfiles;
        fi;

        # Try to use index files to reduce the number of surfaces that have to be loaded
        indexUsed := false;
        restrictedList := [];
        indexFile := Concatenation(folder, "_index/");
        if IsDirectoryPath(indexFile) then
            for query in queryList do
                queryName := NameFunction( query[1] );
                queryDirectory := Concatenation( indexFile, queryName, "/" );
                if IsDirectoryPath(queryDirectory) and not queryName = "unknown" then
                    queryResults := __SIMPLICIAL_IndexQueryResults(queryName, query[2]);
                    possFiles := [];
                    for res in queryResults do
                        resFile := Concatenation( queryDirectory, res );
                        if IsExistingFile(resFile) and IsReadableFile(resFile) then
                            fileIn := InputTextFile( resFile );
                            line := ReadLine(fileIn);
                            while not line = fail do
                                split := SplitString(line, "", " \n");
                                if Length(split) <> 2 then
                                    Error(Concatenation("LibraryAccess failed for index file ", resFile, " for line ", line));
                                fi;
                                pos := Int(split[2]);
                                if pos = fail then
                                    Error(Concatenation("LibraryAccess failed: index file ", resFile, " has an illegal line: ", line));
                                fi;
                                if split[1] in validFiles then
                                    Add(possFiles, [split[1],pos]);
                                fi;
                                line := ReadLine(fileIn);
                            od;
                            CloseStream(fileIn);
                        fi;
                    od;
                    if not indexUsed then
                        indexUsed := true;
                        restrictedList := possFiles;
                    else
                        restrictedList := Intersection(restrictedList, possFiles);
                    fi;
                fi;
            od;
        fi;

        if indexUsed then
            for location in restrictedList do
                locFile := Concatenation(folder, location[1]);
                if not IsExistingFile(locFile) or not IsReadableFile(locFile) then
                    Error("LibraryAccess: File ", locFile, " is requested by an index but could not be read.");
                fi;
                fileIn := InputTextFile(locFile);
                listCache := LookupDictionary(dictCache, location[1]);
                surf := __SIMPLICIAL_ReadLine(locFile, location[2], startingDirectory, listCache);
                if surf <> fail and __SIMPLICIAL_CheckQueryList(surf, queryList) then
                    Add(result, surf);
                fi;
                CloseStream(fileIn);
            od;
        else
            # We read in all files
            for file in validFiles do
                fileIn := InputTextFile(Concatenation(folder,"/",file));
                listCache := LookupDictionary(dictCache, file);

                Append(result, __SIMPLICIAL_ReadFile(fileIn, queryList, startingDirectory, listCache ));
                CloseStream(fileIn);
            od;
        fi;

        return result;
    end
);

BindGlobal( "__SIMPLICIAL_AccessLibrary",
    function(queryList, startingDirectory)
        local libraryPath, split, dict, s;

        libraryPath := __SIMPLICIAL_LibraryLocation();
        if Length(libraryPath) = 0 then
            Error("Surface library cannot be found.");
        fi;
        libraryPath := Concatenation(libraryPath[1], startingDirectory); # Pick just one of them. If this becomes problematic at some point, solve the problem.

        # Find the correct subdictionary of the cache
        split := SplitString(startingDirectory, "/");
        dict := SIMPLICIAL_LIBRARY_CACHE;
        for s in split do
            dict := LookupDictionary(dict, s);
        od;

        return __SIMPLICIAL_AccessLibraryRecursive(libraryPath, queryList, startingDirectory, dict);
    end
);

InstallGlobalFunction( "AllVEFComplexes",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllVEFComplexes");
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);

InstallGlobalFunction( "AllPolygonalComplexes",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllPolygonalComplexes");
        trueArg := Concatenation( [[IsPolygonalComplex,true]], trueArg );
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);

InstallGlobalFunction( "AllTriangularComplexes",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllTriangularComplexes");
        trueArg := Concatenation( [[IsPolygonalComplex,true],[IsTriangularComplex, true]], trueArg );
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);

InstallGlobalFunction( "AllPolygonalSurfaces",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllPolygonalSurfaces");
        trueArg := Concatenation( [[IsPolygonalSurface,true]], trueArg );
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);

InstallGlobalFunction( "AllSimplicialSurfaces",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllSimplicialSurfaces");
        trueArg := Concatenation( [[IsSimplicialSurface,true]], trueArg );
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);



InstallGlobalFunction( "AllBendPolygonalComplexes",
    function(arg)
        local trueArg;

        trueArg := __SIMPLICIAL_ParseLibraryQuery(arg, "AllBendPolygonalComplexes");
        trueArg := Concatenation( [[IsBendPolygonalComplex,true]], trueArg );
        return __SIMPLICIAL_AccessLibrary(trueArg, "");
    end
);


BindGlobal("__SIMPLICIAL_TestLibraryPerformance",
    function()
        local start;

        start := Runtime();
        AllSimplicialSurfaces(NumberOfEdges, 20);
        AllPolygonalComplexes(NumberOfFaces, [1..20]);
        AllSimplicialSurfaces(EulerCharacteristic, 2, IsClosedSurface);

        return Runtime() - start;
    end
);
