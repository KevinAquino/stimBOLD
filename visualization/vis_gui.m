function vis_gui()
% vis_gui
%
%   Inputs:
%
%   Outputs:
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 13-Aug-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 13-Aug-2014  1st ed.
% Ver. 18-Aug-2014  Solve the following issues:
%                   speed, popupmenu, Rewind button, warnings issued at
%                   startup of this function
% Ver. 23-Aug-2014  Change the filenames for the button images to avoid
%                   conflict.
% Ver. 28-Aug-2014  Add figure check to have one GUI for visualisation
%                   only.
% Ver. 02-Sep-2014  Change slider
% Ver. 11-Sep-2014  Use linkprop to control plots, code improvement
% Ver. 13-Oct-2014  Processing in Lab color space

%
% flag_do_nothing =false;
% figHandles = findall(0,'Type','figure');
%
% if ~isempty(figHandles)
%     for mf =1:length(figHandles)
%         name_fig =get(figHandles(mf), 'Name');
%         if strcmpi(name_fig, 'Visualization - MVIBE Toolbox')
%             %             ch =get(hMainFigure, 'Children');
%             ch_handle = findobj('Tag', 'PlayStopButton');
%             figure(figHandles(mf));
%             if getappdata(ch_handle,'play') % if playing set not playing
%                 statusbar(figHandles(mf),...
%                     'You must stop before creating a new instance');
%                 flag_do_nothing =true;
%             else
%                 selection = questdlg({'Do you want to create a new instance?',...
%                     'The current one will be closed.'},...
%             'Close request function',...
%             'Yes','No','Yes');
%         switch selection,
%             case 'Yes',
%                 delete(figHandles(mf))
%             case 'No'
%                flag_do_nothing =true;
%         end
%
%
%                 %             if ishghandle(figHandles(mf))
%                 %                 figure(figHandles(mf))
%                 %                 close(figHandles(mf))
%             end
%         end
%     end
% end


% if ~flag_do_nothing
% Initialise values

zeta = evalin('base','zeta');
BOLD = evalin('base','BOLD');
% BOLDTP = evalin('base','BOLDTP');
params = evalin('base','params');
visual_response =evalin('base','visual_response');

msh =evalin('base','msh');

tmp1 =0;
tmp2 =0;
tmp3 =0;
nn = 1;
ind = 1;
meanZ = mean(zeta,2);
maxZ = max(meanZ);
meanB = mean(BOLD,2);
maxB = max(meanB);
minB = min(meanB);
maxBV = max(BOLD(:));
tall = cell2mat(params.time_indices);
fnV = struct;
bV = struct;

% Parameters to start it all off.
fnV.skipInitialization = 0;
bV.skipInitialization = 0;

% Add the bottom panel
% set up the figure

mPlotTypes ={...      % Example plot types shown by this GUI
    'original';
    'inflated';
    'sphere';
    'flat';};
mplotValue ='original';

im_play =imread('play_mvibe.jpg');
im_stop =imread('stop_mvibe.jpg');
im_forward =imread('forward_mvibe.jpg');
im_backward =imread('backward_mvibe.jpg');
im_rewind =imread('rewind_mvibe.jpg');


% Create the figure
hMainFigure = figure(...       % The main GUI figure
    'MenuBar','figure', ...
    'Toolbar','figure', ...
    'HandleVisibility','callback', ...
    'Color', 'White',...
    'Name', 'Visualization - M-ViBe',...
    'NumberTitle', 'off',...
    'CloseRequestFcn',@hMainFigureClosefun,...
    'Tag', 'MainFigure',...
    'Units', 'normalized',...
    'Renderer', 'OpenGL');

hPlotAxes  = axes(...         % the axes for plotting selected plot
    'Parent', hMainFigure, ...
    'Units', 'normalized', ...
    'HandleVisibility','callback', ...
    'Visible', 'off',...
    'Position',[0 0.1 1 0.9],...
    'FontUnits', 'normalized',...
    'Tag', 'PlotAxes');

