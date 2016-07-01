function [LapOp, Convergence] = BelkinMeshLaplacian(TR, Neighbourhood, MeanEdgeLength)  
% ARGUMENTS:
%           TR             -- A triangulation object.
%           Neighbourhood  -- Integer specifying the N-ring to truncate 
%                             approximation.  
%           MeanEdgeLength -- Scalar. Mean edge length of the
%                             triangulation.
%
% OUTPUT: 
%           LapOp       -- Discrete approximation to Laplace-Beltrami operator.
%           Convergence -- Check contribution of the different rings.
% REQUIRES:
%           triangulation2adjacency() 
%           MeshDistance()
%
% USAGE:
%{
       [LapOp, Convergence] = BelkinMeshLaplacian(TR, 8, meanEdgeLength);

       %Plot to check, ratio max outer ring / dominant contribution, the
       %closer to zero these values are the better.
       figure, plot(Convergence ./ max(LapOp))
 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Originally taken from https://github.com/stuart-knock/BrainNetworkModels/blob/master/Surfaces/MeshLaplacian.m

% Set defaults for any arguments that weren't specified
 if nargin<2,
   Neighbourhood = 8; %for spalloc()
 end
 
 
 % Sizes and preallocation
 NumberofVertices = length(TR.Points);
 
 % Slightly overestimate the nonzero elements for spalloc
 % Assume an hexagonal (triangular) lattice, ie, valence is 6.
 AverageNeighboursPerVertex = sum(6*(1:Neighbourhood+1)); 
 LapOp = spalloc(NumberofVertices,NumberofVertices,AverageNeighboursPerVertex*NumberofVertices);

 % Truncated to the N-ring
 if nargin<3,
   SurfaceEdges  = edges(TR);
   NumberOfEdges = length(SurfaceEdges);
   EdgeLengths   = zeros(1,NumberOfEdges);
   for k = 1:NumberOfEdges,
     EdgeLengths(1,k) = dis(TR.Points(SurfaceEdges(k,1),:).', TR.Points(SurfaceEdges(k,2),:).');
   end
   MeanEdgeLength = mean(EdgeLengths);
 end
 
 % Compute LBO
 % NOTE: 'h' needs to be set such that the Nth ring contributes ~ 0...
 h = MeanEdgeLength * Neighbourhood/4;
 h4 = h * 4; 
 C1 = 1/(4*pi*h^2);
 
 Convergence = zeros(1,NumberofVertices);
 for i = 1:NumberofVertices,
   [LocalVertices, LocalTriangles, GlobalVertexIndices, ~, nRing] = GetLocalSurface(TR, i, Neighbourhood);
   LocalTriangleU = LocalVertices(LocalTriangles(:,2),:) - LocalVertices(LocalTriangles(:,1),:);
   LocalTriangleV = LocalVertices(LocalTriangles(:,3),:) - LocalVertices(LocalTriangles(:,1),:);
   
   LocalTriangleArea = sqrt(sum(cross(LocalTriangleU,LocalTriangleV).^2, 2))./2;
   
   %Get distance to vertices in neighbourhood of current vertex
   %This function fails for Neighborhood 1 because of internal checks
   %regarding the size of vertices and faces.
   LocalAdjacency = triangulation2adjacency(LocalTriangles.');
   DeltaX = MeshDistance(full(LocalAdjacency)).';
   %TODO: Consider using perform_fast_marching_mesh in the future. 
   %      The main disadvantage is that it adds extra dependencies.
   %DeltaX = perform_fast_marching_mesh(LocalVertices.', LocalTriangles.', 1);
   DeltaX = DeltaX(2:end).';
   
   %
   NumberOfTriangles = zeros(1,length(LocalVertices)-1);
   AreaOfTriangles   = zeros(1,length(LocalVertices)-1);
   for k=1:length(LocalVertices)-1,
     NumberOfTriangles(k) = sum(LocalTriangles(:)==(k+1)); %of each vertex in our local patch of surface
     [TrIndi, ~] = find(LocalTriangles==(k+1));
     AreaOfTriangles(k) = mean(LocalTriangleArea(TrIndi));
   end
   
   %
   LapOp(GlobalVertexIndices(2:end),i) = C1 * AreaOfTriangles./3 .* NumberOfTriangles .* exp(- DeltaX.^2 ./h4);
   %NOTE: the 1/h^2 in C1 has the role of  division by dx^2,  as it corresponds to an effective
   %      neighbourhood considered by the Laplacian. ?THINK THIS IS TRUE?
   %      So don't do: LapOp(GlobalVertexIndices(2:end),i) = LapOp(GlobalVertexIndices(2:end),i).' ./ DeltaX.^2;
   
   %TODO: Add check of outer ring values, if > critical value then increase neighbourhood...
   Convergence(1,i) = max(LapOp(GlobalVertexIndices((end-nRing(1,Neighbourhood)+1):end),i));
   
   LapOp(i,i) = -sum(LapOp(:,i));
   clear LocalVertices  LocalTriangles GlobalVertexIndices 
end
       
end %function BelkinMeshLaplacian()