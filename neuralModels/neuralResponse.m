function [neuralActivity,neuralInputs,params,msh] = neuralResponse(msh,v1RetinalOutputs,retinotopicTemplate,params)
% NeuralResponse.m
% Kevin Aquino 2014
%
% Here we have to take the cortical mapping of the stimulus, then determine
% the neural response at this point. Right now it is one for one.
% NOTES
% Kevin Aquino, 2014.
% SHAO Wenbin, 16-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 18-May-2014 Old code is disabled for now.
% Ver. 11-Jul-2014 KMA: Added code to translate contrast function into a
%                       neural response to now have a neural response.
% Ver. 14-Jul-2014 KMA: Made the default value for the calculation of the
%                       contrast response function, will add options to
%                       change this later when the neural GUI is more
%                       developed.
% Ver. 30-Oct-2014 Add error check
% Ver. 21-Nov-2014 KMA: Completely changed this function. Updated to reflect
%                       physiology

% For now use default method to calculate the neural response, change later
% when this GUI becomes more complex.

% This function captures key processing features. Here is how it goes:
% Workflow.
% V1 -> V2 v/d
% ============
% v1RetinalOutputs -> Calculate V1 neural response -> receptive field onto
%                                                     V2
%                                                  = v2Dorsal_v1Outputs
%                                                  = v2Vental_v1Outputs
% This takes the retinal outputs projected onto V1 and uses them to
% calculate the neural response on V1. From this the projection onto V2
% ventral and dorsal streams are done by using the receptive field sizes   
% from ec,pol space.
% 
% After this is done, the inputs onto a region are stored in "neuralInputs"
% and the outputs, i.e. the neural firing are stored in "neuralActivity".
% These are saved this way because the neural drive, i.e. the drive to the
% hemodynamic model is possibly a mixture of the two responses -> currently
% not clear however, this is done so that they may be added onto later.
% Then do the rest for....
%
% V1 -> V3 v/d
%
%
%
%


% V1 Neural Processing
% =================================================================
% First calculate the cortical Neural response:
%
% Currently calculated as a convolution, can be improved upon in the future
%
% intialize, and reduce the size of the retinalReponse
v1Inputs = v1RetinalOutputs(:,retinotopicTemplate.visualAreas.v1);
v1NeuralResponse = zeros(size(v1Inputs));
% First calculate the response Kernel:
responseKernel = calculateResponseKernel(params);
% now calculate the neural response
for ni = 1:size(v1NeuralResponse,2),
    v1NeuralResponse(:,ni) =  params.dt*conv(squeeze(full(v1Inputs(:,ni))),responseKernel,'same');
end
% Making sparse to reduce memory.
v1NeuralResponse = sparse(v1NeuralResponse);


% now have to convert it to flattened map and pass that around - i.e. have
% the V1 as a flattened map - make it as a flattened map first

