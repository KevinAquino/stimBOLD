% This function creates the main GUI for the toolbox, that allows the user
% to access all parts of the code.

% Turn into a function and create global variables to access all different
% parts of the code.



function [mvibe_output] = create_main_gui_tester()
% vis_response_present = NaN;

mvibe_output = struct;

main_gui = figure ('windowstyle', 'normal', 'resize', 'on','visible','off',...
    'Renderer', 'OpenGL','menubar','none','Toolbar','none','numbertitle','off','name','M-ViBe','color','white'); % Add this line to disable the following warning
% Warning: RGB color data not yet supported in Painter's mode


img = imread('GUIcode/data/logo.png');

computation_panel = uipanel('Parent',main_gui,'Title','Computation','units','character','Position',[1 10 100 10]);
% computation_panel = uipanel('Parent',main_gui,'Title','Computation','units','character','Position',[.01 0.3 .98 .4]);

visualization_panel = uipanel('Parent',main_gui,'Title','Visualization, Loading and Saving','Position',[.01 0.1 .98 .2]);


% Make images For processing later
% ah1 = axes('Parent',main_gui,'Position',[.05 .15 .25 .2]);
% ah2 = axes('Parent',main_gui,'Position',[.35 .15 .25 .2]);
% ah3 = axes('Parent',main_gui,'Position',[.65 .15 .25 .2]);

ah1 = axes('Parent',computation_panel,'Position',[.05 .2 .25 .5]);
ah2 = axes('Parent',computation_panel,'Position',[.35 .2 .25 .5]);
ah3 = axes('Parent',computation_panel,'Position',[.65 .2 .25 .5]);

ah4 = axes('Parent',main_gui,'Position',[.15 .7 .7 .3]);
imshow(img,'Parent',ah4);
axis(ah4,'off')
axis(ah1,'off')
axis(ah2,'off')
axis(ah3,'off')

%Make the button for vis. processing
fontSize = 0.3;
width = 0.3;
height = 0.25;
buttonsOffset = 0.25;

dy = 0.01;
dx = 0.01;
x1 = 0.01;
% y1 = 1-(dy + height) - 0*buttonsOffset;
y1 = 1-(dy + height);

par_str = 'Parent';
position = [x1 y1 width height];
callBackStr = 'vis_calc_gui';

boxStr = 'Load visual stimulus';
uicontrol ( 'parent', computation_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);


% y1 = 1- (dy + height + dy + height) - buttonsOffset;
x1 = (2*dx + width);

position = [x1 y1 width height];
callBackStr = 'neural_coding_gui;';
boxStr = 'Neural model';
uicontrol ( 'parent', computation_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);


% y1 = 1 - (dy + 2*(height+dy) + height)-buttonsOffset;
x1 = (3*dx + 2*width);

position = [x1 y1 width height];
callBackStr = 'hemodynamic_coding_gui';
boxStr = 'Hemodynamic Model';
uicontrol ( 'parent', computation_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);


% Now add buttons for visualization
y1 = 0.1;
x1 = 0.01;
fontSize = 0.3;
width_v = width;
height_v = 0.8;
position = [x1 y1 width_v height_v];
% callBackStr = 'visualization_GUI';
callBackStr = 'vis_gui';
boxStr = 'Visualization';
uicontrol ( 'parent', visualization_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);

y1 = 0.1;
x1 = (2*dx + width);
width_v = width;
height_v = 0.8;
position = [x1 y1 width_v height_v];
callBackStr = 'load_gui';
boxStr = 'Load File';
uicontrol ( 'parent', visualization_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);

y1 = 0.1;
x1 = (3*dx + 2*width);
width_v = width;
height_v = 0.8;
position = [x1 y1 width_v height_v];
boxStr = 'Save File';
callBackStr = 'save_gui';
uicontrol ( 'parent', visualization_panel, 'style', 'pushbutton', 'units', 'normalized', 'position', position, 'string', boxStr, 'fontunits', 'normalized', 'fontsize', fontSize,'CallBack',callBackStr);



set(main_gui,'visible','on');