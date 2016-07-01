function data_s= scale_matrix2(data, range)
% scale_matrix2 scales a matrix into [0 1] or a range specified by 'range'
% SYNTAX
%        = scale_matrix2()
%   Inputs:
%
%   Outputs:
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 28-Jul-2009
% UOW, email: wenbin@ymail.com

% Fixed to handle 0 values, KMA

if nargin ==1
    range =[0 1];
end

data_c =data(:);

if(max(data_c) == min(data_c))
    data_s = data;
else
    data_s =(data-min(data_c))./(max(data_c) -min(data_c)).*(range(2) -range(1)) +range(1);
end