function visualStimulus_cell= mat2cell_vs(visualStimulus)
% mat2cell_vs converts the input into a cell array, the length of cell is
% the last dimension of the input.
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
% SHAO Wenbin, 19-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 19-May-2014  1st ed.

if ~iscell(visualStimulus)
    siz_vs =size(visualStimulus);
    siz_vs =num2cell(siz_vs);
    siz_vs{end} =ones(1, siz_vs{end});    
    visualStimulus_cell =mat2cell(visualStimulus,siz_vs{:});
    visualStimulus_cell =squeeze(visualStimulus_cell);
    if size(visualStimulus_cell, 1) >size(visualStimulus_cell,2)
        visualStimulus_cell =visualStimulus_cell.';
    end
else
    visualStimulus_cell =visualStimulus;
end