hPlotsPopupmenu = uicontrol(... % List of available types of plot
    'Parent', hMainFigure, ...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.01 0 0.13 0.1],...
    'HandleVisibility','callback', ...
    'String',mPlotTypes(:,1),...
    'Style','popupmenu',...
    'Callback', @hPlotsPopupmenuCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'PlotsPopupmenu');

hPlayStopButton = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Style', 'togglebutton',...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.17 0.05 0.07 0.05],...
    'CData', im_play,...
    'Callback', @hPlayStopButtonCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'PlayStopButton');

hRewindButton = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.26 0.05 0.07 0.05],...
    'CData', im_rewind,...
    'Callback', @hRewindButtonCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'RewindButton');

hBackwardButton = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.35 0.05 0.07 0.05],...
    'CData', im_backward,...
    'Callback', @hBackwardButtonCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'BackwardButton');

hForwardButton = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.44 0.05 0.07 0.05],...
    'CData', im_forward,...
    'Callback', @hForwardButtonCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'ForwardButton');

hSpeedslider = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Style','slider',...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Min',1,'Max',20,'Value',5, 'SliderStep', [1, 2]/19,...
    'Position',[0.54 0.05 0.2 0.05],...
    'Callback', @hSpeedsliderCallback,...
    'FontUnits', 'normalized',...
    'Tag', 'Speedslider');

hSpeedText = uicontrol(... % Button for updating selected plot
    'Parent', hMainFigure, ...
    'Style','text',...
    'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.76 0.05 0.03 0.05],...
    'TooltipString', 'Speed',...
    'HorizontalAlignment', 'Center',...
    'FontUnits', 'normalized',...
    'Tag', 'SpeedText'); %        'Callback', @hSpeedTextCallback,...

% hExportButton = uicontrol(... % Button for updating selected plot
%     'Parent', hMainFigure, ...
%     'Units','normalized',...
%     'HandleVisibility','callback', ...
%     'Position',[0.92 0.05 0.07 0.05],...
%     'String', 'Export',...
%     'Callback', @hExportButtonCallback,...
%     'FontUnits', 'normalized',...
%     'Tag', 'ExportButton');


setappdata(hPlayStopButton,'play', false);
%     setappdata(hPlayStopButton,'speed_m', 2);
setappdata(hPlayStopButton,'speed_step', 5);
set(hSpeedText,'string', '5');
setappdata(hPlayStopButton,'ind_start', 1);

nn =1;

% handle initialise
h_stimuli =subplot(5,5,[1, 2, 6, 7],'Parent',hMainFigure, 'Visible','off',...
    'FontUnits', 'normalized');
h_response1 =subplot(5,5,[16 17],'Parent',hMainFigure, 'Visible','off');
h_response2 =subplot(5,5,[11 12],'Parent',hMainFigure, 'Visible','off');

h_neural = subplot('Position', [0.418, 0.64, 0.572, 0.35],...
    'Parent',hMainFigure, 'Visible','off', 'FontUnits', 'normalized');

h_bold = subplot('Position', [0.418, 0.1+0.9/5, 0.99-0.418, 0.1+0.9*2/5-0.1],...
    'Parent',hMainFigure, 'Visible','off', 'FontUnits', 'normalized');

cell_prop ={'CameraPosition','CameraUpVector', 'CameraTarget', 'CameraViewAngle'};
% cell_prop =cell_prop(1:2);
hlink = linkprop([h_neural, h_bold],cell_prop);

statusbar(hMainFigure,'Initialising...');
cform =makecform('lab2srgb');
num_vr =length(visual_response);
for m_cell =1:num_vr
    statusbar(hMainFigure,'Initialising, be patient, %3.2f%%', m_cell/num_vr*100);
    visual_response{m_cell} =applycform(visual_response{m_cell}, cform);
end



% First initialization, i.e. loading the surface
localUpdatePlot();
fnV.skipInitialization = 1;
bV.skipInitialization = 1;

