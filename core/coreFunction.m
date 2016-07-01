% This core function is a script that runs the entire mvibe from a set of
% functions (make read-only in future).

function coreFunction(hObject,~)

use_gui = 1;

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

gui_data = guidata(get(hObject,'Parent'));
stimBOLD_output = gui_data.stimBOLD_output;
visual_stimulus = stimBOLD_output.visual_stimulus;
params = stimBOLD_output.params;

set(gui_data.handles.simulationButton,'enable','off');

% Retinal Response
% ================
% Here add the components from load_stimuli_GUI, then here create the
% contrast response functions

statusbar(gui_data.handles.main_gui,'Retinal processing...')
params.useGUI = 0;

% convert the visual stimulus into LAB space
cform =makecform('srgb2lab');

for j=1:length(visual_stimulus),
    visual_stimulus_lab{j} = im_labrgb_convert(visual_stimulus{j},cform);
end

[retinal_blur,params] = retinalProcessing(visual_stimulus_lab,params);

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

statusbar(gui_data.handles.main_gui,'Calculating Retinal contrast response...')
[retinal_response,params] = retinalContrastResponse(retinal_blur,params,retinalTemplate,thmat,rmat);


% Cortical mapping (from Retina -> LGN -> Primary Visual Cortex)
% ================
% In this section do the mapping from the retina to visual cortex, in here
% will also add things such as the smoothing -> changing with respect to
% visual area.
statusbar(gui_data.handles.main_gui,'Calculating Cortical Projection...')
[msh,params,v1RetinalOutputs,retinotopicTemplate] = corticalProjection(retinal_response,retinalTemplate,params);

% later include the retinal pooling in another function (in cortical
% projection?)

% Neural Response
% ================
statusbar(gui_data.handles.main_gui,'Calculating the neural response...')
[neuralActivity,neuralInputs,params,msh] = neuralResponse(msh,v1RetinalOutputs,retinotopicTemplate,params);

% Neural Drive Function (including neural responses)
% ================
[zeta] = calculateNeuralDrive(msh,neuralActivity,neuralInputs,params);


% Bold Response
% ================
statusbar(gui_data.handles.main_gui,'Calculating the BOLD response...')
[BOLD] = hemodynamicModel(full(zeta),msh,params);


stimBOLD_output.params = params;
stimBOLD_output.BOLD = BOLD;
stimBOLD_output.zeta = zeta;
stimBOLD_output.msh = msh;
stimBOLD_output.retinal_response = retinal_response;

gui_data.stimBOLD_output = stimBOLD_output; 
% gui_data.params = params;

guidata(get(hObject,'Parent'),gui_data);

statusbar(gui_data.handles.main_gui,'Done!')

interactive_visualization(stimBOLD_output,gui_data.handles.simPanel);

set(gui_data.handles.simulationButton,'enable','on');
end