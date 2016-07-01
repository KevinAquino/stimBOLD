% VFBToolBox.m
%
% Visual Field to Bold Toolbox.
% ==========================================================================
% This code calculates the BOLD response in visual cortex due to stimuli
% presneted in the visual field.
%
% Kevin Aquino.
% Mark M. Schira.
% Thomas Lacy.
% Peter Robinson.
% Michael Breakspear.
% April 2014.
%
% Ver 11-Aug-2014  Solve the issue when nothing is returned from GUI
%                  Change the code to convert images to uint8 values
% Modified by Wenbin
% Ver. 13-Oct-2014  Processing in Lab color space
% Ver. 24-Nov-2014  Minor description change.
% Ver. 28-Nov-2014  Changed the behaviour of this.

function vis_calc_gui(hObject,~)

gui_data = guidata(get(hObject,'parent'));
params = gui_data.stimBOLD_output.params;
params.useGUI = true;

set(gui_data.handles.simulationButton,'enable','off');
set(gui_data.handles.visStimButton,'enable','off');



% ======== Specify and load in the visual stimulus:
statusbar(gui_data.handles.main_gui,'Calculating Visual Inputs...')

out_GUI =load_stimuli_GUI({params.freesurferpath},gui_data);
if out_GUI.stage_li~=0    
    params.visualStimulus ='GUI';        
    % Now store the images.                
    params.time_cell = out_GUI.time_cell;
    
    % This update should be done when loading parameters in the GUI
    params.t_end =  params.time_cell{end} + params.time_afterStim;
    params.t_start = params.time_cell{1};
    params.t = params.t_start:params.dt:params.t_end;
    params.MAX_SCREEN_EC = out_GUI.para_list_value{4};
    params.step = out_GUI.para_list_value{3};
    
    gui_data.stimBOLD_output.params = params;
    gui_data.stimBOLD_output.visual_stimulus = out_GUI.img_cell;
    guidata(hObject,gui_data);
    
    set(gui_data.handles.simulationButton,'enable','on');
    
    statusbar(gui_data.handles.main_gui,'Visual stimulus has been loaded.')

    
else
    % If there are still visual responses there, make sure that you can
    % still run the simulation, i.e. in the case that you accidently opened
    % this gui.
    
    if(isfield(gui_data,'visual_response'))
        if(~isempty(gui_data.visual_response))
                set(gui_data.handles.simulationButton,'enable','on');
        end
    end    
    
    statusbar(gui_data.handles.main_gui,'Loading Stimulus cancelled.')
end


set(gui_data.handles.visStimButton,'enable','on');
end
