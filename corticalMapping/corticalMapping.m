% CorticalMapping.m
% ======================================================
% The purpose of this script is to load in the fsaverage cortex derived
% from freesurfer, then map the visual field to the cortex.
%
% Kevin Aquino, 2014.
%
% To load in the cortical mapping, we first load in the cortical template,
% then we transform the data onto that.


% loading of the template:
surf_path = [freesurferpath 'subjects/fsaverage_sym/surf/'];
[msh,v1v2v3Atlas,eccentricity_template,polar_angle_template] = load_cortical_template(surf_path);

show_template = 1;


if(exist('mrmStart.m','file')) 
    % Section here just to look at the template data if you want to see it.
    
    % These two lines are needed to open the mesh for visual display when using
    % mrMeshSrv.app
    
    msh = meshVisualize(msh);
    msh.idOpen = msh.id;
    
    if (show_template == 1);
        p.actor = msh.actor;
        p.colors = msh.colors;
        %     p.colors(1:3,v1v2v3Atlas) = 255*meshData2Colors((polar_angle_template(v1v2v3Atlas)), (hsv(256).'),[-1 1]);
        p.colors(1:3,v1v2v3Atlas) = 255*meshData2Colors((eccentricity_template(v1v2v3Atlas)), (hsv(256).'),[0 20]);
        [id,stat,res] = mrMesh('localhost', msh.id, 'modify_mesh', p);
        
    end;
else
    % right now do nothing, but will add a visualization function to show
    % such a thing.
    
end;


% transforming of the visual stimulus onto the template, need something
% such as the imageMatrix onto there.

stimMap = maskImagesToVertices(eccentricity_template,polar_angle_template,v1v2v3Atlas,rmat,thmat);
