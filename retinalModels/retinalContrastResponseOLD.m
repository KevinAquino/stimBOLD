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


% flag here to pass on that the images are already in Lab space.
[method_contrast, params]= get_para(params, 'method_contrast', 'de94');
contrastParams.method_contrast =method_contrast;

% Generate the contrast response in time over the L*a*b channels
contrast_cell = cellfun(@(x, y) im_contrast_gen(x, y, contrastParams), ...
    retinal_blur(1:end-1), retinal_blur(2:end), 'UniformOutput', false);

% Initialize the contrast matrix


contrast_matrix =[zeros(size(contrast_cell{1})), contrast_cell];
contrast_matrix =cell2mat_vs(contrast_matrix);

% The luminance response is the first channel in L*a*b space.
luminanceResponse = contrast_matrix;

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

[nx,ny,nt] = size(luminanceResponse);
luminanceResponse_cell = mat2cell_vs(reshape(luminanceResponse(:),nx*ny,nt));
luminanceResponse_cell = cellfun(@(x) (mappingTransformation.'*x), luminanceResponse_cell, 'UniformOutput', false);

luminanceResponse = squeeze(cell2mat_vs(luminanceResponse_cell));

[imInd,tind] = meshgrid(stim_indices,1:size(luminanceResponse,1));
retinal_response = sparse(tind,imInd,luminanceResponse(:),size(luminanceResponse,1),length(t));

% After this then apply a mean field-retinal response for this. Some kind
% of neural firing model for this.
% right now set to something simple - a step function.



% First calculate the response Kernel:
responseKernel = calculateResponseKernel(params);
% now calculate the neural response
for ni = 1:size(retinal_response,1),
    retinal_response(ni,:) =  params.dt*conv(squeeze(full(retinal_response(ni,:))),responseKernel,'same');
end
% Making sparse to reduce memory.
retinal_response = sparse(retinal_response);


end


