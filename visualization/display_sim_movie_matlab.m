function [msh,figParams] = display_sim_movie_matlab(Ft,msh,range,frameStep,thresh,display_surface,figParams)
% displau_sim_movie_matlab.m
% Kevin Aquino 2014
%
% Function here to display the image on the cortical surface.

if(~isfield(figParams,'skipInitialization'))
    figParams.skipInitialization = 0;
end

if(~figParams.skipInitialization)  
    if (nargin<6),
        display_surface = 'original';
        figParams.figView = [60 10];
    end
        
    if(~isfield(figParams,'colorMap'))
        cmap = jet(256).';
    else
        switch figParams.colorMap
            case 'jet'
                cmap = jet(256).';
            case 'hsv'
                cmap = hsv(256).';
            otherwise
                cmap = colorMap;
        end
    end
    
    switch display_surface,
        case 'original'
            msh.vertices = msh.originalvertices;
            figParams.figView = [60 10];
            %         disp('Displaying the evolution on the normal surface');
        case 'inflated'
            msh.vertices = msh.inflatedvertices;
            figParams.figView = [60 10];
            %         disp('Displaying the evolution on the inflated surface');
        case 'sphere'
            msh.vertices = msh.spherevertices;
            figParams.figView = [20 -20];
            %         disp('Displaying the evolution on the inflated sphere');
    end
    
    % Added capability to plot surface on another axis.
    if(isempty(figParams.figParentAxis));
        figure(figParams.figNo);
        figParams.figHandle = patch('Vertices',msh.vertices.','Faces',msh.triangles.'+1,'FaceVertexCData',msh.colors(1:3,:).'/255,'FaceColor','flat','EdgeColor','none');
        axis 'image';
        view(figParams.figView);
        axis off;
        camlight
        lighting gouraud
        colormap jet;
    else
        % This code here is a fix, not sure why figure changes.
        imshow(rand(10),'Parent',figParams.figParentAxis);
        surf([0 0;0 0],'Parent',figParams.figParentAxis)
        figParams.figHandle = patch('Vertices',msh.vertices.','Faces',msh.triangles.'+1,'FaceVertexCData',msh.colors(1:3,:).'/255,'FaceColor','flat','EdgeColor','none','Parent',figParams.figParentAxis);
        axis(figParams.figParentAxis,'image');
        view(figParams.figParentAxis,figParams.figView);
        axis(figParams.figParentAxis,'off')
        camlight
        lighting(figParams.figParentAxis,'gouraud');
        
        
        
        %     colormap jet;
    end
    
    if (nargin<5),
        thresh = [];
    end
    
    if(nargin < 3)
        range = [0 1];
        frameStep = 1;
    end
    
    if(isfield(figParams,'t'))
%         figParams.textHandle = text(figParams.textPositon(1),figParams.textPositon(2),figParams.textPositon(3),['t = ' num2str(figParams.t(1)) ' s'],'fontSize',20);
            figParams.textHandle = text(figParams.textPositon(1),figParams.textPositon(2),figParams.textPositon(3),['t = ' num2str(figParams.t(1)) ' s']);
    end
% else
    % skipping all the initilzation and going to the end.
end

for mn=1:frameStep:size(Ft,1)
    colors = meshData2Colors(Ft(mn,:), cmap,range,1);
    mshCol = zeros(4,size(Ft,2));
    mshCol(1:3,:) = colors;
    mshCol(4,:) = 1;
    mshCol = (round(mshCol*255));
    
    if(~isempty(thresh))
        threshVals = find(abs(Ft(mn,:))<thresh);
        mshCol(:,threshVals) = msh.submesh.oldColors(:,threshVals);
    end
    
    msh.colors(:,msh.submesh.fullMeshIndices) = mshCol;
    set(figParams.figHandle,'FaceVertexCData',msh.colors(1:3,:).'/255);
    if(isfield(figParams,'t'))
        set(figParams.textHandle,'String',['t = ' num2str(figParams.t(mn)) ' s']);
    end
    drawnow;
    
end



