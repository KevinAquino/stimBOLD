function [receptiveField] = computeReceptiveField(ec1,pol1,ec2,pol2,receptiveFieldParams)
% intialize setup:

% Better way is to actually incorporate population receptive field size
receptiveFieldRadius = @(x) x*receptiveFieldParams.slope + receptiveFieldParams.offset;

for j=1:length(ec2),        
    % make the receptive field as a circle (first approximation), number of
    % points depends on the radius of eccentricity the larger it is, the
    % more points there are.
    recpRadius = receptiveFieldRadius(ec2(j));
    if(ec2(j) < 20)
        npoints = 10;
    else
        npoints = 30;
    end
    
    th = linspace(0,2*pi,npoints);
    
    receptiveFieldRegion{j}(:,1) = recpRadius*cos(th) + ec2(j);
    receptiveFieldRegion{j}(:,2) = recpRadius*sin(th) + pol2(j);
        
    sampledPoints{j} = find(inpolygon(ec1,pol1,receptiveFieldRegion{j}(:,1),receptiveFieldRegion{j}(:,2)));
end


% Next stage: Go through all the points in the receptiveField and find
% appropriate weights, also deal with the points that have no corresponding
% mapping.

pointsInVisualField = cellfun(@(x) numel(x), sampledPoints);

% We first deal with the points that have at least one point
nonZeroElements = find(pointsInVisualField>0);

weights = cell(size(pointsInVisualField));

for elm = nonZeroElements,
    weights{elm} = 1./pointsInVisualField(elm)*ones(pointsInVisualField(elm),1);
end

% Now deal with the points that have zero points, i.e. no corresponding
% point in the lower visual area.
zeroElements = find(pointsInVisualField == 0);

% Find the nearest point:
for elm=zeroElements;    
    allDist = sqrt((pol1(nonZeroElements) - pol2(elm)).^2 + (ec1(nonZeroElements) - ec2(elm)).^2);
    [val,ind] = min(allDist);            
    sampledPoints{elm} = nonZeroElements(ind);
    weights{elm} = 1;
end

receptiveField.weights = weights;
receptiveField.sampledPoints = sampledPoints;
receptiveField.receptiveFieldRegion = receptiveFieldRegion;

end

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

