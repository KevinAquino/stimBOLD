function [m,n,nc, ns] =return_size_stimulus(visualStimulus, flag_one_im)
% return_size_stimulus returns the correct number of image size (m, n);
% nc, the number of color channels, and ns, the number of stimuls, 
% based on the input visualStimulus, which can be a cell or matrix
%
%   Inputs: visualStimulus, a cell or matrix
%
%   Outputs: m, number of rows of the image, 
%            n, number of columns of the image,
%            nc, number of colour channels
%            ns, number of stimulus
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 16-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 16-May-2014  1st ed.
if nargin<2
    flag_one_im =false; % if the input is one image or not
end

vec =size(visualStimulus);
if iscell(visualStimulus)
    [m, n, nc] =size(visualStimulus{1});
    ns =length(visualStimulus);
else
    m =vec(1);
    n =vec(2);
    if flag_one_im
        m =vec(1);
        n =vec(2);
        try
            nc =vec(3);
            ns =1;
        catch
            nc =1;
            ns =1;
        end
    else
        if length(vec)==3
            nc =1;
            ns =vec(3);
        elseif length(vec) ==4
            nc =vec(3);
            ns =vec(4);
        end
    end
end
