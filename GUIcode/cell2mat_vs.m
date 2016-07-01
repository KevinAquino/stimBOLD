function out_mat= cell2mat_vs(in_cell)
% cell2mat_vs converts an cell input to a matrix along the extra dimension.
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
% SHAO Wenbin, 20-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 20-May-2014  1st ed.

if iscell(in_cell)
    n_dim =length(size(in_cell{1})); 
    if n_dim==2 && isequal([1, 1], size(in_cell{1}))
        n_dim_out =2;
    else
        n_dim_out =n_dim+1;
    end
    out_mat =cat(n_dim_out, in_cell{:});
else
    out_mat =in_cell;
end