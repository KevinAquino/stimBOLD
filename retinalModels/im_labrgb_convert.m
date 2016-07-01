function im_out =im_labrgb_convert(im_in, cform)
% imshow_lab2rgb converts im from lab color space to rgb for imshow, or
% from rgb to lab space.
%
%   Inputs: im_in, the input image, either in L*a*b or RGB
%
%   Outputs:
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 11-Oct-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 11-Oct-2014  1st ed.
% Ver. 13-Oct-2014  Solve the transform value range issue.
if nargin<2
    cform =makecform('lab2srgb');
end

class_in =class(im_in);

if (strcmpi(cform.ColorSpace_in, 'rgb'))&&(~strcmpi(class(im_in), 'double'))
    im_in =im2double(im_in);
end

im_out = applycform(im_in,cform); 

if strcmpi(class_in, 'single')
   im_out =single(im_out); 
end