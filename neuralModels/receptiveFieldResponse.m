function [] = function receptiveFieldResponse
% intialize setup:
ec1 = retinotopicTemplate.eccentricityAreas.v1;
pol1 = rad2deg(retinotopicTemplate.polarAreas.v1 + pi/2);


ec2 = retinotopicTemplate.eccentricityAreas.v2;
pol2 = rad2deg(retinotopicTemplate.polarAreas.v2 + pi/2);


% Better way is to actually incorporate population receptive field size
clear receptiveField
clear sampledOrig
receptiveFieldRadius = @(x) x/6 + 0.1;
tic
for j=1:length(ec2),    
%     allDist = sqrt((pol2 - pol2(j)).^2 + (ec2 - ec2(j)).^2);
    
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
    
    receptiveField{j}(:,1) = recpRadius*cos(th) + ec2(j);
    receptiveField{j}(:,2) = recpRadius*sin(th) + pol2(j);
        
    sampledOrig{j} = find(inpolygon(ec1,pol1,receptiveField{j}(:,1),receptiveField{j}(:,2)));
end
toc


%% Checking out the receptive field sizes


zeroPts = find(testEC==0);

figure;plot(ec2(zeroPts),pol2(zeroPts),'*')
hold on
for k=1:length(zeroPts),
    line(receptiveField{zeroPts(k)}(:,1),receptiveField{zeroPts(k)}(:,2),'Color','r');
end

%%

% Check how long it takes to interpolate