statusbar(hMainFigure,'Ready');
% for extension
% [def_az_neural,def_el_neural] = view(h_neural);
% [def_az_bold,def_el_bold] = view(h_bold);


% end

    function hPlotsPopupmenuCallback(hObject, eventdata, handles)
        
        if getappdata(hPlayStopButton,'play')
            hPlayStopButtonCallback(hPlayStopButton)
            statusbar(hMainFigure,'Change option when stop playing');
            m_reset = cellfun(@(x,y) strcmpi(x, mplotValue), mPlotTypes, ...
                'UniformOutput', false);
            m_reset =cell2mat(m_reset);
            tmp =1:4;
            set(hObject, 'Value', tmp(m_reset));
        else
            
            m_popmenu =get(hObject, 'Value');
            if m_popmenu~=4 && (~strcmpi(mplotValue, mPlotTypes{m_popmenu}))
                statusbar(hMainFigure,'Calculating...')
                mplotValue =mPlotTypes{m_popmenu};
                fnV.skipInitialization = 0;
                bV.skipInitialization = 0;
                localUpdatePlot();
                fnV.skipInitialization = 1;
                bV.skipInitialization = 1;
                statusbar(hMainFigure,'Done');
            elseif m_popmenu==4
                statusbar(hMainFigure,'Flat is not supported yet');
            end
        end
    end


    function hPlayStopButtonCallback(hObject, eventdata, handles)
        if getappdata(hObject,'play') % if playing set not playing
            setappdata(hObject,'play', false);
        else
            setappdata(hObject,'play', true);
        end
        
        
        if getappdata(hObject,'play') % if it is not playing
            set(hObject, 'CData', im_stop)
            speed_step =getappdata(hObject,'speed_step');
            %             speed_step =speed_vect(speed_m);
            statusbar(hMainFigure,['Playing, speed ' num2str(speed_step)])
            
            ind_start =getappdata(hPlayStopButton,'ind_start');
            
            for m=ind_start:speed_step:length(params.t)
                %                 if getappdata(hObject,'terminate')
                %                     setappdata(hObject,'terminateact', true);
                %                     break;
                %                 end
                if ~getappdata(hObject,'play')||...
                        ~isequal(speed_step, getappdata(hObject,'speed_step'))
                    setappdata(hObject,'ind_start', m);
                    break;
                end
                
                if ~isequal(ind_start, getappdata(hObject,'ind_start'))
                    break;
                end
                nn =m;
                localUpdatePlot();
                %                 setappdata(hObject,'ind_start', m);
                %                 ind_start =m;
            end
        else
            %            getappdata(hObject,'play')
            set(hObject, 'CData', im_play)
            statusbar(hMainFigure,'Stop')
            %            setappdata(hObject,'play', false);
            %          play_break =true;
        end
    end

    function hRewindButtonCallback(hObject, eventdata, handles)
        % This button will stop current playing activity
        %         setappdata(hPlayStopButton,'play', false);
        %         set(hPlayStopButton, 'CData', im_play)
        if getappdata(hPlayStopButton,'play')
            hPlayStopButtonCallback(hPlayStopButton);
            statusbar(hMainFigure,'Click again when stop playing');
        else
            nn =1;
            setappdata(hPlayStopButton,'ind_start', 1);
            localUpdatePlot();
        end
    end


    function hBackwardButtonCallback(hObject, eventdata, handles)
        %         speed_m1b =getappdata(hPlayStopButton,'speed_m');
        %         speed_m2b =speed_m1b -1;
        %         if speed_m2b>=1
        %             setappdata(hPlayStopButton,'speed_m', speed_m2b);
        %             setappdata(hPlayStopButton,'speed_step', speed_vect(speed_m2b));
        %             set(hSpeedslider, 'Value', speed_vect(speed_m2b));
        %             statusbar(hMainFigure,...
        %                 ['Speed is changed to ' num2str(speed_vect(speed_m2b))]);
        %         else
        %             statusbar(hMainFigure,...
        %                 'Speed is already 1');
        %         end
        speed_step =getappdata(hPlayStopButton,'speed_step');
        %         ind_start =getappdata(hPlayStopButton,'ind_start');
        ind_start =max([1, nn-speed_step*2]);
        setappdata(hPlayStopButton,'ind_start', ind_start);
        localspeedupdate();
        
    end

    function hForwardButtonCallback(hObject, eventdata, handles)
        %         speed_m1f =getappdata(hPlayStopButton,'speed_m');
        %         speed_m2f =speed_m1f +1;
        %         if speed_m2f<=6
        %             setappdata(hPlayStopButton,'speed_m', speed_m2f);
        %             setappdata(hPlayStopButton,'speed_step', speed_vect(speed_m2f));
        %             set(hSpeedslider, 'Value', speed_vect(speed_m2f));
        %             statusbar(hMainFigure,...
        %                 ['Speed is changed to ' num2str(speed_vect(speed_m2f))]);
        %         else
        %             statusbar(hMainFigure,...
        %                 'Speed is already 50');
        %         end
        
        speed_step =getappdata(hPlayStopButton,'speed_step');
        %         ind_start =getappdata(hPlayStopButton,'ind_start');
        ind_start =min([length(params.t), nn+speed_step*2]);
        setappdata(hPlayStopButton,'ind_start', ind_start);
        localspeedupdate();
        
    end

    function hSpeedsliderCallback(hObject, eventdata, handles)
        speed_step_slide =floor(get(hObject, 'Value'));
        
        %         [tmp, slider_m] =min(abs(speed_step_slide-speed_vect));
        %         setappdata(hPlayStopButton,'speed_m', slider_m);
        setappdata(hPlayStopButton,'speed_step', speed_step_slide);
        statusbar(hMainFigure,...
            ['Speed is changed to ' num2str(speed_step_slide)]);
        
        set(hSpeedText,'string', {num2str(speed_step_slide)});
        %      sb = statusbar('text');
        %       set(sb.CornerGrip, 'visible','off');
        %      sb.CornerGrip.setVisible(false);
        %      set(sb.TextPanel, 'Foreground',[1,0,0], 'Background','cyan', 'ToolTipText','Speed step...')
        %      set(sb, 'Background',java.awt.Color.cyan);
        
        localspeedupdate();
    end

    function hMainFigureClosefun(hObject, eventdata, handles)
        % User-defined close request function
        % to display a question dialog box
        
        if getappdata(hPlayStopButton,'play') % if playing set not playing
            statusbar(hMainFigure,...
                'Prepare closing...');
            setappdata(hPlayStopButton,'play', false);
            drawnow
            statusbar(hMainFigure,...
                'Preparation for closing done.');
            %             drawnow
            %             closeconfirm
        else
            closeconfirm
        end
    end

    function closeconfirm
        selection = questdlg('Close this figure?',...
            'Close request function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(gcf)
            case 'No'
                return
        end
    end
%----------------------------------------------------------------------
    function localUpdatePlot
        % Helper function for ploting the selected plot type
        %         axes(hPlotAxes);
        if getappdata(hPlayStopButton,'terminate');
            return;
        end
        
        
        zetaTP = zeta(nn,:);
        BOLDTP = BOLD(nn,:);
        tp = params.t(nn);
        
        %         hsub =subplot(5,5,[2,7], 'Parent',hMainFigure);
        %         % textH = text(0.1,0.5,['t = ' num2str(params.t(1)) 's'],'fontSize',12);
        %         textH = text(0.1,0.5,['t = ' num2str(params.t(1)) 's'], 'Parent',hsub);
        %         axis(hsub, 'off');
        
        
        %         h1 =subplot('Position', [0.01, 0.1+0.9*3/5, 0.4, 0.99-0.1-0.9*3/5],...
        %             'Parent',hMainFigure);
        
        tall = cell2mat(params.time_indices);
        
        ind = find(tp>tall, 1, 'last' );
        if(isempty(ind))
            ind = 1;
        end;
        
        img = visual_response{ind};
        imshow(img, 'Parent',h_stimuli);
        
        title(h_stimuli, ['t = ' num2str(tp) 's'], 'FontUnits', 'normalized', 'FontSize',0.125); %, 'FontSize',12
        %         set(textH,'String',['t = ' num2str(tp) 's']);
        
        
        %         ax = subplot(5,5,[3:5,8 9 10],'Parent',hMainFigure);
        
        %         ax = fig;
        %
        %         ax_pos =set(ax, 'Position');
        
        
        fnV.figNo = hMainFigure;
        % fnV.figView = [60 10];
        fnV.figParentAxis = h_neural;
        
        [msh,fnV] = display_sim_movie_matlab(squeeze(zetaTP),msh,[0 1],1,0,mplotValue,fnV);
        
        
        
        %         h2 =subplot('Position', [0.01, 0.1+0.9*2/5, 0.4, 0.99-0.1-0.9*4/5],...
        %         'Parent',hMainFigure);
        
        plot(params.t,meanZ, 'Parent',h_response2);
        line([tp tp],[0 maxZ],'Color','red','lineWidth',3, 'Parent',h_response2);
        xlim(h_response2, [params.t(1) params.t(end)]);
        ylim(h_response2, [0 maxZ*1.1]);
        %         ylabel('Neural','fontSize',18);
        ylabel(h_response2, 'Neural','FontUnits', 'normalized', 'FontSize',0.25);
        xlabel(h_response2, []);
        set(h_response2, 'XTickLabel', [])
        %         set(gca,'fontSize',20);
        
        
        
        %         h3 =subplot('Position', [0.01, 0.1+0.9*1/5, 0.4, 0.99-0.1-0.9*4/5],...
        %         'Parent',hMainFigure);
        plot(params.t,meanB, 'Parent',h_response1);
        line([tp tp],[0 maxZ],'Color','red','lineWidth',3, 'Parent',h_response1);
        xlim(h_response1, [params.t(1) params.t(end)]);
        ylim(h_response1, [minB*1.1 maxB*1.1]);
        %         xlabel('time (s)','fontSize',18);
        %         ylabel('BOLD','fontSize',18);
        %         set(gca,'fontSize',20);
        xlabel(h_response1, 'time (s)', 'FontUnits', 'normalized', 'FontSize',0.25);
        ylabel(h_response1, 'BOLD', 'FontUnits', 'normalized', 'FontSize',0.25);
        
        %         ax2 = subplot(5,5,[13:15,18:20],'Parent',hMainFigure);
        
        %         ax2 = fig;
        
        bV.figNo = hMainFigure;
        % bV.figView = [60 10];
        bV.figParentAxis = h_bold;
        
        [msh,bV] = display_sim_movie_matlab(BOLDTP,msh,[1.1*minB, 1.1*maxBV],1,0,mplotValue,bV);
        
        drawnow
    end

    function localspeedupdate
        if getappdata(hPlayStopButton,'terminate');
            return;
        end
        if getappdata(hPlayStopButton,'play') % if it is not playing
            speed_step =getappdata(hPlayStopButton,'speed_step');
            statusbar(hMainFigure,['Playing, speed ' num2str(speed_step)]);
            ind_start =getappdata(hPlayStopButton, 'ind_start');
            for m=ind_start:speed_step:length(params.t)
                if ~getappdata(hPlayStopButton,'play')||...
                        ~isequal(speed_step, getappdata(hPlayStopButton,'speed_step'))
                    setappdata(hPlayStopButton,'ind_start', m);
                    break;
                end
                
                if ~isequal(ind_start, getappdata(hPlayStopButton,'ind_start'))
                    break;
                end
                
                nn =m;
                localUpdatePlot();
                %                 ind_start =m;
            end
            
        else
            if nn~=getappdata(hPlayStopButton, 'ind_start')
                nn =getappdata(hPlayStopButton, 'ind_start');
                localUpdatePlot();
            end
            %              ind_start =m;
        end
    end

end