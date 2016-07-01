% load_cortical_template.m
%
% This function loads the cortical template derived by Benson et al. 2012.
% It loads the surface derived from freesurfer: fsaverage_sym (left
% hemisphere) and stores it into a structure named "msh". If you have
% vistatools installed then this will 

% Kevin Aquino 2014.
%              20-Nov-2014 Cleaned up, removed a lot of the output
%              arguments.

function [msh,retinotopicTemplate] = load_cortical_template(params)
% Here first load the template from Benson et al.
% here load everything
% Take the Left Hemisphere from Freesurfer 
% i.e. fs_average_sym


% ============ Loading retinotopic template ============================= %

% load up the specified template in mgz format:
data = MRIread(params.retinotopicTemplate);

% Set the polar angle template
polar_angle_template = squeeze(data.vol(1,1,:,1));

if(isfield(params,'normalizedTemplate'))
    if(params.normalizedTemplate)    
        polar_angle_template = (polar_angle_template-90)/90*pi/2;
    end
end       
% eccentricity template:
eccentricity_template = squeeze(data.vol(1,1,:,2));

% area information:
area_template = squeeze(data.vol(1,1,:,3));


% Here is a segment of code to store all visual cortex vertices from V1-V3,
% we are not using the V4 vertices at the moment.
% v1v2v3Atlas = intersect(find(area_template >= 1),find(area_template <=3));


visualAreas.v1 = find(abs(area_template) == 1);
visualAreas.v2 = find(abs(area_template) == 2);
visualAreas.v3 = find(abs(area_template) == 3);
visualAreas.All = [visualAreas.v1(:).' visualAreas.v2(:).' visualAreas.v3(:).'];

eccentricityAreas.v1 = eccentricity_template(visualAreas.v1);
eccentricityAreas.v2 = eccentricity_template(visualAreas.v2);
eccentricityAreas.v3 = eccentricity_template(visualAreas.v3);

polarAreas.v1 = polar_angle_template(visualAreas.v1);
polarAreas.v2 = polar_angle_template(visualAreas.v2);
polarAreas.v3 = polar_angle_template(visualAreas.v3);


retinotopicTemplate.visualAreas         = visualAreas;
retinotopicTemplate.eccentricityAreas   = eccentricityAreas;
retinotopicTemplate.polarAreas          = polarAreas;

% ============ Loading cortical Surface ============================= %


% Load the surface data

fname = [params.freesurferpath 'subjects/fsaverage_sym/surf/lh.sphere'];
[spherevertices, faces] = read_surf(fname);

fname = [params.freesurferpath 'subjects/fsaverage_sym/surf/lh.inflated'];
[inflatedvertices, faces] = read_surf(fname);

fname = [params.freesurferpath 'subjects/fsaverage_sym/surf/lh.orig'];
[vertices, faces] = read_surf(fname);


% now load all the data into a structure named "msh". This is used for
% visualization purposes.

% First load the vertices and the triangles and look at the curvature map:
msh.triangles           = faces(:,1:3).'; % faces index starts from 0
msh.vertices            = (vertices).';
msh.originalvertices    = msh.vertices; % need to keep them stored for later use.
msh.inflatedvertices    = (inflatedvertices).';
msh.spherevertices      = (spherevertices).';
msh.colors              = [];

% set the color values, currently set to a default value of 0, the last row
% defines the highest value of the colormap.
totalColors = zeros(4,length(vertices));
totalColors(4,:) = 255;


% now load the curvature values that were precalculated and presmoothed by
% freesurfer.

[curv, fnum]            = read_curv([params.freesurferpath 'subjects/fsaverage_sym/surf/lh.curv']);
msh.curvature           = -curv.';
  
mod_depth               = 0.5;
curvatureColorValues    = ((2*msh.curvature>0) - 1) * mod_depth * 128 + 127.5;
totalColors(1:3,:) = repmat(curvatureColorValues,[3 1]);


% mrVistaFlags, this is if mrVista is installed on the system, 
% see: https://www.stanford.edu/group/vista/cgi-bin/home/
% Spefically we take advantage of vista tool's surface viewer: mrMeshSrv
% that loads faces, vertices, and colors onto surfaceviewer developed from 
% VTK.
%


% if(exist('mrmStart.m','file'))     
    
    
    msh.id = 1;
    
    lights{1}.actor = 33;
    lights{1}.ambient = [0.4000 0.4000 0.3000];
    lights{1}.diffuse =  [0.5000 0.5000 0.6000];
    lights{1}.origin = [500 0 300];
    
    lights{2}.actor = 34;
    lights{2}.ambient = [0.4000 0.4000 0.3000];
    lights{2}.diffuse =  [0.5000 0.5000 0.6000];
    lights{2}.origin = [-500 0 -300];
    msh.lights = lights;
% end

msh.colors = totalColors;

% === Last step: Loading in the perimeters of V1,V2 v/d,V3 v/d - not
% working for V2 v/d have to deal with stray points in border detection.
% 
% 
visualAreaBorders.v1 = getPerimeterFromROI(msh,retinotopicTemplate.visualAreas.v1);
% 
% v2dInds = find((area_template) == 2);
% v2vInds = find((area_template) == -2);
% 
% v3dInds = find((area_template) == 3);
% v3vInds = find((area_template) == -3);
% 
% visualAreaBorders.v2d = getPerimeterFromROI(msh,v2dInds);
% visualAreaBorders.v2v = getPerimeterFromROI(msh,v2vInds);
% visualAreaBorders.v3d = getPerimeterFromROI(msh,v3dInds);
% visualAreaBorders.v3v = getPerimeterFromROI(msh,v3vInds);
% 
retinotopicTemplate.visualAreaBorders = visualAreaBorders;





