% Make a movie in .mp4

% First get the image:
% print to .png

% Get the image you want to loop over in this section and print off to
% movie

displayImage = boldResponse;


if(~isdir('tmpfldr'))  % create a temporary folder
    mkdir tmpfldr
end;

bmax = max(displayImage(:));
bmin = min(displayImage(:));

for nt=100:1:size(displayImage,3),
    figure(10);
    
    contourf(dist_x/1e-3,dist_y/1e-3,squeeze(displayImage(:,:,nt)).');caxis([bmin bmax]);
        
    h = title(['Y, t= ' num2str(t(nt)) ' s'],'fontsize',18);set(h,'Interpreter','latex');
%     h = xlabel('x (mm)','fontSize',18);set(h,'Interpreter','latex');
%     h = ylabel('y (mm)','fontSize',18);set(h,'Interpreter','latex');
    set(gcf,'PaperPosition',[0.25 0.25 6 5]);
    
    print(gcf,['./tmpfldr/movieFile ' num2str(nt) '.png'],'-dpng','-painters');
    
end

%% Now make a quicktime movie

dirList = dir('./tmpfldr/*.png');


movObj = QTWriter('movieFile.mov');

movObj.FrameRate = 25;


for fileN = 1:length(dirList);
    img = imread(['./tmpfldr/' dirList(fileN).name]);
    writeMovie(movObj,img);
end;

%save the movie
close(movObj);
