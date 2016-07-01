function listing= dir_select(name)
% dir_select 
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
% SHAO Wenbin, 15-Aug-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 15-Aug-2014  1st ed.
listing =dir(name);
len =length(listing);
b =false(1, len);

for m =1:len
    startIndex = regexpi(listing(m).name, '^\.+');
    if ~isempty(startIndex)
    b(m) =true;
    end
end

listing(b) =[];
