% load_retinal_template.m
%
% This function loads the retinal template as specified in the params
% struct.
%
% Kevin Aquino.
% 2014

function [retinalTemplate] = load_retinal_template(params)

if(~isfield(params,'retinalTemplate'))
    %Currently the retinal template is just the eccentricity and polar
    % angle co-ordinates of V1. This can be changed in future, but for now it
    % is a fair approximation as the cortical template has more nodes at
    % lower eccentricity.
    
    [msh,retinotopicTemplate] = load_cortical_template(params);
    retinalTemplate.polarAngle = retinotopicTemplate.polarAreas.v1;
    retinalTemplate.eccentricity = retinotopicTemplate.eccentricityAreas.v1;
else
    errordlg('Nothing here as of yet');
end


% Change this.


end