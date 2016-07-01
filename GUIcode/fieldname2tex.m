function texname= fieldname2tex(fieldname)
% fieldname2tex
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

if iscell(fieldname)
  texname= cellfun(@(x) fieldname2tex(x), fieldname, 'UniformOutput', false);
else
switch lower(fieldname)
    case 'stim_time'
        texname ='stim\_time';
    case 'isi_time'
        texname ='isi\_time';
    case 'hemo_model'
        texname ='hemo\_model';
    case 't_start'
        texname ='t_{start}';
    case 't_end'
        texname ='t_{end}';
    case 'num_time'
        texname ='num\_time';
    case 'extra_cortex'
        texname ='extra\_cortex';
    case 'y_bounds'
        texname ='y\_bounds';
    case 'max_screen_ec'
        texname ='MAX\_SCREEN\_EC';
    otherwise
        texname =fieldname;
end
end
