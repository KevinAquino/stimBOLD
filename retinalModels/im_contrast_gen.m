function im_out_adj= im_contrast_gen(im_lab1, im_lab2, para)
% im_contrast_gen generates the constrast mask based on a number of images.
%
%   Inputs: im_in1, an image in L*a*b space
%           im_in2, the next image,
%           para: a struct, three fields
%               method: de76, de94, or de2000;
%               gamma: gamma correction
%
%
%   Outputs: im_out, a cell, the same size with im_in, initially assume no
%   change, ie, value of 0
%
%
% NOTES
% References: http://www.colorwiki.com/wiki/Delta_E:_The_Color_Difference
%             http://en.wikipedia.org/wiki/Color_difference
% SHAO Wenbin, 29-Apr-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 29-Apr-2014  1st ed.
% Ver. 01-May-2014  Change the structure for cellfun, add lab space
%                    processing
% Ver. 05-May-2014  Use lab space as default, remove colorspace and change scale fields,
%                   add method_contrast, gamma fields; use function to
%                   calculate Delta-E, now three methods are supported
% Ver. 11-Jul-2014  Fixed scale_matix KMA.
% Ver. 19-Nov-2014  Code cleaning.

[method_contrast, para]= get_para(para, 'method_contrast', 'de94');
[gamma, para]= get_para(para, 'gamma', 0.45); % need to check the default value here is still suitable


deltaE= deltaE_cal(im_lab1, im_lab2, method_contrast);
im_out =scale_matrix2(deltaE);

% gamma correction, make gamma =1 if no adjust is needed
im_out_adj =im_out.^gamma; 


% figure, imshow(im_out_adj); title(method_contrast)

        

