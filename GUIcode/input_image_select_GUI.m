function varargout = input_image_select_GUI(varargin)
% INPUT_IMAGE_SELECT_GUI MATLAB code for input_image_select_GUI.fig
%      INPUT_IMAGE_SELECT_GUI, by itself, creates a new INPUT_IMAGE_SELECT_GUI or raises the existing
%      singleton*.
%
%      H = INPUT_IMAGE_SELECT_GUI returns the handle to a new INPUT_IMAGE_SELECT_GUI or the handle to
%      the existing singleton*.
%
%      INPUT_IMAGE_SELECT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUT_IMAGE_SELECT_GUI.M with the given input arguments.
%
%      INPUT_IMAGE_SELECT_GUI('Property','Value',...) creates a new INPUT_IMAGE_SELECT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before input_image_select_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to input_image_select_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% NOTES
% SHAO Wenbin, 05-Mar-2014
% UOW, email: wenbin@ymail.com
% Ver. 15-Apr-2014 Start recording version changes
%                  GUI interface alignment change
% Ver. 17-Sep-2014 Minor interface change.
%                  

% Edit the above text to modify the response to help input_image_select_GUI

% Last Modified by GUIDE v2.5 29-Apr-2014 14:08:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @input_image_select_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @input_image_select_GUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before input_image_select_GUI is made visible.
function input_image_select_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to input_image_select_GUI (see VARARGIN)

% Choose default command line output for input_image_select_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.input_im_sel_imshow,'Title',text('String','Preview'))
set(handles.input_im_sel_imshow,'Visible','off');
set(get(handles.input_im_sel_imshow,'Title'),'Visible','on');

% UIWAIT makes input_image_select_GUI wait for user response (see UIRESUME)
% uiwait(handles.input_im_sel_figure);
handles.im_count =1;
% handles.im_list =cell(0,0);
handles.im_list_startdir =[pwd filesep];

% handles.next_im_OK =false;

guidata(hObject, handles)
% uiwait(handles.input_im_sel_figure);
uiwait(handles.input_im_sel_figure);

% --- Outputs from this function are returned to the command line.
function varargout = input_image_select_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = handles;
delete(handles.input_im_sel_figure)


% --- Executes on button press in input_im_sel_files.
function input_im_sel_files_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_saveback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% error check
% disable folder function
set(handles.input_im_sel_folder,'Enable','off');

% user_string =get(handles.input_im_sel_edit1,'String');
% if ~isempty(user_string)
%     set(handles.input_im_sel_edit1,'String',[]);
% end

% main body
[filename, pathname] = ...
    uigetfile({'*.jpg';'*.bmp';'*.tif';'*.*'},'File Selector', handles.im_list_startdir);


if ~ischar(filename) &&handles.im_count==1 % user cancelled, use ischar instead of checking if filename is 0
    set(handles.input_im_sel_folder,'Enable','on');
elseif ischar(filename)
    %     handles.next_im_OK =false;
    
    handles.im_list_startdir =pathname;
    
    %     set(handles.input_im_sel_edit1,'String',[pathname filename])
    name_in_this =[pathname filename];
    data_in_this = imread([pathname filename]);
    
    axes(handles.input_im_sel_imshow)
    imshow(data_in_this);
    
    % TBD: change these lines to Combine Cell Arrays approaches.
    handles.name_in{handles.im_count} =name_in_this;
    handles.data_in{handles.im_count} =data_in_this;
    
    handles.im_list{handles.im_count} =name_in_this;
    
    set(handles.input_im_sel_listbox1,'String',handles.im_list)
    set(handles.input_im_sel_listbox1,'Value',handles.im_count)
    guidata(hObject, handles);
    
end



function input_im_sel_timeedit_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_timeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_im_sel_timeedit as text
%        str2double(get(hObject,'String')) returns contents of input_im_sel_timeedit as a double
user_string = get(hObject,'String');

if iscell(user_string)
    time_in_this =str2num(user_string{1}); %#ok<ST2NM> %
else
    time_in_this =str2double(user_string);
end

if length(time_in_this) ==1
    if isnan(time_in_this)
        %     warning('input:wrongtime', 'You must give a valid time value.')
        x = inputdlg('Invalida time, enter a valid number:', 'Start time');
        time_in_this = str2double(x{:});
    end
    
    if handles.im_count>1
        if time_in_this < handles.time_in{handles.im_count-1}
            %         warning('input:smalltime', 'Start time must be greater than the previous value %g.', handles.time_in{handles.im_count-1});
            prompt = {['Enter a valid start time that is greater than ' num2str(handles.time_in{handles.im_count-1})]};
            x = inputdlg(prompt, 'Start time');
            time_in_this = str2double(x{:});
            set(handles.input_im_sel_timeedit,'String', x{:});
        end
    end
    
    % change the following lines using cell concatenating approaches.
    handles.time_in{handles.im_count} =time_in_this;
    handles.im_list{handles.im_count} =[handles.name_in{handles.im_count} '; Start time: ' num2str(time_in_this)];
    set(handles.input_im_sel_listbox1,'String',handles.im_list)
    
    guidata(hObject, handles);
