function path_fs= getpath_freesurfer(dir_main, folder_parts)
% getpath_freesurfer returns the freesurfer path of the system
%
%   Inputs: dir_main: main folder of the create_main_gui.m
%           folder_parts, it is a cell.
%           Both dir_main and folder_parts together give the path where
%           freesurfer_path.mat is saved.
%           Note that the path should be 'Toolbox main
%           folder/GUIcode/data/'
%
%   Outputs: path_fs: free surfer path
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 03-Jul-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 03-Jul-2014  1st ed.
% Ver. 11-Aug-2014  Solve the issue caused by the calling function not in 
%                   the main folder of the toolbox, add an description of
%                   the input folder_parts.
% Ver. 28-Aug-2014  Add hostname check; spray for bugs.
% Ver. 19-Nov-2014  Bug kill.

%
if nargin<2
    dir_mat =fullfile(dir_main, 'data', 'freesurfer_path.mat');
else
    dir_mat =fullfile(dir_main, folder_parts{:}, 'freesurfer_path.mat');
end

if exist(dir_mat, 'file')
    vars = whos('-file', dir_mat, 'pcname');
    if isempty(vars)
        pcname_old =[];
    else
        tmp=load(dir_mat, 'pcname');
        pcname_old =tmp.pcname;
    end
    
    load(dir_mat, 'path_fs');
    
else
   path_fs =[]; 
end

% [tmp, pcname] =system('hostname');
pcname = char(getHostName(java.net.InetAddress.getLocalHost));
% ip = char( getHostAddress( java.net.InetAddress.getLocalHost));
% user = getenv('UserName');

if ~exist(path_fs, 'dir')||(isempty(pcname_old))||(~strcmpi(pcname, pcname_old))
    if ismac
        dir_mat ='/Applications/freesurfer';
        if exist(dir_mat, 'dir')
            path_fs =dir_mat;
        else path_fs =[];
        end
    else
        path_fs =[];
    end
    
    if isempty(path_fs)
        path_fs = uigetdir('', 'Choose FreeSurfer folder');
        while path_fs==0
            path_fs = uigetdir('', 'Choose FreeSurfer folder');
        end
    end
        
    save(dir_mat, 'path_fs', 'pcname');
end