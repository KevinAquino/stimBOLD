function [new_simobject,params_state] = params_picker(old_simobject,params_state)
    handles.figure1 = figure('name','Edit parameters','NumberTitle','off','Units','characters','MenuBar','none','Toolbar','none','Visible','off');

    handles = create_controls(handles);
    assign_callbacks(handles);
    set_colors(handles.figure1);
    
    handles.simobject_editing = old_simobject;
    sync_simobject(handles,old_simobject);
    handles = load_state(handles,params_state);
    handles = sync_to_simobject(handles);
    
    handles.input_simobject = old_simobject; % If cancel is pushed, return the original simobject so it is identical
    % But old simobject has the reduced precision required to check if any changes have been made HERE
    handles.old_simobject = handles.simobject_editing;

    
    guidata(handles.figure1,handles);
    
    minimum_size = [50 21];
    set_pos(handles.figure1,params_state,minimum_size)
    set_minimum_size(handles.figure1,minimum_size);

    % TABLE AUTO SORT. But the number order isn't correct?
    %{ 
    set(handles.advanced_table,'Visible','on');
    jscrollpane = findjobj(handles.advanced_table,'nomenu');
        jtable = jscrollpane.getViewport.getView;

    set(handles.advanced_table,'Visible','off');
 
    % Now turn the JIDE sorting on
    jtable.setSortable(true);		% or: set(jtable,'Sortable','on');
    jtable.setAutoResort(true);
    jtable.setMultiColumnSortable(true);
    jtable.setPreserveSelectionsAfterSorting(true);
    %}

    magic_textbox_make(handles.chi(2),[],'number');
    magic_textbox_make(handles.mu(2),[],'number');
    magic_textbox_make(handles.tc(2),[],'number');
    %magic_textbox_make(handles.q(2),[],'number');
    %magic_textbox_make(handles.k(2),[],'number');

    set(handles.figure1,'KeyPressFcn',@keypress_handler)

    uiwait(handles.figure1);
    
    handles = guidata(handles.figure1);
    params_state = save_state(handles);
    params_state.pos = get(handles.figure1,'Position');

    new_simobject = handles.simobject_editing;
    
    delete(handles.figure1);

function keypress_handler(src,event)
    if strcmp(event.Key,'escape')
        cancel_request(guidata(src));
    end

