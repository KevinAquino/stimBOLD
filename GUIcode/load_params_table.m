% load_params_table.m
% This function load the parameters into table that can be edited.
% Kevin Aquino 2015
%
% Most of this code was stripped from Romesh Abeysuriya's code that did the
% same thing (thanks Romesh!).
%
function load_params_table(main_gui)

if(nargin < 1)
    main_gui = [];
    params = loadParameters();
else
    gui_data = guidata(main_gui);
    params = gui_data.stimBOLD_output.params;
end

% create the figure
position = [60 25 80 60];
param_handles.main_fig = figure('Units','Character','OuterPosition',...
    position,'windowstyle', 'normal', 'resize', 'off','visible','on',...
    'menubar','none','Toolbar','none','numbertitle','off', ...
    'name','Model and simulation parameters.');

% Create the menus
% param_handles.file_menu = uimenu(param_handles.main_fig,'label','File');
% param_handles.load_label = uimenu(param_handles.file_menu,'label','Load');
% param_handles.save_label = uimenu(param_handles.file_menu,'label','Save');

% intialize the position vector.
position_phys_pos = [1 position(4)/4 position(3)-2 position(4)*3/4-4];

% intializing the table
param_handles.phys_panel = uipanel(param_handles.main_fig,'units', ...
    'Character','Position',position_phys_pos,'title','Physiological Parameters');

columnname =   {'Parameter', 'Value', 'Units','Description'};
columnformat = {'char', 'numeric', 'char','char' };
columneditable =  [false true false false];

dat =  { symb('hemo_model'),0,'-','Hemodynamic model'};
param_handles.phys_table = uitable(param_handles.phys_panel,'RowStriping', ...
    'on','Data', dat,'ColumnName', columnname,'ColumnFormat', ...
    columnformat,'ColumnEditable', columneditable,'RowName',[], ...
    'Visible','on','FontSize',11,'ColumnWidth',{'auto','auto','auto',200});

set(param_handles.phys_table,'Units','Character','Position',[1 1 75 38]);


% create the struct array from params
params_array = create_params_array(params,param_handles.main_fig);



dat = squeeze(struct2cell(params_array));

% The way to make it is to do cell2mat then reverse that on the output!

set(param_handles.phys_table,'dat',dat);

data = guidata(param_handles.main_fig);

data.phys_table = param_handles.phys_table;
data.main_gui = main_gui;
data.main_fig = param_handles.main_fig;

guidata(param_handles.main_fig,data);

% create the button to go set values to
param_handles.returnButton = makeButton(param_handles.main_fig,[30 6 25 3],'Set Parameters',@returnButtonParams);

drawnow;
end

% Symbol function that gets the right symbol when you type in the
% description of the symbol.
function str = symb(str)
modifier = 0;
if strfind(str,'^')
    modifier = 1;
    modstr = 'sup';
    [str,str2] = strtok(str,'^');
elseif strfind(str,'_')
    modifier = 1;
    modstr = 'sub';
    [str,str2] = strtok(str,'_');
end

if modifier
    str = sprintf('<html>%s<%s>%s</%s></html>',str,modstr,str2(2:end),modstr);
else
    str = sprintf('<html>%s</html>',str);
end

end

function params_array = create_params_array(params,parent)
% now go through each of the parameters and put them in a structure array.

params_array = struct;
non_table_data = struct;

fnames = fieldnames(params);
for j=1:length(fnames)
    
    if(numel(getfield(params,fnames{j}))>1)
        non_table_data = setfield(non_table_data,fnames{j},getfield(params,fnames{j}));
    else
        
        % setting up variables in the struct array ready for the table.
        params_array = setfield(params_array,{1},fnames{j},fnames{j});
        params_array = setfield(params_array,{2},fnames{j},getfield(params,fnames{j}));
        
        [units,description] = function_parameter_details(fnames{j});
        
        params_array = setfield(params_array,{3},fnames{j},units);
        params_array = setfield(params_array,{4},fnames{j},description);
    end
end

data.non_table_data = non_table_data;
guidata(parent,data);

end

