function varargout = load_stimuli_GUI(varargin)
% LOAD_STIMULI_GUI MATLAB code for load_stimuli_GUI.fig
%      LOAD_STIMULI_GUI, by itself, creates a new LOAD_STIMULI_GUI or raises the existing
%      singleton*.
%
%      H = LOAD_STIMULI_GUI returns the handle to a new LOAD_STIMULI_GUI or the handle to
%      the existing singleton*.
%
%      LOAD_STIMULI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_STIMULI_GUI.M with the given input arguments.
%
%      LOAD_STIMULI_GUI('Property','Value',...) creates a new LOAD_STIMULI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before load_stimuli_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to load_stimuli_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% NOTES
% SHAO Wenbin, 05-Mar-2014
% UOW, email: wenbin@ymail.com
% Ver. 15-Apr-2014 Start recording major changes
%                  Add two folders into path
%                  Input part modification, disable automatic processing
% Ver. 29-Apr-2014 rename the GUI; add code to wait for UI; change code to cope
%                  with stage processing, see OpeningFcn; remove mask generation
%                  code.
% Ver. 08-May-2014 Parameters loading and editing are changed and improved
%                  to cope with externel processing.
% Ver. 20-May-2014 Bug spray.
% Ver. 22-May-2014 Returnt correct information to the calling function
% Ver. 10-Jun-2014 The following finished: delete cortical project button,
%                  add save button.
% Ver. 09-Jul-2014 Now GUI accepts an input
% Ver. 11-Jul-2014 Changed naming of neuralActivity_cell to neuralActivity
%                  KMA
% Ver. 11-Aug-2014 Clean the code after nerual processing was removed.
%                  Modify the code for rentina processing.
% Ver. 02-Sep-2014 Remove folder option since it uses the same GUI as 
% Ver. 17-Sep-2014 Prevent accidental clicks.
% Ver. 11-Oct-2014 Process images in L*a*b space instead of RGB space.
% Ver. 18-Nov-2014 Cleaning up completely, removing guts of retinal
%                  processing into a separate function. also taking in
%                  arguments with no GUI properly to load in for the batch
%                  processing. 
% Ver. 06-Nov-2014 Minor text change.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @load_stimuli_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @load_stimuli_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT


% --- Executes just before load_stimuli_GUI is made visible.
function load_stimuli_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to load_stimuli_GUI (see VARARGIN)

% Choose default command line output for load_stimuli_GUI
handles.output = hObject;

% Update handles structure
% guidata(hObject, handles);


% set(handles.ls_show_stimuli,'Title',text('String','Preview'))
set(handles.ls_show_stimuli,'Visible','off');
% set(get(handles.input_im_sel_imshow,'Title'),'Visible','on');

% set(handles.ls_show_mask,'Title',text('String','Preview'))
set(handles.ls_show_mask,'Visible','off');

% initilise the flag for automatic mask generation.
handles.maskgen_flag =0;

% initilise the flag for processing stages
handles.stage_li =0; % load images:
handles.stage_rp =0; % retinal processing
handles.stage_cp =0; % cortical projection
% handles.stage_nr =0; % neural response
handles.stage_pm =0; % parameters

% initilise
% handles.para_list_field =[];
% handles.para_list_value =[];



% No need to add path, since this part code
% add function and data folders to path
p_filename = mfilename('fullpath');
[pathstr, name, ext]= fileparts(p_filename);
% p_data =fullfile(pathstr, 'data');
% p_function =fullfile(pathstr, 'function');
% addpath(p_data, p_function); 


handles.para_list_field ={'degree', 'step', 'MAX_SCREEN_EC',...
'rgb2lab', 'lab2rgb'};
handles.para_list_value ={str2double(get(handles.ls_para_mexec_val,'string')),...% handles.ls_para_vd_val, for compatibility, this parameter will be kept.
    str2double(get(handles.ls_para_pstep_val,'string')),...
    str2double(get(handles.ls_para_mexec_val,'string')),...
    makecform('srgb2lab'), makecform('lab2srgb')};

handles.cform.lab2rgb =makecform('lab2srgb');
handles.cform.rgb2lab =makecform('srgb2lab');

% handles.path_data =p_data;
handles.path_data = [pwd '/GUIcode/data/'];
% handles.path_function =p_function;

