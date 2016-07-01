% neuralInputs.m
% This function takes the receptive field from a higher visual area and
% projects the outputs from the lower visual area onto them. For example
% at a particular point in V2, the inputs are a sum of the fields from V1.
%

function neuralInputs = computeNeuralInputs(neuralResponse,receptiveField,msh)

% this function takes the receptive field and computes the neural
% inputs using the neuralResponse, currently takes the points from
% neural response and averages, in future it might do some processing
% to represent synaptic activity innervating as inputs.
% 
% for j = 1:length(receptiveField.sampledPoints)    
%     neuralInputs(:,j) = (neuralResponse(:,receptiveField.sampledPoints{j}))*receptiveField.weights{j}(:);
% end
% 
% 
% neuralInputs = sparse(neuralInputs);


% now do the following:

% - get the receptive field, interpolate it
% - make neural inputs 

% -> get interpolation for each.
F = TriScatteredInterp();
F.X = msh.flatCoord;

neuralInputs = zeros(size(neuralResponse,1),length(receptiveField.receptiveFieldRegion));
for nt=1:size(neuralResponse,1),
    
    F.V = full(neuralResponse(nt,:)).';
    % if all the points are zero, then there is no point of doing this
    % step.
    if(sum(neuralResponse(nt,:) ~= 0) > 0)        
        for j = 1:length(receptiveField.receptiveFieldRegion)            
%             meanTS = mean(F(receptiveField.receptiveFieldRegion{j}(1,:),receptiveField.receptiveFieldRegion{j}(2,:)));            
%             meanTS = sum(F(receptiveField.receptiveFieldRegion{j}(1,:),receptiveField.receptiveFieldRegion{j}(2,:)));

            clear premean weights
            premean = F(receptiveField.receptiveFieldRegion{j}(1,:),receptiveField.receptiveFieldRegion{j}(2,:));
            
%             weights = receptiveField.Kernel()
            rad = receptiveField.receptiveFieldParams.radius;
            weights = receptiveField.Kernel(receptiveField.receptiveFieldRegion{j},receptiveField.receptiveFieldCenter(j,:),rad*receptiveField.ratio_surfaceToflat);            

            
            if(~isempty(premean))
                meanTS = sum(premean.*weights);
            else
                meanTS = 0;
            end
            

            % catch NaNs
            
            if(isnan(meanTS))
                meanTS = 0;
            end
            
            % This multiples the response with the area of the receptive
            % field, as this is approximation convolution the conv. factor
            % has to be included.
            if(~isempty(receptiveField.receptiveFieldRegion{j}))
                convHullRecpField = convhull(receptiveField.receptiveFieldRegion{j}(1,:),receptiveField.receptiveFieldRegion{j}(2,:));
                areaRField = polyarea(receptiveField.receptiveFieldRegion{j}(1,convHullRecpField),receptiveField.receptiveFieldRegion{j}(2,convHullRecpField));
                areaRField = areaRField/(receptiveField.ratio_surfaceToflat^2);
            end
            
            
%             neuralInputs(nt,j) = meanTS/areaRField;
%             neuralInputs(nt,j) = meanTS*areaRField*1e-3;
            neuralInputs(nt,j) = meanTS/length(weights);
            
            if(isnan(neuralInputs(nt,j)))
                neuralInputs(nt,j) = 0;
            end
            
            % Have to divide by area as well.
        end        
    else        
        neuralInputs(nt,:) = 0;        
    end
    
    
    
end


neuralInputs = sparse(neuralInputs);
end