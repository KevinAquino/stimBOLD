% here make the experimental conditions placed on the y value



oldBOLD = boldResponse;
boldAvg = reshape(boldResponse,numel(boldResponse(:,:,1)),length(t));


% not the way to do it, this does a running average. A better way would be
% to low pass filter then downsample!

for nc=1:size(boldAvg,1),
    boldFiltered = filter(filterAVG,1,boldAvg(nc,:));
end

clear boldAvg;


boldResponse = boldFiltered;

told = 