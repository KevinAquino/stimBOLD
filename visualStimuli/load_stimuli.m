% load_stimuli.m
%
% Function to load the stimlui images from a batch file. This is extracted
% from load_stimuli_GUI as a light weight version for batch/command line
% running of mvibe.
%
% Kevin Aquino
% Wenbin Shao
% 2014.

function [visual_response,time_indices] = load_stimuli(filename)

fid =fopen(filename);
text_log = textscan(fid, '%s%[^\r\n]', 'Delimiter', '|'); % text_log{2} should be empty
fclose(fid);
text_log =text_log{1};

time_cell =num2cell(str2num(text_log{1}));

num_im =length(text_log) -1;
img_cell =cell(1, num_im);

for k =2:length(text_log)
    img_cell{k-1} =imread(text_log{k});    
end


visual_response = img_cell;
time_indices = time_cell;

