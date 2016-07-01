% vis_gui_intialize.m
%
% M-VIBE: 2014 
% Author: Kevin Aquino 
%
% This here is the skeleton for the visualization gui, have to add buttons
% to the playback_panel. 

vis_Handle = figure(10);
clf;

set(gcf,'Color','white');
nn = 1;ind = 1;
meanZ = mean(zeta,2); 
maxZ = max(meanZ); 
meanB = mean(BOLD,2); 
maxB = max(meanB);
minB = min(meanB);
maxBV = max(BOLD(:));
tall = cell2mat(params.time_indices);
axis off;
fnV = struct;
bV = struct;

% Parameters to start it all off.
fnV.skipInitialization = 0;
bV.skipInitialization = 0;

% Add the bottom panel
playback_panel = uipanel('Parent',vis_Handle,'Title','Playback and Exporting','Position',[.01 0.01 .98 .1]);
% set up the figure
subplot(5,5,[2,7])
textH = text(0.1,0.5,['t = ' num2str(params.t(1)) 's'],'fontSize',20);axis off;

% First initalization, i.e. loading the surface
zetaTP = zeta(nn,:);
BOLDTP = BOLD(nn,:);
tp = params.t(nn);
visualization_time_point; % will have to do this whenever you change 
                          % surfaces with the dropdown menu as a callback, 
                          % preferably using the time index (nn) that is 
                          % currently displayed.


%% Will have to make this part of the code part of the call back to stop/play
figure(10);
for nn=1:5:length(params.t),    
    tp = params.t(nn);    
    fnV.skipInitialization = 1;
    bV.skipInitialization = 1;
    zetaTP = zeta(nn,:);
    BOLDTP = BOLD(nn,:);
    visualization_time_point;
    
end;



