function stimMap = imageIndicesToVertices(eccentricity_template,polar_angle_template,v1v2v3Vertices,rmat,thmat)
% imageIndicesToVertices
% Kevin Aquino 2014
%
% Function to determine the mapping between image space and cortical
% vertices, the result is a sparse matrix that you multiply an image to
% transform the image into cortical space.

LARGE_VALUE = 1000; % flag to know which points not to choose.
THRESH = 0.1;         % Threshold flag, smallest distance to valid point.


polMap = pi/2*(polar_angle_template(v1v2v3Vertices));
ecMap = (eccentricity_template(v1v2v3Vertices));

% now will have to find the corresponding points.



vertexInd = zeros(length(rmat),2);
vertexInd((rmat==-1),:) = LARGE_VALUE;
hemifieldIndices = find(rmat~=-1);  %flag here to only deal with points in the appropriate hemifield.

for npIndex = 1:length(hemifieldIndices) 
    np = hemifieldIndices(npIndex);
    allDist = sqrt((polMap - thmat(np)).^2 + (ecMap - rmat(np)).^2);
    [val,ind] = min(allDist);
    vertexInd(np,:) = [ind,val];
end


% 
% for vertex that is mapped, find all the corresponding data points on the
% visual field map.

indexValid = find(vertexInd(:,2)<THRESH);

imageToCortexIndices = vertexInd(indexValid,1);
closenessToIndex = vertexInd(indexValid,2);


% now that we have a mapping and thresholded to only include those that can
% be used we have to now average out nearby indices, since the mapping
% between visual image and cortex is a many-to-one-mapping. 

% this takes connection matrix to have the closest points are mapped to the
% cortex, and we have a measure of how close they are. Now we will have to 

conmat = sparse(indexValid,imageToCortexIndices,closenessToIndex,length(rmat),length(v1v2v3Vertices));
maxValueMatrix = max(conmat);
nonZeroValues = find(maxValueMatrix>0);


for nci=nonZeroValues,        
    weights = conmat(conmat(:,nci)~=0,nci);
    weights = (weights/maxValueMatrix(nci));
    conmat(conmat(:,nci)~=0,nci) = weights/sum(weights); % sparse allocation in this instance is fast, disregard warning      
end

% then get every point that corresponds to it, and generate a mapping -
% derive a sum for each one, because the visual field to cortex map is a
% many to one map. 

% cortex = retinalImage*mapping;

stimMap = conmat;
