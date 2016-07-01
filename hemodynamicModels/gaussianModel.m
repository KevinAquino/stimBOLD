% Calculate the Gaussian response for the hemodynamics
% Kevin Aquino 2014

%gaussianModel.m This file shows the hemodynamic response due to a Gaussian
%like model.

% get this fixed up


% convolve zxt with a Gaussian Model
FWHM = 3e-3;
sigma_x = FWHM/(2*sqrt(log(2)*2));

% sigma_x = 3e-3; % need to check this again, whether or not this is the right way to do it.

sigma = sigma_x/dx;% size of the Gaussian
ngx = 50;ngy = 50; %support of the Gaussian


H = fspecial('gaussian',[ngx ngy],sigma);

% once you have the Gaussian filter, then what you do is use it to smooth
% away the data.

for nt=1:size(zxt,3)
    bold(:,:,nt) = filter2(H,zxt(:,:,nt));
end

% next step is to then convolve the temporal HRF with the BOLD data. make
% sure that you calculate the HRF using enough points.
[t_calc,y_calc] = ode45('boldeqtnsPulse',linspace(-5,30,1000),[0;1;1;1]);


ballonHRF = ybold(y_calc(:,3),y_calc(:,4));
t_new = linspace(-t(end),t(end),length(t)*2);
HRF = interp1(t_calc,ballonHRF,linspace(-t(end),t(end),length(t)*2));

HRF(t_new<t(1)) = 0;

% now convolve.

bold2 = reshape(bold,[size(bold,1)*size(bold,2),size(bold,3)]);
boldSym = zeros(size(bold2,1),size(bold2,2)*2);
boldSym(:,size(bold2,2)+1:end) = bold2;

% HRFConvKernel = (repmat(HRF,[size(bold2,1) 1]));


for kk=1:size(boldSym,1)
    boldBig(kk,:) = conv(boldSym(kk,:),HRF,'same');
end
% boldBig = conv2(boldSym,HRFConvKernel,'same');



boldResponse = reshape(boldBig(:,size(bold2,2)+1:end),[size(bold,1),size(bold,2),size(bold,3)]);
clear bold2 boldBig;

