function [visualStimulus,params] = retinalProcessing(visualStimulus,params, fig_display)
% retinalProcessing processes the visual stimulus in retinal space, using
% Gaussian blurring mask.
%
%   Inputs: visualStimulus, input, a m*n*k*p matrix or a 1*k or 1*p cell (recommended),
%                                    each cell is a matrix of size m*n or
%                                    m*n*k
%          params, parameters for processing, two fields needed for thye function
%                  im_filtering
%                      degree: the visual degree of the visual stimulus (in degree)
%                      step: the circular step to blur the image
%
%
%
%   Outputs: visualStimulus, output, a matrix or a cell, based on the input
%            params
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 01-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 01-May-2014  1st ed.
% Ver. 08-May-2014  Add GUI flag, when call from GUI, it must supply three
%                   input.
% Ver. 16-May-2014  Now code works with 4-D visual stimulus data;
%                   change description.
% Ver. 19-May-2014  Simplify code. Remove GUI flag, put it in the
%                   parameters
% Ver. 12-Jun-2014  Code optimisation, bug fix
% Ver. 09-Jul-2014  Add error check when user cancel the parameter input
% Ver. 02-Sep-2014  Modify according to 'load_stimuli_GUI.fig'.
% Ver. 10-Oct-2014  Speed improvement.
% Ver. 21-Oct-2014  Add display related functions.
% Ver. 06-Nov-2014  Minor text change.
%% input check
if nargin<3
    fig_display =[];
end

if ~isfield(params, 'useGUI')
    params.useGUI =false;
end


if nargin<2 % this case means flag_GUI is false
    params = struct('MAX_SCREEN_EC',10, 'step', 1);
end

if params.useGUI % call from GUI
    if isempty(params) || ~isfield(params, 'MAX_SCREEN_EC') || ~isfield(params, 'step')
        prompt ={'Maximum screen eccentricity ', 'Processing step in degree'};
        def ={'15', '3'};
        dlgTitle='Parameters for retinal processing';
        largest_question_length = size((char(prompt')),2);
        lineNo=[1,largest_question_length+5];
        AddOpts.Resize='on';
        AddOpts.WindowStyle='normal';
        AddOpts.Interpreter='tex';
        answer=inputdlgcol(prompt,dlgTitle,lineNo,def,AddOpts,5);
        if ~isempty(answer)
            params.MAX_SCREEN_EC =str2double(answer{1});
            params.step =str2double(answer{2});
        else
            N =1;
            while isempty(answer)||N<=3
                answer=inputdlgcol(prompt,dlgTitle,lineNo,def,AddOpts,5);
                N =N+1;
            end
            if isempty(answer)
                params.MAX_SCREEN_EC =15;
                params.step =3;
            else
                params.MAX_SCREEN_EC =str2double(answer{1});
                params.step =str2double(answer{2});
            end
        end
        
    end
end



if ~params.useGUI 
    if ~isfield(params, 'MAX_SCREEN_EC'), params.degree =15; end
    if ~isfield(params, 'step'), params.step =3; end
end

flag_convert =false;
if ~iscell(visualStimulus)
    % convert visual stimulus to cell array to for cellfun
    visualStimulus= mat2cell_vs(visualStimulus);
    flag_convert =true;
end

%% processing, change the function im_filtering for different processing steps.
% params_cell =repmat({params}, 1, length(visualStimulus));
len_vs =length(visualStimulus);
for m =1:len_vs
    if ~isempty(fig_display)% && ((mod(m, 5)==1)||(m==len_vs))
    statusbar(fig_display, 'Rentinal processing %3.2f%%...', m/len_vs*100);
    end
    visualStimulus{m} =im_filtering2(visualStimulus{m}, params);
end
% visualStimulus =cellfun(@(x) im_filtering2(x, params), visualStimulus, 'UniformOutput', false);

if flag_convert
    visualStimulus = cell2mat_vs(visualStimulus);
end