function buttonHandle = makeButton(parentPanel,position,boxStr,callBackStr)
fontSize = 14;
buttonHandle = uicontrol ( 'parent', parentPanel, 'style', 'pushbutton', ...
    'units', 'character', 'position', position, 'string', boxStr, ...
    'fontsize', fontSize,'CallBack',callBackStr);
end

function resize_table(hObject,~)
% do nothing at the moment, but will add the feature in a future release.
end

function returnButtonParams(hObject,~)
data = guidata(hObject);
dat = get(data.phys_table,'dat');

% First instance take all the parameters from the table
params = cell2struct(dat(:,2),dat(:,1));

% Second instance take all the parameters that are vectors/cells and place
% them back in parameters (if there are any)
if(~isempty(data.non_table_data))
    fnames = fieldnames(data.non_table_data);
    for j=1:length(fnames)
        params = setfield(params,fnames{j},getfield(data.non_table_data,fnames{j}));
    end
end


if(~isempty(data.main_gui))
    gui_data = guidata(data.main_gui);
    gui_data.stimBOLD_output.params = params;
    guidata(data.main_gui,gui_data);
end

close(data.main_fig);
end

% Here we have a function that sets parameter details for the parameter
% table, its a neat implementation. To add any other parameters, please add
% it here.
%

function [units,description] = function_parameter_details(fname)
switch fname
    case 'z_n'
        units = '-';
        description = 'Neural normalization';
    case 't_0'
        units = 's';
        description = 'Stimulation starting time';
    case 'hemo_model'
        units = '-';
        description = 'Hemodynamic model: 1 = spatiotemporal model';
    case 'v_b'
        units = symb('mm s^-1');
        description = 'Hemodynamic wave velocity (in spatiotemporal model)';
    case 'Gamma'
        units = symb('s^-1');
        description = 'Damping rate';
    case 'eta'
        units = symb('s^-1');
        description = 'Oxygenated consumption rate';
    case 'tau'
        units = 's';
        description = 'Hemodynamic transit time';
    case 'beta'
        units = '-';
        description = 'Hemodymamic elasticity exponent';               
    case 'k1'
        units = '-';
        description = 'BOLD model constant (k1), Obata et al. 2006 model';
    case 'k2'
        units = '-';
        description = 'BOLD model constant (k2), Obata et al. 2006 model';
    case 'k3'
        units = '-';
        description = 'BOLD model constant (k3), Obata et al. 2006 model';
    case 'gam'
        units = symb('s^-1');
        description = 'Flow rate elimination constant';
    case 'kappa'
        units = symb('s^-1');
        description = 'Flow rate of decay constant';
    case 'rho_f'
        units = symb('kg m ^-3');
        description = 'Blood mass density';
    case 'V_0'
        units = '-';
        description = 'Resting proportion of blood in tissue';
    case 'Xi_0'
        units = symb('kg m^-3');
        description = 'Resting mass density contributed by blood';
    case 'F_0'
        units = symb('s^-1');
        description = 'Resting blood flow';
    case 'L'
        units = 'mm';
        description = 'Cortical depth';
    case 'k0'
        units = symb('m^-1');
        description = 'Perpendicular spatial frequency';
    case 'Cz'
        units = symb('s^-1');
        description = 'Outflow normalization constant';
    case 'D'
        units = symb('s^-1');
        description = 'Effective blood viscosity coefficient';
    case 'k_z'
        units = symb('m^-1');
        description = 'Effective Spatial frequency';
    case 'flowNoise'
        units = '-';
        description = 'Flow noise flag: 1 turns of flow noise, 2 turns off flow noise';
    case 't_start'
        units = 's';
        description = 'Start of the simulation';
    case 't_end'
        units = 's';
        description = 'End of the simulation';
    case 'num_time'
        units = '-';
        description = 'Number of time points in the simulation';
    case 'plotting'
        units = '-';
        description = 'Plotting flag: 1 turns on plotting';
    case 'dt'
        units = 's';
        description = 'Time step';
    case 'time_afterStim'
        units = 's';
        description = 'Time after the stimulation, a good value would be over 20 to account for the relaxation';
    case 'MAX_SCREEN_EC'
        units = 'deg';
        description = 'Max of the screen eccentricity';
    otherwise
        units = '-';
        description = '-';
end
end






