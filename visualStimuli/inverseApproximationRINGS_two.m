% inverse mapping (well approximate using the log-polar transform)

r0 = 0.25;
for k=1:2;
    
    
    
    thmatR = linspace(-pi/2,pi/2,50);
    rmatR = (k-1)*spacing_ring + linspace(r0,r0+0.05,10);

    
    [rVF thVF] = meshgrid(rmatR,thmatR);
    visualField =  [rVF(:); thVF(:)];
    
    
    [V1cartx V1carty V2cartx V2carty V3cartx V3carty] = retinotopicModel(visualField,0);
    
    thmat(:,k) = 0*pi/4 + thVF(:);
    rmat(:,k) = rVF(:);
end;


grid=makeVisualGrid(0.01,5.5,10,3,200);

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


% now assing the timing to each of these stimuli


t = linspace(t_start,t_end,num_time);
num_stimuli = size(rmat,2);          % number of trials

for ns=1:num_stimuli
    time_indices(ns,:) = find((t>(t_0 )).*(t<(t_0 + (stim_time) ) ));
end;

