% This core function is a script that runs the entire mvibe from a set of
% functions (make read-only in future).

use_gui = 0;
stimulus_file = 'wedgeExample.txt';
[path_mvibe_toolbox, name, ext]= fileparts(pwd);
addpath(genpath(path_mvibe_toolbox));
% 
% 
% % change the following line if this file is placed in a different
% % directory.
% 
path_fs = getpath_freesurfer([pwd '/GUIcode'],{'data'});
path_fs_cell ={path_fs};

% This section is if you do not have Freesurfer installed and you want to
% use the sections of freesurfer needed for mvibe to run.

matlab_fs =fullfile(path_fs, 'matlab');

if exist(matlab_fs, 'dir')
    addpath(matlab_fs)
else
    addpath(fullfile(path_fs, 'MATLAB'));
end


if(~use_gui)
    % Parameters
    % ================
    % Here load the parameters
    params = loadParameters();
    params.freesurferpath = 'freesurfer/';   
    params.flattenedSurface = 'savedOcciptalPole.mat';
    
    % Visual inputs
    % ================
    % This function should take the results of the image selector then run them
    % in here. I.e. it should effectively run it again - this is to provide
    % consistency.
    
    % This function here loads the stimuli using a file - you pass the file
    % in as an argument. In the gui will not go through this stage as the
    % visual input would have already been loaded.
    [visual_stimulus,params.time_cell] = load_stimuli(stimulus_file);    
    
    
    % This update should be done when loading parameters in the GUI
    params.t_end =  params.time_cell{end} + params.time_afterStim;
    params.t_start = params.time_cell{1};
    params.t = params.t_start:params.dt:params.t_end;    
end

% Retinal Response
% ================
% Here add the components from load_stimuli_GUI, then here create the
% contrast response functions

disp('Retinal Processing..')
[retinal_blur,params] = retinalProcessing(visual_stimulus,params);

% After doing the smoothing calculate the contrast response functions i.e.
% in L*A*B space then using this to calculate the contrast response based
% on the luminance variable.

% After this inital processing is down, it is then reduced in size to
% a set retinal template, i.e. a set of co-ordinates in eccentricity and
% polar angle.     
[retinalTemplate] = load_retinal_template(params);
 
% This here loads the co-ordinates of the image in polar-coordinates, this
% is needed to transform from the visual field to the retinal field. 
[thmat,rmat] = polar_coordinates_gen(size(visual_stimulus{1}, 1),...
    size(visual_stimulus{1}, 2), params);
[retinal_response,params] = retinalContrastResponse(retinal_blur,params,retinalTemplate,thmat,rmat);


% Cortical mapping (from Retina -> LGN -> Primary Visual Cortex)
% ================
% In this section do the mapping from the retina to visual cortex, in here
% will also add things such as the smoothing -> changing with respect to
% visual area.
[msh,params,v1RetinalOutputs,retinotopicTemplate] = corticalProjection(retinal_response,retinalTemplate,params);

% later include the retinal pooling in another function (in cortical
% projection?)

% Neural Response
% ================
disp('NeuralResponse..')
[neuralActivity,neuralInputs,params,msh] = neuralResponse(msh,v1RetinalOutputs,retinotopicTemplate,params);

% Neural Drive Function (including neural responses)
% ================
[zeta] = calculateNeuralDrive(msh,neuralActivity,neuralInputs,params);


% Bold Response
% ================
disp('BOLD model')
[BOLD] = hemodynamicModel(full(zeta),msh,params);


mvibe_output.params = params;
mvibe_output.BOLD = BOLD;
mvibe_output.zeta = zeta;
mvibe_output.visual_response = visual_stimulus;
mvibe_output.msh = msh;
mvibe_output.retinal_response = retinal_response;
mvibe_output.visual_stimulus = visual_stimulus;

% Here is just the visual sitimulus displayed. 
interactive_visualization(mvibe_output);
