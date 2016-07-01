% For now load a specific paradigm to see how it looks like

% load ~/Dropbox/Movie_simulation/RingMask.mat
load ~/Dropbox/Movie_simulation/TwoRings.mat; maskImgs = maskImg;


% load ~/Dropbox/Movie_simulation/maskTwoCircles.mat
% load ~/Dropbox/Movie_simulation/WedgeMask.mat

% load ~/Dropbox/Movie_simulation/Wedge_new.mat;

%

% r0 = 0.5;

MAX_SCREEN_EC = 5; % i.e. the maximum eccentricity that the screen is, this will be used to normalize it all.

[nx ny ni] = size(maskImgs);

% normalization factor to normalize each radial readout from this script 
maxRad = floor(nx/2);
normFactor = MAX_SCREEN_EC/maxRad;

xaxis = linspace(-maxRad,maxRad,nx)*normFactor;
yaxis = linspace(-maxRad,maxRad,nx)*normFactor;

% background saved for later purposes
[ybg xbg] = meshgrid(yaxis,xaxis(xaxis>0));
[thbg rbg] = cart2pol(xbg,ybg);

suitableRange = find(rbg <= MAX_SCREEN_EC);
thbg = thbg(suitableRange);
rbg = rbg(suitableRange);


for k=1:size(maskImgs,3);
    
    stim_image = maskImgs(:,:,k);
        
    % find the mask where it equals to 1
    
    [yi xi] = find(stim_image == 1);        
        
    xvals = xaxis(xi);  %transform onto the speficied grid;
    yvals = yaxis(yi);
    
    % right now we are only dealing with the left hemisphere, hence elimate
    % all images in the left visual hemifield        

    leftIndices = find(xvals>0);
    
    xvals = xvals(leftIndices);
    yvals = yvals(leftIndices);
    
    
    [thVF rVF] = cart2pol(xvals,yvals);            
       
    visualField =  [rVF(:); thVF(:)];
    
%     
%     % this here is to make sure that we have something to feed into the
%     % model, otherwise make it empty
%     if(isempty(visualField))
%         
%     else    
%         [V1cartx V1carty V2cartx V2carty V3cartx V3carty] = retinotopicModel(visualField,0);
%     end;
            
    thmat{k} = thVF(:);
    rmat{k} = rVF(:);
    
    % this has to be 
    suitableRange = find(rmat{k} <= MAX_SCREEN_EC);
    
%     
%     
%     
    rmat{k} = rmat{k}(suitableRange);
%     
    thmat{k} = thmat{k}(suitableRange);
    
end;


grid=makeVisualGrid(0.01,5.5,10,3,200);

% grid=makeVisualGrid(0.01,36,10,3,200);


if (plotting == 1)
    figure(1);
    subplot(2,1,1);
    polar(grid(2,:),grid(1,:),'r.');
    hold on;
    
    for k=size(rmat,2):-1:1;
        h = polar(thmat{k},rmat{k},'*');
        set(h,'Color',[0 1-k/size(rmat,2) k/size(rmat,2)]);
    end;
    set(gca,'fontSize',18);
    title('Visual Field','fontSize',18);
end



t = linspace(t_start,t_end,num_time);


for ns=1:num_stimuli
    time_indices{ns} = find((t>(t_0 + (isi_time + stim_time)*(ns-1) )).*(t<(t_0 + stim_time + (isi_time + stim_time)*(ns-1)) ));
    
%     time_indices(ns,:) = indices;
end;