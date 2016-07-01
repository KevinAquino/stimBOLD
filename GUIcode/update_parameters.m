function handles_sub =update_parameters(handles_sub, varargin)
% update_parameters, special GUI function 
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
% SHAO Wenbin, 24-Jun-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 24-Jun-2014  1st ed, move out from GUI main code
if nargin ==2
    list_field_tmp =fieldnames(varargin{1})';
    list_value_tmp =struct2cell(varargin{1})';
    
    
    if isempty(handles_sub.para_list_field)
        
        handles_sub.para_list_field =list_field_tmp;
        handles_sub.para_list_value =list_value_tmp;
        
    else
        list_field_tmp =[list_field_tmp, handles_sub.para_list_field];
        list_value_tmp =[list_value_tmp, handles_sub.para_list_value];
        
        [tmp1, ind_tmp, tmp2] = CStrUnique(list_field_tmp);
        handles_sub.para_list_field =list_field_tmp(ind_tmp);
        handles_sub.para_list_value =list_value_tmp(ind_tmp);
    end
    
elseif nargin==3
    list_field_tmp = varargin{1};
    list_value_tmp = varargin{2};
    
    if isempty(handles_sub.para_list_field)
        
        handles_sub.para_list_field =list_field_tmp;
        handles_sub.para_list_value =list_value_tmp;
        
    else
        list_field_tmp =[list_field_tmp, handles_sub.para_list_field];
        list_value_tmp =[list_value_tmp, handles_sub.para_list_value];
        
        [tmp1, ind_tmp, tmp2] = CStrUnique(list_field_tmp);
        handles_sub.para_list_field =list_field_tmp(ind_tmp);
        handles_sub.para_list_value =list_value_tmp(ind_tmp);
    end
end
