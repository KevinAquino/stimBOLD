% stimBOLDGUI.m
% This function loads the Main GUI for stimBOLD, It calls coreFunction - a
% function that runs the calculations.
%
% Kevin Aquino 
% First created: 2014
%
function stimBOLDGUI()

% Primary initialization:
stimBOLD_output = struct;

% Initalize the figure
use_gui = 1;
quote = '''';
handles = struct;
figure_size = [20 20 160 50];
handles.main_gui = figure ('windowstyle', 'normal', 'resize', 'on','visible','off',...
    'Renderer', 'zbuffer','menubar','none','Toolbar','none','numbertitle','off', ...
    'name','stimBOLD','units','Character','OuterPosition',figure_size); 

% This here to set the minimum size for the GUI
set_minimum_size(handles.main_gui);

% Load, then set the stimBOLD Logo
img = imread(['GUIcode' filesep 'data' filesep 'logo.png']);
handles.logo_handle = axes('Parent',handles.main_gui,'units','Character','Position',[8 35 50 10]);
imshow(img,'Parent',handles.logo_handle);

% Create the save and load handles in the main GUI
handles.file_menu = uimenu(handles.main_gui,'label','File');
handles.load_label = uimenu(handles.file_menu,'label','Load');
handles.save_label = uimenu(handles.file_menu,'label','Save');
set(handles.load_label,'Callback',@load_data);
set(handles.save_label,'Callback',@save_data);

% Set a status bar.
statusbar(handles.main_gui,'stimBOLD ready.')

% Now make the side panel (on the left)
handles.inputsPanel = uipanel('Parent',handles.main_gui,'units','character','Position',[8 3 50 28]);

% Add the simulation buttong that is called "GO"
handles.simulationButton = makeButton(handles.inputsPanel,[10 1 30 6],'GO',@coreFunction);
set(handles.simulationButton,'enable','off');

% now make the buttons for the left panel
handles.paramsButton = makeButton(handles.inputsPanel,[10 22 30 3],'Model Parameters',@load_model_parameters);
handles.visStimButton = makeButton(handles.inputsPanel,[10 16 30 3],'Visual Inputs',@vis_calc_gui);

% initialize the display figure.
handles.simPanel = uipanel('Parent',handles.main_gui,'units','character','Position',[66 3 85 40]);
set(handles.main_gui,'visible','on');

gui_data = guidata(handles.main_gui);
gui_data.handles = handles;

% Loading of default parameters
params = loadParameters();
gui_data.stimBOLD_output.params = params;
% =================================

guidata(handles.main_gui,gui_data);

drawnow;
set(handles.main_gui,'ResizeFcn',@resizeFunction);
resizeFunction(handles.main_gui,[]);

end

function handles = resizeMainWindow(handles)
% this here resizes the window, currently not in use but its callback is
% there for future use.
end

% Default function to make the buttons
function buttonHandle = makeButton(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
buttonHandle = uicontrol ( 'parent', parentPanel, 'style', 'pushbutton', 'units', 'character', 'position', position, 'string', boxStr, 'fontsize', fontSize,'CallBack',callBackStr);
end

function load_model_parameters(hObject,~)
% Function to load the model parameters. This loads in a table.
load_params_table(get(hObject,'parent'));
end

% Loading Function for previously calculated data.
function load_data(hObject,~)

file = uigetfile('.mat');
gui_data = guidata(get(hObject,'parent'));
statusbar(gui_data.handles.main_gui,'Loading file...')
if(~isempty(file))
    try
        load(file);
        gui_data.stimBOLD_output = stimBOLD_output;
        guidata(get(hObject,'Parent'),gui_data);
        
        clear stimBOLD_output;
        statusbar(gui_data.handles.main_gui,'Displaying response...')
        interactive_visualization(gui_data.stimBOLD_output,gui_data.handles.simPanel);
        statusbar(gui_data.handles.main_gui,'Done!')
        set(gui_data.handles.simulationButton,'enable','on');
    catch
        statusbar(gui_data.handles.main_gui,'Error..')
    end
else
    statusbar(gui_data.handles.main_gui,'Load file cancelled.')
end


end

% Saving Function, to load up for future use.
function save_data(hObject,~)
gui_data = guidata(get(hObject,'parent'));
file = uiputfile('.mat');

if(~isempty(file))
    try
        save(file,gui_data.stimBOLD_output);
    catch
        statusbar(gui_data.handles.main_gui,'File not saved, error.')
    end
else
    statusbar(gui_data.handles.main_gui,'Save file cancelled.')
end

end

% This resize function resizes the main GUI according to specific
% rules,keeping spacings of the logo and the buttons in set spacing. This
% must be changed everytime a new button-like feature is added
function resizeFunction(hObject,~)

GUI_data = guidata(hObject);
outerPosition = get(hObject,'Position');

parentWidth = outerPosition(3);
parentHeight = outerPosition(4);

handles = GUI_data.handles;

logo_width = 50;logo_height = 10;
inputs_width = 50;inputs_height = 28;
top_spacing = 2;
bottom_spacing = 4.25;

logo_y = parentHeight - logo_height - top_spacing;
inputs_y = parentHeight - inputs_height - logo_height - 2*top_spacing;
sim_panel_x = 66;
sim_panel_width = parentWidth - logo_width - 8 - 17;
sim_panel_height = parentHeight - top_spacing - bottom_spacing;



set(handles.logo_handle,'Position',[8 logo_y logo_width logo_height]);
set(handles.inputsPanel,'Position',[8 inputs_y inputs_width inputs_height]);
set(handles.simPanel,'Position',[sim_panel_x bottom_spacing sim_panel_width sim_panel_height]);



end