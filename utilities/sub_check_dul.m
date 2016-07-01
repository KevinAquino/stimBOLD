function [vec_next_index, dis_next]= sub_check_dul(vec_next_index, dis_next, method)
% sub_check_dul
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
% SHAO Wenbin, 04-Nov-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 04-Nov-2014  1st ed, add a third input

if nargin<3
    method ='min';
end


[vec_next_index,IX] = sort(vec_next_index);
dis_next =dis_next(IX);
delta = vec_next_index(2:end) - vec_next_index(1:end-1);

tmp_ind_a1 =1:length(vec_next_index)-1;
tmp_ind_a2 =1:length(vec_next_index);

tmp_ind1 =tmp_ind_a1(delta == 0);

if isempty(tmp_ind1)
    return;
else
    
    dup_ind =unique(vec_next_index(tmp_ind1));
    
    switch lower(method)
        case 'min'
            for m =1:length(dup_ind)
                tmp_dup_ind =(vec_next_index==dup_ind(m));
                dis_next(tmp_dup_ind) =min(dis_next(tmp_dup_ind));
            end
        case 'max'
            
            for m =1:length(dup_ind)
                tmp_dup_ind =(vec_next_index==dup_ind(m));
                dis_next(tmp_dup_ind) =max(dis_next(tmp_dup_ind));
            end
    end
    tmp_ind_a2(tmp_ind1) =[];
    
    vec_next_index =vec_next_index(tmp_ind_a2);
    dis_next =dis_next(tmp_ind_a2);
    
    % if length(unique(vec_next_index)) ~=length(vec_next_index)
    %     [vec_next_index, dis_next]= sub_check_dul(vec_next_index, dis_next);
    % end
end