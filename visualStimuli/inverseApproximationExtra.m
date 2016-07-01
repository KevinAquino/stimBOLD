% inverse mapping (well approximate using the log-polar transform)




for k=1:10;
    
%     x = linspace(1,3,5)+k*d_s;
%     x = linspace(1,3,5)+k*1;
%     y = linspace(-2,2,5);
    
    amat = [-pi:0.5:pi];
    x = 20 + 10*cos(amat);
    y = 5*sin(amat);
    
%     [xx yy] = meshgrid(x,y);        
    [TH,R] = cart2pol(x,y);
    
%     TH1 = TH + pi/8;
%     
%     TH2 = TH - pi/8;
%     
    
%     TH = [TH1;TH2];
%     R = [R;R];
    
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
