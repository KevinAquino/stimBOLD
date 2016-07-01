params = precomputed_data.params;

t = params.t;
hrf = boyntonHIRF(t, 3, 1.08, 1); %default values
% hrf = boyntonHIRF(t, 3, 1.08, 2); %default values
% zt = zeros(size(t));
% 
% 
% zt(params.time_cell{2}) = 1;
% zt(1) = 0;
STIM_TIME = 1.5;
zt = (t>=0).*(t<=STIM_TIME);
convhrf = conv(zt,hrf);

%%
kernel = convhrf(1:length(params.t));
NoWedges = 16;
totalCoverage = 180;


clear polVal;

for nv = 1:size(BOLD,2),
    [C,LAGS] = xcorr(BOLD(:,nv),kernel);
    lagval = mean(LAGS(C==max(C)))*params.dt;
    
    polVal(nv) = lagval/(16*STIM_TIME)*360;
end


%%


figParams = struct;
figParams.noFig = 10;
figParams.figParentAxis = [];
figParams.range = [0 180];
figParams.colorMap = 'hsv';

display_sim_movie_flat(polVal-min(polVal),precomputed_data.msh,figParams);

%%

figParams = struct;
figParams.noFig = 10;
figParams.figParentAxis = [];
figParams.range = 5e-3*[-0.1 1];

display_sim_movie_flat(precomputed_data.BOLD(300,:),precomputed_data.msh,figParams);

%%