% If there are images loaded, then put them in here!
if(~isempty(varargin{2}))
    gdata = varargin{2};
    
    % Set the parameter values here for max screen eccentricity that are
    % defined in the parameters
    handles.para_list_value{1} = gdata.stimBOLD_output.params.MAX_SCREEN_EC;
    handles.para_list_value{3} = gdata.stimBOLD_output.params.MAX_SCREEN_EC;
    guidata(hObject, handles);
    
    if(isfield(gdata.stimBOLD_output,'visual_stimulus'))
        img_cell = gdata.stimBOLD_output.visual_stimulus;                
        load_images_to_display(hObject,img_cell,gdata.stimBOLD_output.params.time_cell,handles);
        handles = guidata(hObject);
        handles.stage_li =1;
        guidata(hObject, handles);
        ls_retinal_processing_Callback(hObject);
        
    end
else
    guidata(hObject, handles);
end


% Set the parameters that are specified, initialize them here:
set(handles.ls_para_mexec_val,'String',handles.para_list_value{1});



% UIWAIT makes load_stimuli_GUI wait for user response (see UIRESUME)
uiwait(handles.load_stimuli_figure);
end

% --- Outputs from this function are returned to the command line.
function varargout = load_stimuli_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
% The figure can be deleted now
delete(handles.load_stimuli_figure);
end

% --- Executes when user attempts to close load_stimuli_figure.
function load_stimuli_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to load_stimuli_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
end


% --- Executes on selection change in ls_input.
function ls_input_Callback(hObject, eventdata, handles)
% hObject    handle to ls_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ls_input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ls_input
val = get(hObject,'Value');
set(handles.ls_retinal_processing,'Enable','off')
switch val
    case 1 % movie
        set(handles.ls_im_sel_tip, 'String','Processing...');
        [filename, pathname] = ...
            uigetfile({'*.avi;*.mov;*.mpg';'*.*'},'File Selector');
        if filename ==0
            img_cell{1} =imread(fullfile(handles.path_data, 'NoImage.png'));
            time_cell{1} =0;
            
        else
            data_in = VideoReader(fullfile(pathname, filename));
            
            nFrames = data_in.NumberOfFrames;
            rateFrames = data_in.FrameRate;
            
            time_cell =(0:nFrames-1)/rateFrames;
            
            time_cell =mat2cell_vs(time_cell);
            
            img_cell =cell(1, nFrames);

            % Read one frame at a time.
            for k = 1 : nFrames
                img_cell{k} = read(data_in, k);
            end
            
            handles.stage_li =1;
        end
        
    case 2 % image, manual
        set(handles.ls_im_sel_tip, 'String','Processing...');
        image_select_data =input_image_select_GUI; % image select gui outputs all necessary data
        
        if ~isfield(image_select_data, 'data_in')
            img_cell{1} =imread(fullfile(handles.path_data, 'NoImage.png'));
            time_cell{1} =0;
        else
            if  isempty(image_select_data.data_in)
                img_cell{1} =imread(fullfile(handles.path_data, 'NoImage.png'));
                time_cell{1} =0;
            else
                img_cell =image_select_data.data_in;
                time_cell =image_select_data.time_in;
                handles.stage_li =1;
            end
        end

    case 3 % text file
        
        set(handles.ls_im_sel_tip, 'String','Processing...');
        [filename,pathname] = uigetfile('*.txt','Select the text file');
        if ~ischar(filename)
     
            img_cell{1} =imread(fullfile(handles.path_data, 'NoImage.png'));
            time_cell{1} =0;
        else
            handles.text_filename =[pathname filesep filename];
            
            fid =fopen(handles.text_filename);
            text_log = textscan(fid, '%s%[^\r\n]', 'Delimiter', '|'); % text_log{2} should be empty
            fclose(fid);
            text_log =text_log{1};
            
            time_cell =num2cell(str2num(text_log{1}));
            
            num_im =length(text_log) -1;
            img_cell =cell(1, num_im);
          
            
            for k =2:length(text_log)
                img_cell{k-1} =imread(text_log{k});
            end
            handles.stage_li =1;
        end                
        
end

