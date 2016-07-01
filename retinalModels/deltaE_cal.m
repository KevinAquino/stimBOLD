function deltaE= deltaE_cal(im_lab1, im_lab2, method)
% deltaE_cal calcualtes the delta E for different methods, de76, de94,
% de2000
%
%   Inputs: im_rgb1, imrgb2: input images in RGB format, if it is a gray
%           one, it will be automatically extended.
%           method: which method to calculate the color difference,
%           supports: cie76, cie94, cie2000
%
%   Outputs: deltaE, color difference matrix, not scaled.
%
%
% EXAMPLE
%
%
% NOTES
% References: http://www.colorwiki.com/wiki/Delta_E:_The_Color_Difference
%             http://en.wikipedia.org/wiki/Color_difference
%             http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
% SHAO Wenbin, 05-May-2014
% Kevin Aquino
%
% UOW, email: wenbin@ymail.com
% History:
% Ver. 05-May-2014  1st ed.
% Ver. 08-May-2014  Error fix for CIE2000.
% Ver. 18-Nov-2014  allowed possibility of having LAB input KMA
% Ver. 19-Nov-2014  Remove the code to convert images from RGB to L*a*b. 
%                   The images are processed in L*a*b space and thus no
%                   need to convert from RGB to L*a*b. 

% for debugging
% path_img =[userfolder filesep 'science\surface_work\Striate_v1\ring_images'];
% im_rgb1 =imread([path_img filesep 'Pat_m10_p1.jpg']);
% im_rgb2 =imread([path_img filesep 'Pat_m10_p2.jpg']);
% figure;
% subplot(1,2,1), imshow(im_rgb1);
% subplot(1,2,2), imshow(im_rgb2);

% if(strcmp(method,'de94LAB'))
%     im_lab1 = im2double(im_rgb1);
%     im_lab2 = im2double(im_rgb2);
%     
% else
%     cform1 = makecform('srgb2lab');
%     im_lab1 = applycform(im2double(im_rgb1),cform1);
%     im_lab2 = applycform(im2double(im_rgb2),cform1);
% end

switch lower(method)
    case {'cie76', 'de76', '76'}
        % Color difference Delta E between image
        delta_L =im_lab1(:,:,1)-im_lab2(:,:,1);
        delta_A =im_lab1(:,:,2)-im_lab2(:,:,2);
        delta_B =im_lab1(:,:,3)-im_lab2(:,:,3);
        deltaE = sqrt(delta_L.^ 2 + delta_A.^ 2 + delta_B.^ 2);
        
    case {'cie94', 'de94', '94', 'de94'}
        C1 =sqrt(im_lab1(:,:,2).^2+im_lab1(:,:,3).^2);
        C2 =sqrt(im_lab2(:,:,2).^2+im_lab2(:,:,3).^2);
        
        kL =1;
        k1 =0.045;
        k2 =0.015;
        sL =1;
        
        sC =1+k1*C1;
        sH =1+k2*C1;
        
        delta_L =im_lab1(:,:,1)-im_lab2(:,:,1);
        delta_A =im_lab1(:,:,2)-im_lab2(:,:,2);
        delta_B =im_lab1(:,:,3)-im_lab2(:,:,3);
        delta_C =C1-C2;
        delta_H_prime =sqrt(delta_A.^2+delta_B.^2 -delta_C.^2);
        
        deltaE =sqrt((delta_L./(kL*sL)).^2+...
            (delta_C./sC).^2+...
            (delta_H_prime./sH).^2);
        
    case {'cie2000', 'de2000', '2000'}
        C1 =sqrt(im_lab1(:,:,2).^2+im_lab1(:,:,3).^2);
        C2 =sqrt(im_lab2(:,:,2).^2+im_lab2(:,:,3).^2);
        
        
        delta_L_prime =im_lab1(:,:,1)-im_lab2(:,:,1);
        L_bar =(im_lab1(:,:,1)+im_lab2(:,:,1))/2;
        C_bar =(C1+C2)/2;
        
        G_coe =(1-sqrt(C_bar.^7./(C_bar.^7+25^7)))/2;
        
        A1_prime =im_lab1(:,:,2).*(1+G_coe);
        A2_prime =im_lab2(:,:,2).*(1+G_coe);
        C1_prime =sqrt(A1_prime.^2+im_lab1(:,:,3).^2);
        C2_prime =sqrt(A2_prime.^2+im_lab2(:,:,3).^2);
        C_bar_prime =(C1_prime+C2_prime)/2;
        delta_C_prime =C2_prime -C1_prime;
        
        h1_prime =atan2(im_lab1(:,:,3), A1_prime);
        h1_prime =h1_prime +(h1_prime<0)*2*pi;
        h2_prime =atan2(im_lab2(:,:,3), A2_prime);
        h2_prime =h2_prime +(h2_prime<0)*2*pi;
        
        %         H1 =atan2(im_lab1(:,:,3),im_lab1(:,:,2));
        %         H2 =atan2(im_lab2(:,:,3),im_lab2(:,:,2));
        %
        delta_h_prime =h2_prime-h1_prime; % delta h
        delta_h_prime = delta_h_prime - 2*pi*(delta_h_prime >pi);
        delta_h_prime = delta_h_prime + 2*pi*(delta_h_prime <(-pi));
        
        delta_H_prime =2*sqrt(C1_prime.*C2_prime).*sin(delta_h_prime/2);
        
        H_bar_prime =(h1_prime+h2_prime)/2;
        
%         H_bar_prime = H_bar_prime - ( abs(h1_prime-h2_prime)>pi) *pi;
% % rollover ones that come -ve
%         H_bar_prime = H_bar_prime+ (H_bar_prime < 0) *2*pi;
        
        H_bar_prime =H_bar_prime + (abs(h1_prime-h2_prime)>pi)*pi;
        
        T = 1 - 0.17*cos(H_bar_prime - pi/6 ) + 0.24*cos(2*H_bar_prime) + 0.32*cos(3*H_bar_prime+pi/30) ...
            -0.20*cos(4*H_bar_prime-63*pi/180);
        
        tmp1 =(L_bar -50).^2;
        sL = 1 + 0.015*tmp1./sqrt(20+tmp1);
        sC = 1+0.045*C_bar_prime;
        sH = 1 + 0.015*C_bar_prime.*T;
        tmp2_deltatheta = 30*pi/180*exp(- ( (180/pi*H_bar_prime-275)/25).^2);
        % tmp2 needs to convert back to radian
        
        rC =  2*sqrt((C_bar_prime.^7)./(C_bar_prime.^7 + 25^7));
        rT =  - sin(2*tmp2_deltatheta).*rC;
        
        deltaE =sqrt((delta_L_prime./sL).^2+...
            (delta_C_prime./sC).^2+...
            (delta_H_prime./sH).^2+...
            rT.*delta_C_prime./sC.*delta_H_prime./sH);
        %
        %         im_out =scale_matrix2(deltaE);
        %         figure, imshow(im_out); title('cie2000')
        %
    otherwise
        deltaE= deltaE_cal(im_rgb1, im_rgb2, 'cie94');
end