function [  mnEdges, mbVertVertAdjacency, ...
            mbEdgeTriAdjacency, mbTriTriAdjacency, ...
            mbEdgeVertexAdjacency, mbTriVertexAdjacency, ...
            vbBoundaryEdges, vbBoundaryVertex] = ...
               SurfaceAdjacency(mnSurfTri, mfSurface)

% SurfaceAdjacency - FUNCTION Compute surface adjacency relationships
%
% Usage: [  mnEdges, mbVertVertAdjacency, ...
%           mbEdgeTriAdjacency, mbTriTriAdjacency, ...
%           vbBoundaryEdges, vbBoundaryVertex] = ...
%              SurfaceAdjacency(mnSurfTri <, mfSurface>)

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 25th June, 2009

% - Check agurments

if (nargin < 1)
   help SurfaceAjacency;
   return;
end

nNumTriangles = size(mnSurfTri, 1);

if (~exist('mfSurface', 'var'))
   nNumVertices = max(mnSurfTri(:));
else
   nNumVertices = size(mfSurface, 1);
end

%% -- Compute vertex / edge / triangle adjacencies

% - Collect all edges
mnAllEdges = vertcat([mnSurfTri(:, 1:2)   (1:nNumTriangles)'], ...
                     [mnSurfTri(:, 2:3)   (1:nNumTriangles)'], ...
                     [mnSurfTri(:, [3 1]) (1:nNumTriangles)']);

mnAllEdges(:, 1:2) = sort(mnAllEdges(:, 1:2), 2);
                  
% - Collect the edges list
[mnEdges, nul, vnUniqueEdgesIndices] = unique(mnAllEdges(:, 1:2), 'rows'); %#ok<ASGLU,NASGU>

% - Record number of edges
nNumEdges = size(mnEdges, 1);

% - Compute the vertex adjacency matrix
mbVertVertAdjacency = sparse([mnEdges(:, 1); mnEdges(:, 2)], ...
                           [mnEdges(:, 2); mnEdges(:, 1)], true, ...
                           nNumVertices, nNumVertices); %#ok<NASGU>

% - Compute the edge/triangle adjacency matrix
mbEdgeTriAdjacency = sparse(vnUniqueEdgesIndices, mnAllEdges(:, 3), true, nNumEdges, nNumTriangles);
mbTriEdgeAdjacency = mbEdgeTriAdjacency';

% - Compute the tri/tri adjacency matrix

mbTriTriAdjacency = sparse([], [], false, nNumTriangles, nNumTriangles);
for (nTriIndex = 1:nNumTriangles)
   mbTriTriAdjacency(nTriIndex, :) = any(mbTriEdgeAdjacency(:, mbEdgeTriAdjacency(:, nTriIndex)), 2);
end


%% - Compute the edge/triangle adjacency matrix
% - Compute the edge/vertex adjacency matrix
% - Pre-allocate adjacency lists
cellAdjacentVerticesList = cell(nNumEdges, 1);
vbBoundaryEdges = false(nNumEdges, 1);

for (nEdgeIndex = 1:nNumEdges)
   % - Find the triangles associated with this edge
   vbAdjacentTris = mbTriEdgeAdjacency(:, nEdgeIndex);

   % - Check for a boundary edge
   if (nnz(vbAdjacentTris) == 1)
      vbBoundaryEdges(nEdgeIndex) = true; %#ok<AGROW>

      % - Adjacency is only with those points comprising this edge
      vnAdjacentVertices = mnEdges(nEdgeIndex, :);

   else
      % - Find all the points comprising those triangles
      vnAdjacentVertices = mnSurfTri(vbAdjacentTris, :); %#ok<PFBNS>
      vnAdjacentVertices = vnAdjacentVertices(:);
   end

   % - Record adjacency
   cellAdjacentVerticesList{nEdgeIndex} = ...
      [repmat(nEdgeIndex, numel(vnAdjacentVertices), 1) vnAdjacentVertices(:)];
end

% - Construct adjacency matrices
%   Note: Must use logical(sparse(...)), since repeated indices are not
%   supported for logical arrays
mnAdjacentVertices = vertcat(cellAdjacentVerticesList{:});
mbEdgeVertexAdjacency = logical(sparse(mnAdjacentVertices(:, 1), mnAdjacentVertices(:, 2), 1, nNumEdges, nNumVertices)); %#ok<NASGU>

% - Make boundary edges matrix sparse
vbBoundaryEdges = sparse(vbBoundaryEdges);

% - Compute boundary vertices
vnBoundaryVertices = mnEdges(vbBoundaryEdges, :);
vnBoundaryVertices = vnBoundaryVertices(:);
vbBoundaryVertex = logical(sparse(vnBoundaryVertices, 1, 1, nNumVertices, 1)); %#ok<NASGU>


%% - Construct vertex / triangle adjacency matrix

mnVertTris = [ mnSurfTri(:, 1) (1:nNumTriangles)' 1*ones(nNumTriangles, 1);
               mnSurfTri(:, 2) (1:nNumTriangles)' 2*ones(nNumTriangles, 1);
               mnSurfTri(:, 3) (1:nNumTriangles)' 3*ones(nNumTriangles, 1)];
            
% mnTriVertexAdjacency = sparse(mnVertTris(:, 2), mnVertTris(:, 1), mnVertTris(:, 3), nNumTriangles, nNumVertices);
mbTriVertexAdjacency = sparse(mnVertTris(:, 2), mnVertTris(:, 1), true, nNumTriangles, nNumVertices);


% --- END of SurfaceAdjacency.m ---
