% This function displays a response on a given region with specified
% co-ordinates
% useful for looking at stuff like



function display_response_on_area(polMap,ecMap,params,response,nt,method,parent)

if(nargin<7)
    figure;
    parent = gca;
end

if(nargin<6)
    method = 'patch';
end

if(nargin<5)
    nt = 1:size(response,2);
end

[xx,yy] = pol2cart(polMap,ecMap);
TRI = delaunay(xx,yy);

% now plot the retinal response as a function of time as a surface:
switch method
    case 'patch'
        p = patch('Vertices',[xx(:).';yy(:).'].','Faces',TRI,'FaceVertexCData',response(:,1),'FaceColor','interp','edgeColor','none','parent',parent);
        axis image
        xlim([0 params.MAX_SCREEN_EC]);
        ylim([-params.MAX_SCREEN_EC params.MAX_SCREEN_EC]);
        for j=nt;
            set(p,'FaceVertexCData',response(:,j));
            pause(0.1)
            drawnow
        end
    case 'mesh'
        mesh([xx(:).';xx(:).'],[yy(:).';yy(:).'],[response;response],'mesh','column','marker','.','MarkerSize',30);
        view(2);
        axis image
        xlim([0 params.MAX_SCREEN_EC]);
        ylim([-params.MAX_SCREEN_EC params.MAX_SCREEN_EC]);
end

