function polVal = create_phase_map(params,BOLD,msh,STIM_TIME,stimuli,totalCoverage)


t = params.t;
hrf = boyntonHIRF(t, 3, 1.08, 1); %default values

zt = (t>=0).*(t<=STIM_TIME);
convhrf = conv(zt,hrf);


kernel = convhrf(1:length(params.t));


clear polVal;

for nv = 1:size(BOLD,2),
    [C,LAGS] = xcorr(BOLD(:,nv),kernel);
    lagval = mean(LAGS(C==max(C)))*params.dt;
    
    polVal(nv) = lagval/(stimuli*STIM_TIME)*totalCoverage;
end

polVal = polVal - min(polVal);


% default plotting


figParams = struct;
figParams.noFig = 1;
figParams.figParentAxis = [];
figParams.range = [0 180];
figParams.colorMap = 'hsv';

display_sim_movie_flat(polVal,msh,figParams);




end