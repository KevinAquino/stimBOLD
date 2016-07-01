%visualizationOfResponses



indx = floor(size(boldResponse,1)/2);
indy = floor(size(boldResponse,2)/2);


figure;
subplot(211)
contourf(dist_x/1e-3,t,squeeze(boldResponse(:,floor(size(boldResponse,2)/2),:)).')
h = title('Y','fontsize',18);set(h,'Interpreter','latex');
h = xlabel('x (mm)','fontSize',18);set(h,'Interpreter','latex');



indx = floor(size(boldResponse,1)/2);
indy = floor(size(boldResponse,2)/2);
subplot(212)
plot(t,squeeze(boldResponse(indx,indy,:)),'r');h = xlabel('t (s)','fontSize',18);set(h,'Interpreter','latex');



times = linspace(10,18,4);
for k=1:length(times)
    [val ind] = min(abs(t-times(k)));
    tRange(k) = ind;
end;

figure;
bmax = max(boldResponse(:));
bmin = min(boldResponse(:));
for p=1:length(tRange)
    subplot(length(tRange),1,p)
    %         contourf(dist_x/1e-3,dist_y/1e-3,squeeze(y(:,:,tRange(p))).');caxis(0.001*[-1 5]);
    contourf(dist_x/1e-3,dist_y/1e-3,squeeze(boldResponse(:,:,tRange(p))).');caxis([bmin bmax]);
    
    %         ,0.001*[-1:0.1:1]);
    h = title(['Y, t= ' num2str(t(tRange(p))) ' s'],'fontsize',18);set(h,'Interpreter','latex');
    h = xlabel('x (mm)','fontSize',18);set(h,'Interpreter','latex');
    h = ylabel('y (mm)','fontSize',18);set(h,'Interpreter','latex');
    %         hold on;h2 = plot(gridV1x+1e3*abs(x_0),gridV1y,'r.');%set(h2,'markerSize',1);
    %         ylim([min(dist_y/1e-3),max(dist_y/1e-3)]);
    set(gca,'fontSize',18);
    axis image;
end



%
% for p=1:length(tRange)
%     subplot(length(tRange),1,p)
%     contourf(dist_x/1e-3,dist_y/1e-3,squeeze(boldResponse(:,:,tRange(p))).');caxis(0.001*[-1 5]);
%
%     %         ,0.001*[-1:0.1:1]);
%     h = title(['boldResponse, t= ' num2str(t(tRange(p))) ' s'],'fontsize',18);set(h,'Interpreter','latex');
%     h = xlabel('x (mm)','fontSize',18);set(h,'Interpreter','latex');
%     h = ylabel('boldResponse (mm)','fontSize',18);set(h,'Interpreter','latex');
%     %         hold on;h2 = plot(gridV1x+1e3*abs(x_0),gridV1y,'r.');%set(h2,'markerSize',1);
%     %         ylim([min(dist_y/1e-3),max(dist_y/1e-3)]);
%     set(gca,'fontSize',18);
%     axis image;
% end

figure;

bmax = max(boldResponse(:));
bmin = min(boldResponse(:));

for p=1:length(tRange);
    subplot(length(tRange),1,p)
    plot(dist_x/1e-3,squeeze(boldResponse(:,indy,tRange(p))),'lineWidth',3);
    hold on;
%     errorbar(dist_x/1e-3,squeeze(boldResponse(:,indy,tRange(p))),squeeze(yerr(:,indy,tRange(p))));
    
    set(gca,'fontSize',18);
    ylim([bmin bmax]);xlim([t(1) t(end)]);
    h = xlabel('$x$ (mm)','fontSize',18);set(h,'Interpreter','latex');
    h = ylabel('BOLD','fontSize',18);set(h,'Interpreter','latex');
    h = title(['$Y(x,y=0,t_i)$, $t_i$= ' num2str(t(tRange(p))) ' s'],'fontsize',18);set(h,'Interpreter','latex');
end;