elseif length(time_in_this) >1&& strcmpi(get(handles.input_im_sel_files,'Enable'), 'off')
    
    if length(time_in_this)<length(handles.data_in)
        dlg_title = 'Input start time for your images';
        num_lines = 1;
        def = {['0:0.25:' num2str(0.25*length(handles.data_in))]};
        answer = inputdlg('Not enough start time points, OK to provide more time points',dlg_title,num_lines,def);
        time_in_this =str2num(answer{1});
    end
    handles.time_in =num2cell(time_in_this);
    handles.im_count =length(handles.data_in);
end
set(hObject,'String', num2str(time_in_this));
guidata(hObject, handles)
% uiresume(input_im_sel_figure);

% --- Executes during object creation, after setting all properties.
function input_im_sel_timeedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_timeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_im_sel_nextim.
function input_im_sel_nextim_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_nextim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% in case forget to input time
user_string = get(handles.input_im_sel_timeedit,'String');

if ~isempty(user_string)% || handles.next_im_OK % if is empty, do nothing.
    input_im_sel_timeedit_Callback(handles.input_im_sel_timeedit, eventdata, handles)
    % prepare for next
    % set(handles.input_im_sel_edit1,'String', []);
    set(handles.input_im_sel_timeedit,'String', []);
    handles.im_count =handles.im_count +1;
    guidata(hObject, handles);
    %     input_im_sel_files_Callback(handles.input_im_sel_files, eventdata, handles)
    
    %     handles.next_im_OK =true;
end
guidata(hObject, handles)

% --- Executes on button press in input_im_sel_saveback.
function input_im_sel_saveback_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_saveback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save a text file
[filename, pathname] = uiputfile({'*.txt'}, 'Save as');

if ~filename ==0
    
    name_cell =handles.name_in;
    %
    fid = fopen(fullfile(pathname, filename), 'w', 'n', 'UTF-8');
    % Save the time at the first line
    fprintf(fid, '%g, ', handles.time_in{:});
    fprintf(fid, '\r\n');
    
    % Print file locations
    for m =1:length(name_cell)
        fprintf(fid, '%s\r\n', name_cell{m});
    end
    fclose(fid);
    % uiresume(handles.input_im_sel_figure);
    handles.output =true;
    guidata(hObject,handles)
    uiresume(handles.input_im_sel_figure);
end
% close(handles.input_im_sel_figure);
% delete(handles.input_im_sel_figure);
% uiresume(handles.input_im_sel_figure);


% --- Executes on selection change in input_im_sel_listbox1.
function input_im_sel_listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_im_sel_listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_im_sel_listbox1
if isfield(handles, 'name_in')
    index_selected = get(hObject,'Value');
    item_selected = handles.data_in{index_selected};
    axes(handles.input_im_sel_imshow)
    imshow(item_selected);
end

% --- Executes during object creation, after setting all properties.
function input_im_sel_listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function input_im_sel_figure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% delete(handles.input_im_sel_figure)
% uiresume(hObject);


% --- Executes when user attempts to close input_im_sel_figure.
function input_im_sel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% uiresume(hObject);

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

% --- Executes during object creation, after setting all properties.
function input_im_sel_imshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_imshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate input_im_sel_imshow


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over input_im_sel_files.
function input_im_sel_files_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to input_im_sel_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in input_im_sel_folder.
function input_im_sel_folder_Callback(hObject, eventdata, handles)
% hObject    handle to input_im_sel_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% once this button is pressed, the image selection button and next image button
% will be disable.
set(handles.input_im_sel_files,'Enable','off');
set(handles.input_im_sel_nextim,'Enable','off');
guidata(hObject, handles);
% get the folder
dir_in = uigetdir([],'Choose the folder where images are saved');

if dir_in ==0 % if the user cancelled the selection
    set(handles.input_im_sel_files,'Enable','on');
    set(handles.input_im_sel_nextim,'Enable','on');
    
else % show all files in the list box
    prompt = {'Image file extension:'};
    dlg_title = 'Input extension';
    num_lines = 1;
    def = {'jpg'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    img_ext =answer{1};
    
    img_files =dir_select(fullfile(dir_in, ['*.' img_ext]));
    num_im =length(img_files);
    
    %     handles.im_count =num_im;
    
    cell_img_names ={img_files.name};
    [cs,index] = sort_nat(cell_img_names);
    cell_img_names =cs;
    
    % display the files
    cell_img_names_full = cellfun(@(x) fullfile(dir_in, x), cell_img_names, 'UniformOutput', false);
    handles.name_in =cell_img_names_full;
    set(handles.input_im_sel_listbox1,'String',handles.name_in)
    guidata(hObject, handles);
    
    % read in the images and display the first image
    for m =1:num_im
        handles.data_in{m} =imread(cell_img_names_full{m});
    end
    set(handles.input_im_sel_listbox1,'Value',1)
    axes(handles.input_im_sel_imshow)
    imshow(handles.data_in{1});
    
    set(handles.input_im_sel_timeedit,'String', []);
    % generate default values for start time
    def = {['0:0.25:' num2str(0.25*(num_im-1))]};
    set(handles.input_im_sel_timeedit,'String',def)
    handles.time_in =num2cell(0:0.25:0.25*(num_im-1));
    
end
guidata(hObject, handles)
