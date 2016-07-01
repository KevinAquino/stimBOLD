function stimMap = maskImagesToVertices(eccentricity_template,polar_angle_template,v1v2v3Vertices,rmat,thmat)

polMap = pi/2*(polar_angle_template(v1v2v3Vertices));
% ecMap = 20*(eccentricity_template(V1vertices));
ecMap = (eccentricity_template(v1v2v3Vertices));

% now will have to find the corresponding points.


for k=1:length(rmat)
    vertexInd = zeros(length(rmat{k}),1);
    for np=1:length(rmat{k}),
        allDist = sqrt((polMap - thmat{k}(np)).^2 + (ecMap - rmat{k}(np)).^2);
        [val,ind] = min(allDist);
        vertexInd(np) = ind;
    end
    stimMap{k} = unique(vertexInd);
end