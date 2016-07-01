polMap = retinalTemplate.polarAngle;
ecMap = retinalTemplate.eccentricity;

[xx,yy] = pol2cart(polMap,ecMap);


% Display it
% figure;
% mesh([xx(:).';xx(:).'],[yy(:).';yy(:).'],[retinal_image;retinal_image],'mesh','column','marker','.','MarkerSize',30);
% view(2)
% axis image
% xlim([0 params.MAX_SCREEN_EC]);
% ylim([-params.MAX_SCREEN_EC params.MAX_SCREEN_EC]);

TRI = delaunay(xx,yy);

% now plot the retinal response as a function of time as a surface:
figure;
p = patch('Vertices',[xx(:).';yy(:).'].','Faces',TRI,'CData',retinal_response(:,1).','FaceColor','interp','edgeColor','none');
axis image
xlim([0 params.MAX_SCREEN_EC]);
ylim([-params.MAX_SCREEN_EC params.MAX_SCREEN_EC]);


for j=1:length(params.t);    
set(p,'CData',retinal_response(:,j).');
pause(0.1)
drawnow
end