%% First load the template

params.freesurferpath = 'freesurfer/';
params.retinotopicTemplate = 'corticalMapping/2014-11-03-Benson_Template.mgz';

[msh,retinotopicTemplate] = load_cortical_template(params);


%%

msh = meshVisualize(msh);

%%


p.actor = msh.actor;
p.colors = msh.colors;
allEc = (cell2mat(struct2cell(retinotopicTemplate.eccentricityAreas)));
v1v2v3 = retinotopicTemplate.visualAreas.All;


p.colors(1:3,v1v2v3) = 255*meshData2Colors(log(allEc), (hsv(256).'),[log(0.5) log(90)]);
[id,stat,res] = mrMesh('localhost', msh.id, 'modify_mesh', p);



%% now make the ring around the center

% [nodes,edges] = buildEdgeListFromTriangles(msh); 
% This operation is very intensive, beware the time it takes - might have to make
% this into a mex file because it takes so damn long. The problem is that
% we rely mrManDist which has to be compiled in a machine. 

% Here is the pre-calculated version:
load edges_nodes_vista.mat;



% now to work out the central point look at V1, and get the lowest
% eccentricity

[minEcValue,ind] = min(retinotopicTemplate.eccentricityAreas.v1);

fovealNode = retinotopicTemplate.visualAreas.v1(ind);
% now get the index:
[allDist,nPts,lastPoint] = mrManDist(double(nodes), double(edges), fovealNode-1,[1 1 1], -1,0);

distance = 80; % 80 mm from the foveal Node
Perimeter = find(abs(allDist-distance) <= 0.2);

allPts = find(allDist<distance);

[msh2] = getSubMesh(msh,allPts);

p.colors(1:3,allPts) = 0;
[id,stat,res] = mrMesh('localhost', msh.id, 'modify_mesh', p);


%% 
% % next step is to make the flatted map, this also takes some time in the
% % current form. Will have to make into a mex file at some point.
tic
[mfTutteMap] = TutteMap(msh2.submesh.triangles.'+1);
toc