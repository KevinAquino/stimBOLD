function [zeta] = calculateNeuralDrive(msh,neuralActivity,neuralInputs,params)
% calculateNeuralDrive.m
% Kevin Aquino 2014
%                  24-Nov-2014: Updated
%
% this function calculates the neural drive zeta that is used as an input
% to to the hemodynamic model.

switch params.neuralVascularModel
    case 'inputModel'
        zeta = neuralInputs(:,msh.submesh.mappedInds);
    case 'spikingModel'
        zeta = neuralActivity(:,msh.submesh.mappedInds);
    case 'mixedModel'
        zeta = neuralInputs(:,msh.submesh.mappedInds) + neuralActivity(:,msh.submesh.mappedInds);
end

