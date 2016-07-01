function [msh] = getSubMesh(msh,storedVertices)

% getSubMesh.m : code to make a submesh from the ROI input on mrMeshSrv.
% This code also includes two matrices to transfer between the full to the
% submesh and vice-versa.
%
% note: you must draw the ROI and fill it or add the extra flag to do so.
%
% Kevin Aquino 2014
%



faces = msh.triangles.' + 1;
vertices = msh.vertices.';

if (nargin < 2),
    
    [id,stat,val] = mrMesh('localhost', msh.id, 'get_cur_roi');
    
    val.vertices = val.vertices +1 ;
    val.vertices = unique(val.vertices);
    storedVertices = val.vertices;
    
    
    % now restrict the vertices and the faces:
    svertices = vertices(val.vertices,:);
else
    svertices = vertices(storedVertices,:);
end

% for the faces just find where they are

[h h2] = ismember(faces,storedVertices);
sum3 = sum(h,2);
sfaces = faces(sum3==3,:);
fac2 = h2(sum3==3,:);


% Now setting the submesh structure and importants parts of it.
% =================================================================
submesh = struct;

submesh.lights = msh.lights;
submesh.id = 5;
submesh.triangles = fac2.' - 1;
submesh.vertices = svertices.';
submesh.fullMeshIndices = storedVertices; % This list gives you what the subvertices correspond to
submesh.colors = msh.colors(:,storedVertices);
submesh.oldColors = msh.colors(:,storedVertices);

% fullToSub gives you the sparse matrix to transfer from the full mesh to
% the submesh. To get the points on the submesh:
% [nold submeshVertices] = find(fullToSub(fullMeshVerts,:))
%
% note: output gives unique and sorted indices.

fullToSub = sparse(submesh.fullMeshIndices,1:length(submesh.vertices),1,length(msh.vertices),length(submesh.vertices)); 
submesh.fullToSub = fullToSub;

% The inverse matrix is subToFull, to project the submesh points onto the
% full mesh you do the following:
% [nsub fullMeshVertices] = find(subToFull(submeshVerts,:))
%
% note: output gives unique and sorted indices. You can get the direct and unsorted mapping by having:
% fullVerts = fullMeshIndices(submeshVerts) instead

subToFull = sparse(1:length(submesh.vertices),submesh.fullMeshIndices,1,length(submesh.vertices),length(msh.vertices));
submesh.subToFull = subToFull;

msh.submesh = submesh;
msh.submesh.mappedInds = storedVertices;