indsV1 = retinotopicTemplate.visualAreas.v1;
tind = 1:length(params.t);
[ii,tt] = meshgrid([indsV1.'],tind);
totalResponse = [v1NeuralResponse];

v1FlatNeuralResponse = sparse(tt(:),ii(:),totalResponse(:),length(params.t),size(msh.originalvertices,2));

v1FlatNeuralResponse = v1FlatNeuralResponse(:,msh.submesh.fullMeshIndices);


% V2 Neural Processing
% ================================================================
% The first step of this is to find out the inputs to V2, this is done by
% taking the responses as the receptive fields from V1.
%
receptiveFieldParams.radius = 2;
receptiveFieldParams.project = 'v2';
receptiveFieldParams.radiiStep = 0.5;

gainV1V2 = 1;

[receptiveField] = computeReceptiveFieldFromV1(retinotopicTemplate,msh,receptiveFieldParams);
v2NeuralInputs = gainV1V2*computeNeuralInputs(v1FlatNeuralResponse,receptiveField,msh);
v2NeuralResponse = v2NeuralInputs;


receptiveFieldParams.radius = 4;
receptiveFieldParams.project = 'v3';
receptiveFieldParams.radiiStep = 0.5;

gainV1V3 = 1;

[receptiveField] = computeReceptiveFieldFromV1(retinotopicTemplate,msh,receptiveFieldParams);
v3NeuralInputs = gainV1V3*computeNeuralInputs(v1FlatNeuralResponse,receptiveField,msh);
v3NeuralResponse = v3NeuralInputs;

% ecV1 = retinotopicTemplate.eccentricityAreas.v1;
% polV1 = 180/pi*(retinotopicTemplate.polarAreas.v1 + pi/2);
% 
% ecV2 = retinotopicTemplate.eccentricityAreas.v2;
% polV2 = 180/pi*(retinotopicTemplate.polarAreas.v2 + pi/2);
% 
% receptiveFieldParams.slope = params.prf_slope_V2;
% receptiveFieldParams.offset = params.prf_offset_V2;
% 
% [receptiveFieldV1toV2] = computeReceptiveField(ecV1,polV1,ecV2,polV2,receptiveFieldParams);
% 
% 
% v2NeuralInputs = computeNeuralInputs(v1NeuralResponse,receptiveFieldV1toV2);


%
%
%
% V2 Ventral <= 90 Degrees Processing
% ================================================================
% 
% First off calculate the receptive field processing from V1
% This step requires one to upsample
%  
% V2 Dorsal > 90 Degrees
%
% For now not implemented processing all done temporally
% 
% v2NeuralResponse = zeros(size(v2NeuralInputs));
% responseKernel = calculateResponseKernel(params);
% % now calculate the neural response
% for ni = 1:size(v2NeuralResponse,2),
%     v2NeuralResponse(:,ni) =  conv(squeeze(full(v2NeuralInputs(:,ni))),responseKernel,'same');
% end
% % Making sparse to reduce memory.
% v2NeuralResponse = sparse(v2NeuralResponse);



% V3 Neural Processing
% ================================================================
% The first step of this is to find out the inputs to V3, this is done by
% taking the responses as the receptive fields from V1.
%
% 
% ecV3 = retinotopicTemplate.eccentricityAreas.v3;
% polV3 = 180/pi*(retinotopicTemplate.polarAreas.v3 + pi/2);
% 
% receptiveFieldParams.slope = params.prf_slope_V3;
% receptiveFieldParams.offset = params.prf_offset_V3;
% 
% [receptiveFieldV1toV3] = computeReceptiveField(ecV1,polV1,ecV3,polV3,receptiveFieldParams);
% v3NeuralInputs = computeNeuralInputs(v1NeuralResponse,receptiveFieldV1toV3);
% 
% % 
% % V3 Ventral < 
% %
% % V3 Dorsal
% v3NeuralResponse = zeros(size(v3NeuralInputs));
% responseKernel = calculateResponseKernel(params);
% % now calculate the neural response
% for ni = 1:size(v3NeuralResponse,2),
%     v3NeuralResponse(:,ni) =  conv(squeeze(full(v3NeuralInputs(:,ni))),responseKernel,'same');
% end
% % Making sparse to reduce memory.
% v3NeuralResponse = sparse(v3NeuralResponse);

%
%
%
% Outputs: Have to create a sparse Matrix

indsV1 = retinotopicTemplate.visualAreas.v1;
indsV2 = retinotopicTemplate.visualAreas.v2;
indsV3 = retinotopicTemplate.visualAreas.v3;
tind = 1:length(params.t);
[ii,tt] = meshgrid([indsV1.' indsV2.' indsV3.'],tind);
totalResponse = [v1NeuralResponse.';v2NeuralResponse.';v3NeuralResponse.'].';
totalInputs = [v1Inputs.'; v2NeuralInputs.'; v3NeuralInputs.'].';

% here are the outputs
neuralActivity = sparse(tt(:),ii(:),totalResponse(:),length(params.t),size(msh.originalvertices,2));
neuralInputs = sparse(tt(:),ii(:),totalInputs(:),length(params.t),size(msh.originalvertices,2));
% 
% msh.receptiveFieldV1toV2 = receptiveFieldV1toV2;
% msh.receptiveFieldV1toV3 = receptiveFieldV1toV3;
