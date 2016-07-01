
figure(20);
subplot(131)
grid=makeVisualGrid(0.01,5.5,10,3,200);
polar(grid(2,:),grid(1,:),'r.');
set(gca,'fontSize',18);
title('Visual Field','fontSize',18);
hold on;

subplot(132);
plot(1e3*abs(x_0)+gridV1x,gridV1y,'r.');axis image;
xlabel('x (mm)','fontSize',18);ylabel('y (mm)','fontSize',18);set(gca,'fontSize',18);
title('On Visual Cortrex','fontSize',18);
hold on;

subplot(133);
h = title(['Y, t= ' num2str(t(tRange(p))) ' s'],'fontsize',18);set(h,'Interpreter','latex');
h = xlabel('x (mm)','fontSize',18);set(h,'Interpreter','latex');
h = ylabel('y (mm)','fontSize',18);set(h,'Interpreter','latex');

IndsStart = time_indices(:,1);

for nt=1:500;
%     
%     if(sum(IndsStart == nt))
%         k = find(IndsStart==nt);
%         subplot(1,3,1);
%         polar(grid(2,:),grid(1,:),'r.');
%         set(gca,'fontSize',18);
%         title('Visual Field','fontSize',18);
%         hold on;
%         
%         h = polar(thmat(:,k),rmat(:,k),'*');
%         set(h,'Color',[0 1-k/size(rmat,2) k/size(rmat,2)]);
%         hold off
%         
%         
%         
%         subplot(1,3,2);
%         plot(1e3*abs(x_0)+gridV1x,gridV1y,'r.');axis image;
%         xlabel('x (mm)','fontSize',18);ylabel('y (mm)','fontSize',18);set(gca,'fontSize',18);
%         title('On Visual Cortrex','fontSize',18);
%         hold on;
%         h = plot(squeeze(corticalMappingV1(1,:,k)*1e3),squeeze(corticalMappingV1(2,:,k)*1e3),'*');
%         set(h,'Color',[0 1-k/size(rmat,2) k/size(rmat,2)]);
%         hold off
%         %     axis([-90 -40 -25 25]);
%         drawnow;
%         %         pause(0.2);
%     end
%     
    subplot(133);   
    imagesc(dist_x/1e-3,dist_y/1e-3,squeeze(boldResponse(:,:,nt)).');caxis(0.001*[-1 5]);
    title('BOLD Signal','fontSize',18);
    drawnow;
    
    %     hold off
    
    % show the plots in real time
    

    pause(mean(diff(t))/2);
end
