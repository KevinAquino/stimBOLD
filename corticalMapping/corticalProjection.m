function [msh,params,v1RetinalOutputs,retinotopicTemplate] = corticalProjection(retinal_response,retinalTemplate,params,fig_display)
% CorticalProjection.m
% ======================================================
% The purpose of this script is to load in the fsaverage cortex derived
% from freesurfer, then map the visual field to the cortex.
% Input:
% Output: stimMap
%
% NOTES
% Kevin Aquino, 2014.
% SHAO Wenbin, 01-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 12-May-2014  modify the code to work with cell input.
% Ver. 18-May-2014  code improvement
% Ver. 14-Jul-2014  KMA: changed so vista tools is not used, will add this
%                   somewhere else in future. Also fixed "show_template"
%                   options. 
% Ver. 30-Oct-2014  Add display status
% Ver. 20-Nov-2014  (Overhaul) Changing how the cortical mapping works.
%
% To load in the cortical mapping, we first load in the cortical template,
% then we transform the data onto that.
%

if params.useGUI &&(~isfield(params, 'freesurferpath'))
       params.freesurferpath = uigetdir([],'Choose the freesurfer path');
end

if nargin<5
    fig_display =[];
end

% loading of the cortical template and the cortical surface.
[msh,retinotopicTemplate] = load_cortical_template(params);

% transforming of the visual stimulus onto the template, need something
% such as the imageMatrix onto there.
 if ~isempty(fig_display)
    statusbar(fig_display, 'Cortical projection, phase 1 of 2...');
 end

% This is the biggest stage of the cortical projection, we take the
% retinal_response and find the corresponding co-ordinates in V1
% from this we use this mapping to then find out the mapping on the
% cortical surface.

rettoV1 = polarMappingCoordinateTransfer(retinotopicTemplate.eccentricityAreas.v1,retinotopicTemplate.polarAreas.v1,retinalTemplate.eccentricity,retinalTemplate.polarAngle);
msh.rettoV1 = rettoV1;

% Now we use this to map onto V1 from the retina:
v1RetinalOutputsPolar = mapResponseToRegion(retinal_response,rettoV1).';

% The next stage is to assign this to the cortex.
indsV1 = retinotopicTemplate.visualAreas.v1;
tind = 1:length(params.t);

[ii,tt] = meshgrid(indsV1,tind);

v1RetinalOutputs = sparse(tt(:),ii(:),v1RetinalOutputsPolar(:),length(params.t),size(msh.originalvertices,2));


% Here also load in the save occipital pole, we restrict the simulation to
% this small area to decrease the memory load on the system.

load(params.flattenedSurface);
[msh] = getSubMesh(msh,storedVertices);
msh.flatCoord = flatCoord;

end


function mappedResponse = mapResponseToRegion(response,mappingTransformation)
    
% need to do the mapping for sparse matrices

for k=1:size(response,2),
    mappedResponse(:,k) = mappingTransformation.'*response(:,k);
end

end
