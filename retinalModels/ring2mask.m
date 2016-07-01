function img_mask= ring2mask(img, img_bg, para)
% ring2mask converts a stimuli image to a binary mask image automatically.
% For other approaches, see s_test_ring2mask.m
%
%   Inputs: img: stimuli image,
%           bg: back ground image,
%           para, a struct
%               se1:  morphological structuring element size for the 1st step
%           (remove gray lines)
%               se2:  morphological structuring element size for the 2nd step
%           (close opening part)
%           bg: back ground image
%
%   Outputs: img_mask: binary mask image
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 13-Mar-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 13-Mar-2014  1st ed.
% Ver. 20-Mar-2014  Simplify code, bug fix
% Ver. 21-Mar-2014  Big mode bug (add single conversion)
% Ver. 11-Apr-2014  Change threshold from 5 to 3.5
% Ver. 14-Apr-2014  Add an input 'bg' for background,
%                   Change the order of input
%                   Modify the parameter input into a structure array, make
%                   it suitable for furture extension
% Ver. 15-Apr-2014  Change the field names for threshold.
%                   Change pixel field value from 25 to 20

if nargin<2, img_bg =[]; end
if nargin<3 || isempty(para)
    para =struct;
end


if isempty(img_bg) % without background
    % check input
    if isfield(para, 'se1'), se1 =para.se1; else se1 =5; end
    if isfield(para, 'se2'), se2 =para.se2; else se2 =5; end
    if isfield(para, 'threshold_auto')
        threshold =para.thresh;
    else
        threshold =3.5;
    end
    
    background = imopen(img,strel('disk',se1));
    
    img_gray =rgb2gray(background);
    
    imp_freq = mode(single(img_gray(:)));
    
    img_p =img_gray;
    
    img_bin_ind =(img_gray <imp_freq+threshold)&(img_gray>imp_freq-threshold);
    img_p(img_bin_ind) =0;
    
    img_p(img_p~=0) =255;
    
    img_mask =imclose(img_p,strel('disk',se2));
    img_mask =im2bw(img_mask);
    % imshow(img_mask)
    
else % with background supplied, see s_test_ring2mask
     if isfield(para, 'pixel'), no_pixel =para.pixel; else no_pixel =20; end
        if isfield(para, 'se2'), se2 =para.se2; else se2 =5; end
    if isfield(para, 'threshold_mask')
        threshold =para.thresh;
    else
        threshold =1.5;
    end
        
    if threshold>1
        threshold =threshold/255;
    end
    
    img =im2double(img);
    img_bg =im2double(img_bg); % use first as the background
    %
    
    img =rgb2gray(img);
    img_bg =rgb2gray(img_bg);
    
    I1 =img-img_bg;
    
    % after subtraction, I1 can have negative values
    I1c =abs(I1(:));
    I1c(I1c>threshold) =1;
    I1c =reshape(I1c, size(I1));
    
    BW2 = bwareaopen(im2bw(I1c), no_pixel); % remove small objects, 
%     this line is not necessary with a correct background image 
    
    img_mask =imclose(BW2,strel('disk',se2));
end