function handles = create_controls(handles)
        %handles.parameters_text = uicontrol(handles.figure1,'Style','text','String','Model Parameters','FontSize',10,'FontWeight','bold','HorizontalAlignment','left');
        
        handles.homeostatic_text = uicontrol(handles.figure1,'Style','text','String','Homeostatic drive','HorizontalAlignment','left','FontWeight','bold');
        
        handles.chi(1) = uicontrol(handles.figure1,'Style','text','String','Clearing time constant ','HorizontalAlignment','Right','TooltipString','Rate at which homeostatic drive decreases during sleep');
        handles.mu(1) = uicontrol(handles.figure1,'Style','text','String','Accumulation time constant ','HorizontalAlignment','Right','TooltipString','Rate at which homeostatic drive increases during wake');
        handles.chi(2) = uicontrol(handles.figure1,'Style','edit','String','1','TooltipString','Rate at which homeostatic drive decreases during sleep');
        handles.mu(2) = uicontrol(handles.figure1,'Style','edit','String','1','TooltipString','Rate at which homeostatic drive increases during wake');
        handles.chi(3) = uicontrol(handles.figure1,'Style','text','String','h','HorizontalAlignment','left','TooltipString','Rate at which homeostatic drive decreases during sleep');
        handles.mu(3) = uicontrol(handles.figure1,'Style','text','String','h','HorizontalAlignment','left','TooltipString','Rate at which homeostatic drive increases during wake');
        
        handles.circ_text = uicontrol(handles.figure1,'Style','text','String','Circadian drive','HorizontalAlignment','left','FontWeight','bold');
        handles.circ_model = uicontrol('Style', 'popup','String', 'St Hilaire|Jewett & Kronauer|Forger','Tag','circ_model','TooltipString','Select the type of circadian oscillator to use for the simulation');
       
        handles.tc(1) = uicontrol(handles.figure1,'Style','text','String','Intrinsic circadian period ','HorizontalAlignment','Right','TooltipString','Natural period of the circadian drive');
        %handles.k(1) = uicontrol(handles.figure1,'Style','text','String','Sensitivity to light (q) ','HorizontalAlignment','Right');
        %handles.q(1) = uicontrol(handles.figure1,'Style','text','String','Sensitivity to light (k) ','HorizontalAlignment','Right');
        handles.tc(2) = uicontrol(handles.figure1,'Style','edit','String','1','TooltipString','Natural period of the circadian drive');
        %handles.k(2) = uicontrol(handles.figure1,'Style','edit','String','1');
        %handles.q(2) = uicontrol(handles.figure1,'Style','edit','String','1');
        handles.tc(3) = uicontrol(handles.figure1,'Style','text','String','mV','HorizontalAlignment','left','TooltipString','Natural period of the circadian drive');
        %handles.k(3) = uicontrol(handles.figure1,'Style','text','String','mV','HorizontalAlignment','left');
        %handles.q(3) = uicontrol(handles.figure1,'Style','text','String','mV','HorizontalAlignment','left');

        handles.advanced_table = create_advanced_table(handles);
        
        handles.advanced_button =  uicontrol(handles.figure1,'Style','pushbutton','String','Advanced...');
        handles.apply_button =  uicontrol(handles.figure1,'Style','pushbutton','String','Apply');
        handles.cancel_button =  uicontrol(handles.figure1,'Style','pushbutton','String','Cancel');
        handles.default_button =  uicontrol(handles.figure1,'Style','pushbutton','String','Defaults');
        
function h = create_advanced_table(handles)
    columnname =   {'Parameter', 'Value', 'Units','Description'};
    columnformat = {'char', 'numeric', 'char','char' };
    columneditable =  [false true false false]; 

    dat =  { 'External',     0,'mV','External stimulus to MA';...
            symb('&tau;_v'),     0,'s','VLPO relaxation time';...
            symb('&tau;_m'),     0,'s','MA relaxation time';...
            symb('&mu;'),     0,'-','H accumulation time';...
            symb('&chi;')     0,'h','H clearing time';...
            symb('&tau;_c'),  0,'h','Intrinsic circadian period';...
            'q',0,'-','Light sensitivity';...
            'k',0,'-','Circadian response to light';...
            symb('D_0'),0,'mV','Base level of sleep drive';...
            symb('&nu;_vm'),     0,'mVs','Coupling from MA to VLPO';...
            symb('&nu;_mv'),     0,'mVs','Coupling from VLPO to MA';...
            symb('&nu;_vh'),     0,'mV','Coupling from H to VLPO';...
            symb('&nu;_vc'),     0,'mV','Coupling from C to VLPO';...
            symb('&beta;'),  0, symb('min^-1'),'Conversion of photoreceptors to ready';...
            symb('&mu;_c'),  0, '-','Circadian oscillator stiffness';...
            symb('VLPO_wake'),   0, 'mV','Forced wake VLPO voltage';...
            symb('MA_wake'),     0, 'mV','Forced wake MA voltage';...
            symb('VLPO_sleep'),   0, 'mV','Forced sleep VLPO voltage';...
            symb('MA_sleep'),     0, 'mV','Forced sleep MA voltage';...
            'VLPO', 0,'mV','Initial VLPO potential';...
            'MA', 0,'mV','Initial MA potential';...
            'H',     0,'-','Initial homeostatic drive';...
            symb('x_0'),     0,'-','Initial main circadian variable';...
            symb('x_c0'),     0,'-','Initial complementary circadian variable';...
            symb('n_0'),     0,'-','Initial ratio of ''ready'' light receptors';...
            };

    h = uitable(handles.figure1,'RowStriping','on','Data', dat,'ColumnName', columnname,'ColumnFormat', columnformat,'ColumnEditable', columneditable,'RowName',[],'Visible','off','FontSize',11,'ColumnWidth',{'auto','auto','auto',250});

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