% 
% % get number of images
% num_im =length(img_cell); % for test purpose
% handles.num_im =num_im;
% 
% handles.img_cell =img_cell;
% % generate input for further processing
% mask_cell{1} =imread(fullfile(handles.path_data, 'NoMask.png'));
% mask_cell{1} =im_labrgb_convert(mask_cell{1}, handles.cform.rgb2lab);
% % mask_cell will be in Lab color space
% handles.mask_cell =repmat(mask_cell, 1, length(img_cell));
% handles.time_cell =time_cell;
% guidata(hObject, handles);
% 
% 
% % set up the slide
% if num_im>1
%     set(handles.ls_sel_im_slide,'sliderstep',[1 1]/(num_im-1),...
%         'max',num_im,'min',1,'Value',1);
% else
%     set(handles.ls_sel_im_slide,'sliderstep',[1 1],...
%         'max',1.1,'min',1,'Value',1);
% end
% 
% set(handles.ls_im_sel_tip, 'String',...
%     ['Image 1 is displayed, start time: ' num2str(time_cell{1}) '.'])
% 
% axes(handles.ls_show_stimuli)
% imshow(img_cell{1});
% axes(handles.ls_show_mask)
% imshow(im_labrgb_convert(mask_cell{1}, handles.cform.lab2rgb));
% set(handles.ls_retinal_processing,'Enable','on')
load_images_to_display(hObject,img_cell,time_cell,handles);

% load the preprocessing .
if(handles.stage_li ==1);
    ls_retinal_processing_Callback(get(hObject,'Parent'));
end
end

function load_images_to_display(hObject,img_cell,time_cell,handles)

% get number of images
num_im =length(img_cell); % for test purpose
handles.num_im =num_im;

handles.img_cell =img_cell;
% generate input for further processing
mask_cell{1} =imread(fullfile(handles.path_data, 'NoMask.png'));
mask_cell{1} =im_labrgb_convert(mask_cell{1}, handles.cform.rgb2lab);
% mask_cell will be in Lab color space
handles.mask_cell =repmat(mask_cell, 1, length(img_cell));
handles.time_cell =time_cell;
guidata(hObject, handles);


% set up the slide
if num_im>1
    set(handles.ls_sel_im_slide,'sliderstep',[1 1]/(num_im-1),...
        'max',num_im,'min',1,'Value',1);
else
    set(handles.ls_sel_im_slide,'sliderstep',[1 1],...
        'max',1.1,'min',1,'Value',1);
end

set(handles.ls_im_sel_tip, 'String',...
    ['Image 1 is displayed, start time: ' num2str(time_cell{1}) '.'])

axes(handles.ls_show_stimuli)
imshow(img_cell{1});
axes(handles.ls_show_mask)
imshow(im_labrgb_convert(mask_cell{1}, handles.cform.lab2rgb));
set(handles.ls_retinal_processing,'Enable','on')

end


      



% --- Executes during object creation, after setting all properties.
function ls_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end



% --- Executes on slider movement.
function ls_sel_im_slide_Callback(hObject, eventdata, handles)
% hObject    handle to ls_sel_im_slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ind_im_show =round(get(hObject,'Value'));

if (~isfield(handles, 'img_cell'))&&(~isfield(handles, 'mask_cell'))
    % both stumuli and mask images are not given, do nothing
    set(handles.ls_im_sel_tip, 'String',...
        'Neither stimuli nor mask images are given.')
else
    stimuli_this =handles.img_cell{ind_im_show};
    mask_this =im_labrgb_convert(handles.mask_cell{ind_im_show}, handles.cform.lab2rgb);
    time_this =handles.time_cell{ind_im_show};
    % show the image
    axes(handles.ls_show_stimuli)
    imshow(stimuli_this);
    
    axes(handles.ls_show_mask)
    imshow(mask_this);
    
    set(handles.ls_im_sel_tip, 'String',...
        ['Image ' num2str(ind_im_show) ' is displayed, start time: ' num2str(time_this) '.'])
end
end

% --- Executes during object creation, after setting all properties.
function ls_sel_im_slide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_sel_im_slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


function ls_im_sel_tip_Callback(hObject, eventdata, handles)
% hObject    handle to ls_im_sel_tip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ls_im_sel_tip as text
%        str2double(get(hObject,'String')) returns contents of ls_im_sel_tip as a double
end

% --- Executes during object creation, after setting all properties.
function ls_im_sel_tip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_im_sel_tip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes during object creation, after setting all properties.
function ls_show_stimuli_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_show_stimuli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ls_show_stimuli
end

