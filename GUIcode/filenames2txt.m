function img_files =filenames2txt(dir_in, ext, txtname, dir_out, time_cell)
% filenames2txt save all the filenames in the dir_in folder to a text file, 
% excluding all folders in dir_in 
%
%   Inputs: dir_in: where the files are saved
%           ext: the file extensions
%           txtname: text file name
%           dir_out: where the text file is saved
%           time_cell: the start time for images, it is a cell
%
%   Outputs: img_files, a structure array
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 06-Mar-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 06-Mar-2014  1st ed

if nargin <4, dir_out =dir_in; end
if nargin <3||isempty(txtname), txtname ='input_image_locations'; end
if nargin <2||isempty(ext), ext ='jpg'; end

if ~strcmpi(txtname(end-3:end), '.txt')
    txtname =[txtname '.txt'];
end

img_files =dir(fullfile(dir_in, ['*.' ext]));

fid = fopen(fullfile(dir_out, txtname), 'w', 'n', 'UTF-8');
fprintf(fid, '%g, ', time_cell{:});
fprintf(fid, '\r\n');

for m =1:length(img_files)
 fprintf(fid, '%s\r\n', fullfile(dir_in, img_files(m).name));   
end
fclose(fid);