function resize_fcn(handles)
        if isempty(handles) % Not sure why this function is called with empty handles when figure is opened
            return
        end
        pos = get(handles.figure1,'Position');

        total_height = pos(4);
        total_width = pos(3);        
        title_width = 30;
        name_width =  30;
        edit_width = 8;
        units_width = 5;
        element_height = 1.5;
        gap = 1;
        
        %set(handles.parameters_text,'Units','characters','Position',[ 2 total_height-2 title_width element_height]);
        set(handles.homeostatic_text,'Units','characters','Position',[ 2 total_height-2 title_width element_height]);
        set(handles.circ_text,'Units','characters','Position',[ 2 total_height-2-(element_height+gap)*3 title_width element_height]);

        master_indent = 2;
        eindent = [master_indent master_indent+name_width+1 master_indent+name_width+1+edit_width+1];
        ewidth = [name_width edit_width units_width];
        vert_offset = [0 0.25 0];
        for j = 1:3
            set(handles.chi(j),'Units','characters','Position',[ eindent(j) total_height-2-(element_height+gap)*1+vert_offset(j) ewidth(j) element_height]);
            set(handles.mu(j),'Units','characters','Position',[ eindent(j) total_height-2-(element_height+gap)*2+vert_offset(j) ewidth(j) element_height]);
            set(handles.tc(j),'Units','characters','Position',[ eindent(j) total_height-2-(element_height+gap)*5+vert_offset(j) ewidth(j) element_height]);
            %set(handles.q(j),'Units','characters','Position',[ eindent(j) total_height-2-(element_height+gap)*6+vert_offset(j) ewidth(j) element_height]);
            %set(handles.k(j),'Units','characters','Position',[ eindent(j) total_height-2-(element_height+gap)*7+vert_offset(j) ewidth(j) element_height]);
        end
        
        table_size = total_height - 5.5-5;
        set(handles.advanced_table,'Units','characters','Position',[ 2 total_height-0.5-table_size total_width-4 table_size])

        if strcmp(get(handles.advanced_button,'String'),'Simple...')
            set(handles.circ_model,'Units','characters','Position',[ 10 total_height-0.5-(element_height+gap)*1.3-table_size-0.2 title_width element_height])
            set(handles.circ_text,'Units','characters','Position',[ 2 total_height-1-(element_height)-table_size title_width element_height]);
        else
            set(handles.circ_model,'Units','characters','Position',[ 10 total_height-2-(element_height+gap)*4-0.2 title_width element_height])
            set(handles.circ_text,'Units','characters','Position',[ 2 total_height-2-(element_height+gap)*3-1 title_width element_height]);
        end

        set(handles.advanced_button,'Units','characters','Position',[ 1 3.5 21 2]);
        set(handles.apply_button,'Units','characters','Position',[ total_width-10-2 1 10 2]);
        set(handles.cancel_button,'Units','characters','Position',[1 1 10 2]);
        set(handles.default_button,'Units','characters','Position',[ 1+10+1  1 10 2]);

function advanced_button_Callback(handles)
    % This unusual block copies values between the simple and advanced menu
    % This way the two dialogs stay in sync when changes are made to one of them
    handles = sync_to_simobject(handles); % Move the current parameters into the simobject
    sync_simobject(handles,handles.simobject_editing); % Set all of the parameters (including invisible ones) to the simobject
    if strcmp(get(handles.advanced_button,'String'),'Advanced...')
        set(handles.advanced_button,'String','Simple...')
    else
        set(handles.advanced_button,'String','Advanced...')
    end
    hide_components(handles);
    
    guidata(handles.figure1,handles);

