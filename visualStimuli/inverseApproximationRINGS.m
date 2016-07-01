% inverse mapping (well approximate using the log-polar transform)

rmatEnds = [0 0.5; 0.5 1; 1 2; 2 4; 4 8; 8 16; 16 32]/32*5.5;




% r0 = 0.5;
for k=1:size(rmatEnds,1);
    

    
    thmatR = linspace(-pi/2,pi/2,20);
    
%     rmatR = (k-1)*0.5 + linspace(r0,r0+1,2);

    rmatR = linspace(rmatEnds(k,1),rmatEnds(k,2),4);
    [rVF thVF] = meshgrid(rmatR,thmatR);
    visualField =  [rVF(:); thVF(:)];
    
    
    [V1cartx V1carty V2cartx V2carty V3cartx V3carty] = retinotopicModel(visualField,0);
    
    thmat(:,k) = 0*pi/4 + thVF(:);
    rmat(:,k) = rVF(:);
end;


grid=makeVisualGrid(0.01,5.5,10,3,200);

% grid=makeVisualGrid(0.01,36,10,3,200);


if (plotting == 1)
    figure(1);
    subplot(2,1,1);
    polar(grid(2,:),grid(1,:),'r.');
    hold on;
    
    for k=size(rmat,2):-1:1;
        h = polar(thmat(:,k),rmat(:,k),'*');
        set(h,'Color',[0 1-k/size(rmat,2) k/size(rmat,2)]);
    end;
    set(gca,'fontSize',18);
    title('Visual Field','fontSize',18);
end



t = linspace(t_start,t_end,num_time);

for ns=1:num_stimuli
    time_indices(ns,:) = find((t>(t_0 + (isi_time + stim_time)*(ns-1) )).*(t<(t_0 + stim_time + (isi_time + stim_time)*(ns-1)) ));
end;