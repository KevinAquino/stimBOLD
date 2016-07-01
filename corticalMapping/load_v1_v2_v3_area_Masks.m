 % load_cortical_template.m
%
% This function loads the cortical template derived by Benson et al. 2012.
% It loads the surface derived from freesurfer: fsaverage_sym (left
% hemisphere) and stores it into a structure named "msh". If you have
% vistatools installed then this will 

% Kevin Aquino 2014. (maybe merge

function [retinotopicTemplate] = load_v1_v2_v3_area_Masks(params)
% Here first load the template from Benson et al.
% here load everything
% Take the Left Hemisphere from Freesurfer 
% i.e. fs_average_sym

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

end