function hide_components(handles)
    %simple_fields = {handles.chi,handles.mu,handles.tc,handles.q,handles.k};
    simple_fields = {handles.chi,handles.mu,handles.tc};

    if strcmp(get(handles.advanced_button,'String'),'Simple...')
        simple_visible = 'off';
        set(handles.advanced_table,'Visible','on');
        pos = get(handles.circ_model,'Position');
        set(handles.circ_model,'Position',[pos(1) 6 pos(3) pos(4)]);
    else
        simple_visible = 'on';
        set(handles.advanced_table,'Visible','off');
        resize_fcn(handles)
    end
    
    set(handles.homeostatic_text,'Visible',simple_visible);
    %set(handles.circ_text,'Visible',simple_visible);

    for j = 1:length(simple_fields)
        for k = 1:3
            set(simple_fields{j}(k),'Visible',simple_visible);
        end
    end
    resize_fcn(handles);
    
function assign_callbacks(handles)
    set(handles.advanced_button,'Callback',@(a,b,c) advanced_button_Callback(guidata(a)));
    set(handles.advanced_table,'CellEditCallback',@(source,eventdata) advanced_table_validate(source,eventdata));
    set(handles.figure1,'CloseRequestFcn',@(a,b,c) cancel_request(guidata(a)));
    set(handles.cancel_button,'Callback',@(a,b,c) cancel_request(guidata(a)));
    set(handles.default_button,'Callback',@(a,b,c) default_button_Callback(guidata(a)));
    set(handles.apply_button,'Callback',@(a,b,c) apply_button_Callback(guidata(a)));
    set(handles.figure1,'ResizeFcn',@(a,b,c) resize_fcn(guidata(a)));
    
function advanced_table_validate(source,eventdata)
    if isempty(eventdata.NewData) || ~isfinite(eventdata.NewData)
        errordlg('Parameter values must be numerical','Input error','modal');
        d = get(source,'Data');
        d{eventdata.Indices(1),eventdata.Indices(2)} = eventdata.PreviousData;
        set(source,'Data',d);
    end

function sync_simobject(handles,s)
    % Take a simobject (e.g. defaults) , and sync it to the text fields
    % It will also get copied to handles.simobject_editing
    %handles.simobject_editing = s;
    
    set(handles.circ_model,'Value',find(strcmp(s.circ_model,{'circ_sh','circ_jk','circ_f'})));
    
    data = get(handles.advanced_table,'Data');
    values = [s.a s.tauv*s.mph s.taum*s.mph s.mu*s.mph s.chi/s.mph s.taux/s.mph s.cpars(10) s.cpars(11) s.cpars(2) s.muvm s.mumv s.muvh s.muvc s.cpars(13) s.cpars(6) s.wpars(1,1) s.wpars(1,2) s.wpars(2,1) s.wpars(2,2) s.V(1,1) s.V(1,2)  s.V(1,3) s.V(1,7) s.V(1,8) s.V(1,9)];

    for j = 1:length(values)
        data{j,2} = values(j);
    end

    set(handles.advanced_table,'Data',data);
  
    set(handles.chi(2),'String',s.chi/s.mph)
    set(handles.mu(2),'String',s.mu*s.mph)
    set(handles.tc(2),'String',s.taux/s.mph)
    %set(handles.q(2),'String',s.cpars(10))
    %set(handles.k(2),'String',s.cpars(11))
    
