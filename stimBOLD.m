% stimBOLD
%
% A computational framework to estimate the BOLD response directly from an
% input stimulus.
%
% Kevin Aquino
% Mark Schira
% Peter Robinson.
%
% Acknowledgments:
% Wenbin Shao       - for computional work
% Romesh Abeysuriya - for GUI and visualization assistance
% Thomas Lacy       - for help in equations
% Michael Breakspear- help in development of the model
% Noah Benson       - Aiding of the retinotopic template

% Add the current directory of stimBOLD to the path (and all its
% subfolders)
addpath(genpath(pwd));
% Generate 
path_fs = getpath_freesurfer([pwd filesep 'GUIcode'],{'data'});
path_fs_cell ={path_fs};

% This section is if you do not have Freesurfer installed and you want to
% use the sections of freesurfer needed for stimBOLD to run.

matlab_fs =fullfile(path_fs, 'matlab');

if exist(matlab_fs, 'dir')
    addpath(matlab_fs)
else
    addpath(fullfile(path_fs, 'MATLAB'));
end

% Now start the main GUI
stimBOLDGUI();