% --- Executes on button press in ls_retinal_processing.
function ls_retinal_processing_Callback(hObject, eventdata, handles)
% hObject    handle to ls_retinal_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(nargin < 3)
    handles = guidata(hObject);
end

if handles.stage_li==1% do nothing unless images have been loaded
    set(handles.ls_retinal_processing,'Enable','off')
    fun_ls_statusbar_start(handles.load_stimuli_figure)
    if handles.stage_pm ==1
        params = cell2struct(handles.para_list_value,handles.para_list_field, 2);
    else
        params =struct;
    end
    params.useGUI =true;
    
    handles =update_parameters(handles, params);
    
    params = cell2struct(handles.para_list_value,handles.para_list_field, 2);
    
    fun_ls_statusbar_msg(handles.load_stimuli_figure, 'Retinal processing - Working hard...');
    
    
    [visualstimulus,params] = retinalProcessing(handles.img_cell,params, handles.load_stimuli_figure);
    
    fun_ls_statusbar_msg(handles.load_stimuli_figure, 'Retinal processing - Saving data.');
    handles =update_parameters(handles, params);
    handles.visualstimulus_cell =visualstimulus;
    handles.stage_rp = 1;
    
    
    handles.mask_cell =visualstimulus;
    guidata(hObject,handles); % save data
    
    % display the results
    set(handles.ls_sel_im_slide, 'Value',1);
    axes(handles.ls_show_stimuli)
    imshow(handles.img_cell{1});
    
    axes(handles.ls_show_mask)
    imshow(im_labrgb_convert(handles.mask_cell{1}, handles.cform.lab2rgb));
    
    fun_ls_statusbar_msg(handles.load_stimuli_figure, 'Retinal processing - Done! Ready for next step.');
    if(length(handles.img_cell)==1)
            fun_ls_statusbar_msg(handles.load_stimuli_figure,'ERROR! You need at least 2 images for this to run!');        
    end
    set(handles.ls_retinal_processing,'Enable','on')
    
else
    fun_ls_statusbar_msg(handles.load_stimuli_figure, 'Please load images first.');
end
guidata(hObject,handles);
end

% --- Executes on button press in ls_close_pushbutton.
function ls_close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ls_close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the current position of the GUI from the handles structure
% to pass to the modal dialog.

% Getting rid of this functionality at the moment as it is not nescessary.

% button = questdlg('Are you sure to close?', 'Confirm close', 'Yes');
% 
% if strcmpi(button, 'yes') % otherwise do nothing
%     %     load_stimuli_GUI_OutputFcn(hObject, eventdata, handles)
%     close(handles.load_stimuli_figure)
% end

close(handles.load_stimuli_figure);

end

function fun_ls_statusbar_start(fighandle)
statusbar(fighandle); % delete status bar from current figure
statusbar(fighandle, 'Please wait while processing...');
end

function fun_ls_statusbar_progress(fighandle, idx, total)

statusbar(fighandle, 'Processing %d of %d (%.1f%%)...',idx,total,100*idx/total);
N=10;
statusbar(fighandle, 'Running... [%s%s]',repmat('*',1,fix(N*idx/total)),repmat('.',1,N-fix(N*idx/total)));
end

function fun_ls_statusbar_exit(fighandle)
statusbar(fighandle); % delete status bar from current figure
end

function fun_ls_statusbar_msg(fighandle, msg)
statusbar(fighandle, msg);
end



function ls_para_pstep_val_Callback(hObject, eventdata, handles)
% hObject    handle to ls_para_pstep_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ls_para_pstep_val as text
%        str2double(get(hObject,'String')) returns contents of ls_para_pstep_val as a double
list_field_tmp{1} ='step';
user_string = get(hObject,'String');
list_value_tmp{1} =str2double(user_string);
handles =update_parameters(handles, list_field_tmp, list_value_tmp);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function ls_para_pstep_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_para_pstep_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function ls_para_mexec_val_Callback(hObject, eventdata, handles)
% hObject    handle to ls_para_mexec_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ls_para_mexec_val as text
%        str2double(get(hObject,'String')) returns contents of ls_para_mexec_val as a double
list_field_tmp{1} ='MAX_SCREEN_EC';
user_string = get(hObject,'String');
list_value_tmp{1} =str2double(user_string);
handles =update_parameters(handles, list_field_tmp, list_value_tmp);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function ls_para_mexec_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ls_para_mexec_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
