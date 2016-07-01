function [receptiveField] = computeReceptiveFieldFromV1(retinotopicTemplate,msh,receptiveFieldParams)

% intialize setup:

% Better way is to actually incorporate population receptive field size
% receptiveFieldRadius = @(x) x*receptiveFieldParams.slope + receptiveFieldParams.offset;

switch receptiveFieldParams.project
    case 'v2'
        ec2 = retinotopicTemplate.eccentricityAreas.v2;
        pol2 = retinotopicTemplate.polarAreas.v2;
    case 'v3'
        ec2 = retinotopicTemplate.eccentricityAreas.v3;
        pol2 = retinotopicTemplate.polarAreas.v3;
end

[nold,v1OnFlat] = find(msh.submesh.fullToSub(retinotopicTemplate.visualAreas.v1,:));

ec1 = retinotopicTemplate.eccentricityAreas.v1(nold);
pol1 = retinotopicTemplate.polarAreas.v1(nold);

x = msh.flatCoord(v1OnFlat,1);
y = msh.flatCoord(v1OnFlat,2);

% First set up the interpolants
FX = TriScatteredInterp();
FX.X = [ec1,pol1];
FX.V = x;

FY = TriScatteredInterp();
FY.X = [ec1,pol1];
FY.V = y;

% Get the V1 border on the flattened mesh

indsPerim = retinotopicTemplate.visualAreaBorders.v1;
for j=1:length(indsPerim),
    [nold,pt] = find(msh.submesh.fullToSub(indsPerim(j),:));
    v1Border(j) = pt;
end



meanDistFlat = meanEdgeDistance(msh.submesh.triangles+1,msh.flatCoord.');
meanDistSurface = meanEdgeDistance(msh.submesh.triangles+1,msh.submesh.vertices);

% conversion Factor
ratio_surfaceToflat = meanDistFlat/meanDistSurface;

for j=1:length(ec2),
    % first find the appropriate point on V1, do this by interpolation as
    % set up above.

    xV1 = FX(ec2(j),pol2(j));
    yV1 = FY(ec2(j),pol2(j));
    
    % Get the radius from the parameter field
    
    receptiveFieldRadius = receptiveFieldParams.radius*ratio_surfaceToflat;
    
    % now get the radii will be used to calculate the receptive field in
    % concentric circles
    
    radii = 0:receptiveFieldParams.radiiStep*ratio_surfaceToflat:receptiveFieldRadius;
    
    % Here is just how big the radii are     
    if(receptiveFieldRadius < 4*ratio_surfaceToflat)
        npoints = 10;
    else
        npoints = 30;
    end
    
    th = linspace(0,2*pi,npoints);
    
    xSampled = [];
    ySampled = [];
    for r_n = radii,
        xSampled = [xSampled,r_n*cos(th) + xV1];
        ySampled = [ySampled,r_n*sin(th) + yV1];
    end
    % WRONG ^ have to calculate mean distance between nodes - to get a
    % better mapping. then times it by that ratio.
    
    
    % now have to test whether or not these points are still in V1
    
    inPoints = inpolygon(xSampled,ySampled, msh.flatCoord(v1Border,1),msh.flatCoord(v1Border,2));
    receptiveFieldRegion{j} = [xSampled(inPoints);ySampled(inPoints)];
%    receptiveFieldRegion{j} = [xSampled;ySampled];
    

    
%     receptiveFieldRegion{j}(:,1) = recpRadius*cos(th) + ec2(j);
%     receptiveFieldRegion{j}(:,2) = recpRadius*sin(th) + pol2(j);
%         
%     sampledPoints{j} = find(inpolygon(ec1,pol1,receptiveFieldRegion{j}(:,1),receptiveFieldRegion{j}(:,2)));
    
    % now calculate the type of kernel, need to include this here:
    receptiveFieldCenter(j,:) = [xV1,yV1];


end



receptiveField.receptiveFieldRegion = receptiveFieldRegion;
receptiveField.ratio_surfaceToflat = ratio_surfaceToflat;

    
% Put this in earlier with different parameters i.e. dog or something
% like that.
Kernel = @(pvec,cent,sigma) exp(-((pvec(1,:)-cent(1)).^2 + (pvec(2,:)-cent(2)).^2)/sigma.^2);
KernelType = 'Gaussian';

receptiveField.Kernel = Kernel;
receptiveField.KernelType = KernelType;
receptiveField.receptiveFieldCenter = receptiveFieldCenter;
receptiveField.receptiveFieldParams = receptiveFieldParams;


% 
% 
% % Next stage: Go through all the points in the receptiveField and find
% % appropriate weights, also deal with the points that have no corresponding
% % mapping.
% 
% pointsInVisualField = cellfun(@(x) numel(x), sampledPoints);
% 
% % We first deal with the points that have at least one point
% nonZeroElements = find(pointsInVisualField>0);
% 
% weights = cell(size(pointsInVisualField));
% 
% for elm = nonZeroElements,
%     weights{elm} = 1./pointsInVisualField(elm)*ones(pointsInVisualField(elm),1);
% end
% 
% % Now deal with the points that have zero points, i.e. no corresponding
% % point in the lower visual area.
% zeroElements = find(pointsInVisualField == 0);
% 
% % Find the nearest point:
% for elm=zeroElements;    
%     allDist = sqrt((pol1(nonZeroElements) - pol2(elm)).^2 + (ec1(nonZeroElements) - ec2(elm)).^2);
%     [val,ind] = min(allDist);            
%     sampledPoints{elm} = nonZeroElements(ind);
%     weights{elm} = 1;
% end
% 
% receptiveField.weights = weights;
% receptiveField.sampledPoints = sampledPoints;
% receptiveField.receptiveFieldRegion = receptiveFieldRegion;
% 
% end

% % Checking out the receptive field sizes
% 
% 
% zeroPts = find(testEC==0);
% 
% figure;plot(ec2(zeroPts),pol2(zeroPts),'*')
% hold on
% for k=1:length(zeroPts),
%     line(receptiveField{zeroPts(k)}(:,1),receptiveField{zeroPts(k)}(:,2),'Color','r');
% end

%

% Check how long it takes to interpolate

