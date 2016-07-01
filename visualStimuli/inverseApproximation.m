% inverse mapping (well approximate using the log-polar transform)




for k=1:num_stimuli;
    
    x = linspace(1,3,5)+k*d_s;
%     x = linspace(1,3,5)+k*1;
    y = linspace(-2,2,5);
    
    [xx yy] = meshgrid(x,y);        
    [TH,R] = cart2pol(xx,yy);
        
    % here using the complex formalism:
    a=0.75;             % Foveal pole
    b=90;               % Peripheral pole
    K=18;               % scaling parameter
    
    
    w = exp(1i*reshape(TH,numel(TH),1)).*reshape(R,numel(R),1);
    z = exp(w/K) - a;
    thVF = angle(z);rVF = abs(z);
    visualField =  [rVF.'; thVF.'];
    
    
    [V1cartx V1carty V2cartx V2carty V3cartx V3carty] = retinotopicModel(visualField,0);
    
    thmat(:,k) = 0*pi/4 + thVF;
    rmat(:,k) = rVF;
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

t = linspace(t_start,t_end,num_time);

for ns=1:num_stimuli
    time_indices(ns,:) = find((t>(t_0 + (isi_time + stim_time)*(ns-1) )).*(t<(t_0 + stim_time + (isi_time + stim_time)*(ns-1)) ));
end;