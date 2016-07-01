function im_out= im_filtering2(im_in, para)
% im_filtering filters the image using the parameters in para. The input
% im_in must be one image, and the im_out must be one image. The para input
% is a strcuture array.
%
%   Inputs: im_in, input image, a matrix, rgb space
%           im_out, output image, a matrix
%           para, a structure array to transfer parameters,
%                .text: to be integrated into the display in the status bar
%                .degree: this is a 1*2 vector, the first number is the screen
%                         size in degree visual angle,
%                .step: step in degree to blur the image
%                .filter_h: 2D filter size, (not supported yet)
%                .filter_sigma: Gaussian std, variance is its square (not supported yet)
%                .type: 'blur'
%
%
%
%   Outputs: im_out: output image, l*a*b space
%
%
% EXAMPLE
%
%
% NOTES
% SHAO Wenbin, 17-Apr-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 17-Apr-2014  1st ed.
% Ver. 22-Apr-2014  Code writing and modification
% Ver. 29-Apr-2014  Speed improvement, memory improvement
% Ver. 08-May-2014  Change the code to handle color images, kill bugs.
% Ver. 12-May-2014  Simplify the code
% Ver. 09-Jul-2014  Handle rare error when step is large, and optimise.
% Ver. 06-Aug-2014  Change the way how the Gaussian filter is generated,
%                   especailly the relationship between sigma and square kernel size:
%                   6*sigma~=H_size
%                   Speed improvement: ~20%
%                   In the first ring, no blurring
% Ver. 02-Sep-2014  Modify according to 'load_stimuli_GUI.fig'. 
% Ver. 23-Sep-2014  Rewrite the function for speed optimisation.
%% for debugging
% im_in = imread('cameraman.tif');
% imshow(im_in)
%
% d_total =10;
% d_step =1;

rgb = imread('peppers.png');
cform = makecform('srgb2lab');
lab = applycform(rgb,cform); 

%%

if isfield(para, 'kernel_coe')
    kernel_coe =para.kernel_coe;
else
    kernel_coe =7; %
end

if isfield(para, 'type_filter')
    type_filter =para.type_filter;
else
    type_filter ='amean'; %
end


if isfield(para, 'rgb2lab')
    cform =para.rgb2lab;
else
    cform = makecform('srgb2lab'); %
end

im_in_lab = im_labrgb_convert(im_in, cform);
%% Consider moving the following out, if all images share the same size.
% find the centre of the input
[siz_m, siz_n, tmp1, tmp2] =size(im_in_lab); % in case it is a multi-dimensional matrix

y_c = siz_m/2;
x_c = siz_n/2;

[X_vec,Y_vec]=meshgrid(((1:siz_n)-x_c).^2,((1:siz_m)-y_c).^2);

D_mat =X_vec+Y_vec; % distance matrix from each point to center

num_inter = ceil(para.MAX_SCREEN_EC/para.step);
% d_point =linspace(0, 1, num_inter+1); %
d_point =0:1/num_inter:1;
r_point =d_point(2:end)*min([x_c, y_c]); % the distance in pixels
r_point =r_point.^2; %, 1, ones(1, length(r_point)));

% im_in_lab =im2single(im_in_lab); % convert to single to reduce memory
% im_in_c =repmat({im2single(im_in)}, 1, length(r_point));

if length(kernel_coe) ==1
    h_siz =kernel_coe:2:kernel_coe+2*(num_inter-2);
elseif length(kernel_coe)>=num_inter-1
    h_siz =kernel_coe(1:num_inter-1);
elseif length(kernel_coe)<num_inter-1
    h_siz =[kernel_coe, kernel_coe(end)+2:2:kernel_coe(end)+2+2*(num_inter-1-length(kernel_coe)-1)];
end
h_gamma =h_siz/6;

D_mat_ring =cell(1, num_inter);
for n =1:num_inter-1
    D_mat_ring{n} =D_mat<r_point(n);
end
D_mat_ring{num_inter} =ones(siz_m, siz_n);

% processing, first ring does not require process
im_out = bsxfun(@times, im_in_lab, D_mat_ring{1});


% double checked, the first circle is not blurred
for m =1:num_inter-1
    switch lower(type_filter)
        case {'gaussian', 'g'}            
        h = fspecial('gaussian', h_siz(m), h_gamma(m));
        im_tmp =imfilter(im_in_lab, h, 'replicate');
%         im_tmp =sub_imfiltering(im_in,h_siz(m), h_gamma(m));
        case {'amean'}
        h = fspecial('average', h_siz(m));
        im_tmp = imfilter(im_in_lab, h, 'replicate');
%         case {'alphatrim'}
%         im_tmp = alphatrim(im_in, h_siz(m), h_siz(m), 2); 
    end
    im_out =im_out + bsxfun(@times, im_tmp,(D_mat_ring{m+1} -D_mat_ring{m}));
end


% function f = alphatrim(g, m, n, d)
% %  Implements an alpha-trimmed mean filter.
% % The code is modifled from R. C. Gonzalez, R. E. Woods, and S. L. Eddins
% %   From the book Digital Image Processing Using MATLAB, 2nd ed., p. 162
% 
% f = imfilter(g, ones(m, n), 'symmetric');
% for k = 1:d/2
%     f = f - ordfilt2(g, k, ones(m, n), 'symmetric');
% end
% for k = (m*n - (d/2) + 1):m*n
%     f = f - ordfilt2(g, k, ones(m, n), 'symmetric');
% end
% f = f / (m*n - d);
% 
% 
% 
% D_mat_ring_c =cellfun(@(x) D_mat<=x, r_point_c, 'UniformOutput', false);
% %%
% 
% % filtering
% % im_out_c1 =cellfun(@(y) sub_imfiltering2(im_in_c,type_filtering,y),...
% %     h_siz_c, 'UniformOutput', false); % the place
% im_out_c1 =cellfun(@(y) spfilt(im_in,type_filter,y, y),...
%     h_siz_c, 'UniformOutput', false); % the place
% 
% % combine results
% D_mat_ring_cmb1 =[D_mat_ring_c(1:end-1), 1];
% D_mat_ring_cmb2 =[{0}, D_mat_ring_cmb1(1:end-1)];
% D_mat_ring_cmb =cellfun(@minus ,D_mat_ring_cmb1, D_mat_ring_cmb2, 'UniformOutput', false);
% 
% im_out_c2 =cellfun(@(x, y) bsxfun(@times, x, y),[{im_in}, im_out_c1], D_mat_ring_cmb, 'UniformOutput', false);
% 
% % use loop to save memory
% im_out =im_out_c2{1};
% for m =2:length(im_out_c2)
%     im_out =im_out+im_out_c2{m};
% end


%
% function sub_out =sub_imfiltering(sub_in, sub_h_siz, sub_h_gamma, bi_im)
%
% im_p =sub_in.*bi_im; %
%
% h = fspecial('gaussian', sub_h_siz, sub_h_gamma);
% sub_out =imfilter(im_p, h);

