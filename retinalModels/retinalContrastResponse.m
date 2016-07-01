function [retinal_response,params] = retinalContrastResponse(retinal_blur,params,retinalTemplate,thmat,rmat)
% RetinalContrastresponse.m
%
% This function takes the retinal response that has been processed then
% generates the retinal contrast response. Currently it is not taking into
% effect spatial variation, it is only taking into effect the temporal
% contrast changes in luminance - L.
% 
% Kevin Aquino,
% Wenbin Shao.
% 2014.
% % flag here to pass on that the images are already in Lab space.
% [method_contrast, params]= get_para(params, 'method_contrast', 'de94');
% contrastParams.method_contrast =method_contrast;
% 
% % Generate the contrast response in time over the L*a*b channels
% contrast_cell = cellfun(@(x, y) im_contrast_gen(x, y, contrastParams), ...
%     retinal_blur(1:end-1), retinal_blur(2:end), 'UniformOutput', false);
% 
% % Initialize the contrast matrix
% 
% 
% contrast_matrix =[zeros(size(contrast_cell{1})), contrast_cell];
% contrast_matrix =cell2mat_vs(contrast_matrix);
% 
% % The luminance response is the first channel in L*a*b space.

luminanceTimeSeries = retinal_blur;
luminanceTimeSeries = cell2mat_vs(luminanceTimeSeries);

% Keeping the L in the L*a*b space.
luminanceTimeSeries = squeeze(luminanceTimeSeries(:,:,1,:));
% Setting up the time vector is done here.
stimulus_times = params.time_cell;

t = params.t;

% here find the corresponding indices (this does the upsampling)
stim_indices =zeros(1, length(stimulus_times));
for j=1:length(stimulus_times),
    % here to find the indices    
    
    inds = find(abs(t-stimulus_times{j})<params.dt);    
    diffs = params.t(inds) - stimulus_times{j};
    
    % this here ensures that the assigned value happens at most dt seconds
    % after the stimulus time.
    
    indices = find(diffs >= 0);
    stim_indices(j) = inds(indices(1));
end

% Once we have the times, the next stage is to generate the reduced space
% for the retinal map to reflect what is happening at this stage, where
% regions in the visual field converge onto co-ordinates on the retina.
% 
% This retinalTemplate map has to be specified, and it contains fields
% eccentricity and polar angle.

mappingTransformation = polarMappingCoordinateTransfer(retinalTemplate.eccentricity,retinalTemplate.polarAngle,rmat,thmat);

[nx,ny,nt] = size(luminanceTimeSeries);
luminanceResponse_cell = mat2cell_vs(reshape(luminanceTimeSeries(:),nx*ny,nt));
luminanceResponse_cell = cellfun(@(x) (mappingTransformation.'*x), luminanceResponse_cell, 'UniformOutput', false);

luminanceTimeSeries = squeeze(cell2mat_vs(luminanceResponse_cell));

[imInd,tind] = meshgrid(stim_indices,1:size(luminanceTimeSeries,1));
retinal_luminance = sparse(tind,imInd,luminanceTimeSeries(:),size(luminanceTimeSeries,1),length(t));

% After this then apply a mean field-retinal response for this. Some kind
% of neural firing model for this.
% right now set to something simple - a step function.



% now set up the luminance as a step in the time series
lum_tser = retinal_luminance;

for n=1:length(stim_indices)
    if(n<length(stim_indices))
        lum_tser(:,stim_indices(n):stim_indices(n+1)) = repmat(retinal_luminance(:,stim_indices(n)),1,length(stim_indices(n):stim_indices(n+1)));
    else
        lum_tser(:,stim_indices(n):end) = repmat(retinal_luminance(:,stim_indices(n)),1,length(t) - stim_indices(n)+1);
    end
end
% next step, set up the difference in contrast with steps

delta_L = retinal_luminance;
for n=2:length(stim_indices)
    delta_L(:,stim_indices(n)) = abs(retinal_luminance(:,stim_indices(n)) - retinal_luminance(:,stim_indices(n-1)))./(retinal_luminance(:,stim_indices(n-1)) + eps);
end
delta_L(:,stim_indices(1)) = 0;


thresh = 0.5;
dist_b = 0.5;
sigmoid_firing_rate = @(x) 1./(1 + exp(-(x - thresh)/dist_b));


% First calculate the response Kernel:
responseKernel = calculateResponseKernel(params);
% now calculate the neural response
% for ni = 1:size(retinal_response,1),
%     retinal_response(ni,:) =  params.dt*conv(squeeze(full(retinal_response(ni,:))),responseKernel,'same');
% end
% % Making sparse to reduce memory.
% retinal_response = sparse(retinal_response);

% Here do the following:
%
% - Change Delta E to Neural firing rate
% 
% or from membrane V to Q?
% get mV ?
% 
% 
% Then after this we are all good. 
% We then have firing rates
%



retinal_response = delta_L;

end


