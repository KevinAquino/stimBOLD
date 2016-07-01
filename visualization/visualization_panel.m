% test visualization

figure(10);

clf
set(gcf,'Color','white');
nn = 1;
ind = 1;
meanZ = mean(zeta,2);
maxZ = max(meanZ);
meanB = mean(BOLD,2);
maxB = max(meanB);
minB = min(meanB);

maxBV = max(BOLD(:));
tall = cell2mat(params.time_indices);
subplot(4,5,[2,7])
textH = text(0.1,0.5,['t = ' num2str(params.t(1)) 's'],'fontSize',20);axis off;
axis off;
fnV = struct;
bV = struct;

for nn=1:20:length(params.t);
    subplot(4,5,[1,6])
    tp = params.t(nn);
%     if(tp>params.time_indices{ind})
%         ind = ind+1;
%     end

    ind = max(find(tp>tall));
    if(isempty(ind))
        ind = 1;
    end;
    
    img = visual_response{ind};
    imshow(img);
    
    set(textH,'String',['t = ' num2str(tp) 's']);

    
    fig = subplot(4,5,[3:5,8 9 10]);
    ax = gca;
    
    fnV.figNo = 10;
    fnV.figView = [60 10];
    fnV.figParentAxis = ax;          
    [msh,fnV] = display_sim_movie_matlab(squeeze(zeta(nn,:)),msh,[0 1],1,0,'original',fnV);
    
    fnV.skipInitialization = 1;
    
    subplot(4,5,[11 12])
    plot(params.t,meanZ);
    line([tp tp],[0 maxZ],'Color','red','lineWidth',3);
    xlim([params.t(1) params.t(end)]);
    ylim([0 maxZ*1.1]);
    ylabel('Neural','fontSize',18);
    set(gca,'fontSize',20);
    

    subplot(4,5,[16 17])
    plot(params.t,meanB);
    line([tp tp],[0 maxZ],'Color','red','lineWidth',3);
    xlim([params.t(1) params.t(end)]);
    ylim([minB*1.1 maxB*1.1]);
    xlabel('time (s)','fontSize',18);
    ylabel('BOLD','fontSize',18);
    set(gca,'fontSize',20);
            
    fig = subplot(4,5,[13:15,18:20]);
    ax2 = gca;    
    
    bV.figNo = 10;
    bV.figView = [60 10];
    bV.figParentAxis = ax2;  
    
    [msh,bV] = display_sim_movie_matlab(squeeze(BOLD(nn,:)),msh,[1.1*minB 1.1*maxBV],1,0,'original',bV);        
     bV.skipInitialization = 1;
    drawnow
end

clear bV fnV