function handles = sync_to_simobject(handles)
    % Take the value of the text fields and sync them to
    % handles.simobject_editing
    s = handles.simobject_editing;
    
    if strcmp(get(handles.advanced_button,'String'),'Advanced...') % Sync simple fields
        s.chi = str2double(get(handles.chi(2),'String'))*s.mph;
        s.mu = str2double(get(handles.mu(2),'String'))/s.mph;
        s.taux = s.mph*str2double(get(handles.tc(2),'String'));
        %s.cpars(10) = str2double(get(handles.q(2),'String'));
        %s.cpars(11) = str2double(get(handles.k(2),'String'));
    else
        % Sync the advanced fields
        data = get(handles.advanced_table,'Data');
        values = zeros(1,size(data,1));
        for j = 1:length(values)
            values(j) = data{j,2};
        end

        s.a = values(1);
        s.tauv = values(2)/s.mph;
        s.taum = values(3)/s.mph;
        s.mu = values(4)/s.mph;
        s.chi = values(5)*s.mph;
        s.taux = values(6)*s.mph;
        s.cpars(10) = values(7);
        s.cpars(11) = values(8);
        s.cpars(2) = values(9);
        s.muvm = values(10);
        s.mumv = values(11);
        s.muvh = values(12);
        s.muvc = values(13);
        s.cpars(13) = values(14);
        s.cpars(6) = values(15);
        s.wpars(1,1) = values(16);
        s.wpars(1,2) = values(17);
        s.wpars(2,1) = values(18);
        s.wpars(2,2) = values(19);
        s.V(1,1) = values(20);
        s.V(1,2) = values(21);
        s.V(1,3) = values(22);
        s.V(1,7) = values(23);
        s.V(1,8) = values(24);
        s.V(1,9) = values(25);
    end
    
    % And update dependencies
	s.pars(1)  = 1/s.tauv;						% av (min^{-1})
	s.pars(2)  = s.muvm/(s.mph*s.tauv);				% muvm (mV)
	s.pars(3)  = s.muvc/s.tauv;					% muvc (mV min^{-1})
	s.pars(5)  = 2*pi/(s.hpde*s.mph);				% omega (units) for circadian rhythm
	s.pars(6)  = mod(s.bed*s.mph + s.phase,s.hpd*s.mph);% alpha (min), the initial circadian phase for circ = 0, or  initial light phase for circ = 1.
	s.pars(7)  = s.muvh/s.tauv;					% muvh (mV nM^{-1} min^{-1})
	s.pars(8)  = 1/s.taum;						% am (min^{-1})
	s.pars(9)  = s.mumv/(s.mph*s.taum);				% mumv (mV)
	s.pars(10) = s.a*s.pars(8);					% A*am (mV min^{-1})

    % Homeostatic parameters
    s.pars(7) = 1/s.tauv;
	s.pars(11) = s.mu/s.chi;           % m (nM) rescaled mu
	s.pars(12) = s.chi^(-1);         % ac (min^{-1})
    
    s.cpars(1)  =  s.muvc/s.tauv;                     % nu_vc/tauv 
	s.cpars(12) = (s.hpd*s.mph/(s.f*s.taux))^2; % constant in the equation for x_c
    circ_modes = {'circ_sh','circ_jk','circ_f'};
    s.circ_model = circ_modes{get(handles.circ_model,'Value')};
    
    handles.simobject_editing = s;
    
function cancel_request(handles)
    handles = sync_to_simobject(handles);
    if ~isequal_simobject(handles.simobject_editing,handles.old_simobject) && ~rquestdlg()
        return
    end
    handles.simobject_editing = handles.input_simobject;
    guidata(handles.figure1,handles);
    uiresume(handles.figure1);
    
function default_button_Callback(handles)
    sync_to_simobject(handles);
    if ~isequal_simobject(handles.simobject_editing,default_simobject()) && ~rquestdlg()
        return
    end
    sync_simobject(handles,default_simobject());
    guidata(handles.figure1,handles);
    
function apply_button_Callback(handles)
    handles = sync_to_simobject(handles);
    guidata(handles.figure1,handles);
    uiresume(handles.figure1);

function handles = load_state(handles,state)
    if isempty(state) || ~isfield(state,'advanced')
        state.advanced = 0;
    end

    if state.advanced
        set(handles.advanced_button,'String','Simple...')
    else
        set(handles.advanced_button,'String','Advanced...')
    end
    hide_components(handles);
        
function state = save_state(handles)
    if strcmp(get(handles.advanced_button,'String'),'Advanced...')
        state.advanced = 0;
    else
        state.advanced = 1;
    end
