function [mfTutteMap] = TutteMap(mnTriangulation)

% TutteMap - FUNCTION Use Tutte's algorithm to map a surface mesh to a planar unit circle
%
% Usage: [mfTutteMap] = TutteMap(mnTriangulation)
%
% Maintaining the existing triangulation, this function maps a surface mesh onto
% a planar unit circle.  Tutte's algorithm [1] is used.  The simple technique
% for finding point locations is from [2].
%
% 'mnTriangulation' is an Nx3 array as returned by delaunayn, defining the
% triangulation of the surface mesh.  'mfTutteMap' will be an Mx2 array, each
% row of which defines the planar location of a vertex.  The surface
% triangulation should contain no holes, and must have a boundary!  The first
% boundary cycle will be mapped onto the unit circle, with the interior points
% mapped inside the circle such that no edge crossings occur.
%
% References:
% [1] Tutte, 1963. "How to draw a graph". Proc. Lond. Math. Soc. 13, 743-768.
% [2] Kocay & McLeod, 2005. "Novel approaches to placement". Canadian Conference
% on Electrical and Computer Engineering 2005, 1931-1934.

% -- Check arguments

if (nargin < 1)
   disp('*** TutteMap: Incorrect usage');
   help TutteMap;
   return;
end

% - Record input sizes
nNumTriangles = size(mnTriangulation, 1);
nNumVertices = max(mnTriangulation(:));

[mnEdges, mbVertexAdjacency, ...
 mbEdgeTriAdjacency, mbTriTriAdjacency, ...
 mbEdgeVertexAdjacency, mbTriVertexAdjacency, ...
 vbBoundaryEdges, vbBoundaryVertex] = ...
      SurfaceAdjacency(mnTriangulation);
nNumEdges = size(mnEdges, 1);


%% -- Find the boundary cycle

% - First, find all boundary cycles

nBoundaryCycle = 0;
bFindCycles = true;
vbEdgeOnACycle = false(nNumEdges, 1);

while (bFindCycles)
   nBoundaryCycle = nBoundaryCycle + 1;
   
   % - Find the first boundary edge
   vnCycleEdges = find(vbBoundaryEdges & ~vbEdgeOnACycle, 1, 'first');
   nThisEdge = vnCycleEdges;
   vnCycleVertices = mnEdges(vnCycleEdges, :);
   nThisVertex = mnEdges(vnCycleEdges, 2);
   vbEdgeOnThisCycle = false(nNumEdges, 1);
   vbEdgeOnThisCycle(nThisEdge) = true;
   vbVertexOnThisCycle = false(nNumVertices, 1);
   vbVertexOnThisCycle(vnCycleVertices) = true;
   
   bKeepTracing = true;
   while (bKeepTracing)
      % - Find the next edge 
      nNextEdge = find(mbEdgeVertexAdjacency(:, nThisVertex) & vbBoundaryEdges & ~vbEdgeOnThisCycle & ~vbEdgeOnACycle, 1, 'first');
      
      if (isempty(nNextEdge))
         bKeepTracing = false;
         continue;
      end
      
      nNextVertex = mnEdges(nNextEdge, mnEdges(nNextEdge, :) ~= nThisVertex);

      % - Record this edge and vertex
      vnCycleEdges = [vnCycleEdges nNextEdge]; %#ok<AGROW>
      vnCycleVertices = [vnCycleVertices nNextVertex]; %#ok<AGROW>
      vbEdgeOnThisCycle(nNextEdge) = true;
      vbVertexOnThisCycle(nNextVertex) = true;
      
      nThisVertex = nNextVertex;
   end

   % - Record this cycle
   cellBoundaryCycles{nBoundaryCycle} = vnCycleVertices(1:end-1); %#ok<AGROW>
   vnCycleLengths(nBoundaryCycle) = numel(vnCycleVertices)-1; %#ok<AGROW>
   
   % - Should we continue?
   vbEdgeOnACycle = vbEdgeOnACycle | vbEdgeOnThisCycle;
   bFindCycles = any(vbBoundaryEdges & ~vbEdgeOnACycle);
end

% - Identify the boundary cycle

if (numel(cellBoundaryCycles) > 1)
   disp('--- TutteMap: Warning: A handle exists in the surface; the surface is not planar.');
   disp('       The mapped output may have intersections.');
end

[nul, nBoundaryCycle] = max(vnCycleLengths); %#ok<ASGLU,NASGU>
vnCycleVertices = cellBoundaryCycles{nBoundaryCycle};


%% -- Map the boundary cycle vertices to the unit circle

mfTutteMap = nan(nNumVertices, 2);

nCycleLength = numel(vnCycleVertices);
vfAngles = linspace(0, 2*pi, nCycleLength+1)';
vfAngles = vfAngles(1:end-1);

mfTutteMap(vnCycleVertices, :) = [cos(vfAngles) sin(vfAngles)];


%% -- Compute other vertex locations

% - Construct A and B matrices
vbVertexOnCycle = false(nNumVertices, 1);
vbVertexOnCycle(vnCycleVertices) = true;
vnNotOnCycle = find(~vbVertexOnCycle);

A = double(mbVertexAdjacency(vnNotOnCycle, vnCycleVertices));
B = -double(mbVertexAdjacency(vnNotOnCycle, vnNotOnCycle));

% - Annotate B matrix with vertex degrees
for (nVertex = 1:numel(vnNotOnCycle))
   B(nVertex, nVertex) = nnz(mbVertexAdjacency(vnNotOnCycle(nVertex), :));
end

% - Find interior vertex locations
% Binv = inv(B);
mfTutteMap(vnNotOnCycle, :) = B \ A * mfTutteMap(vnCycleVertices, :);

% --- END of TutteMap.m ---
