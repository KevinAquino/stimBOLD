% display_sim_movie_flat.m
%
%
% This function draws responses/mappings on the flattened cortex. 
%
% Kevin Aquino 14/11/2014
%

function [msh,figParams] = display_sim_movie_flat(data,msh,figParams)

if(nargin<3)
    figParams = struct;
end

% == Start initialization

if(~isfield(figParams,'figNo'))
    figParams.figNo = [];
end

if(~isfield(figParams,'figParentAxis'))
    figParams.figParentAxis = [];
end

if(~isfield(figParams,'skipInitialization'))
    figParams.skipInitialization = 0;
end


if (~isfield(figParams,'maxClip') && ~isempty(data)),
    figParams.maxClip = max(data(:));
end

if(~isfield(figParams,'minClip') && ~isempty(data))
    figParams.minClip = min(data(:));
end

if(~isfield(figParams,'range'))
    figParams.range = [0 1];
end



if(~figParams.skipInitialization)  

           
    % Added capability to plot surface on another axis.
    if(isempty(figParams.figParentAxis));
        if(isempty(figParams.figNo))
           figure; 
        else
            figure(figParams.figNo)
        end
        
        figParams.figHandle = patch('Vertices',msh.flatCoord,'Faces',msh.submesh.triangles.'+1,'FaceColor','interp','FaceVertexCData',msh.submesh.oldColors(1:3,:).'/255,'EdgeColor','none');
        axis 'image';
        axis off;        
        lighting gouraud
        
    else       
        figParams.figHandle = patch('Vertices',msh.flatCoord,'Faces',msh.submesh.triangles.'+1,'FaceColor','interp','FaceVertexCData',msh.submesh.oldColors(1:3,:).'/255,'EdgeColor','none','Parent',figParams.figParentAxis);
        axis 'image';
        axis off;        
        lighting gouraud
%         colormap jet;
    end       
    
    figParams.skipInitialization = 1;
end


% == End initialization

% now color the figure;

if(isempty(data))
    return
end

% now color the flat mesh

if(isfield(figParams,'colorMap'));
    switch figParams.colorMap
        case 'hsv'
            cmap = (hsv(256).');
        case 'jet'
            cmap = (jet(256).');
        case 'hot'
            cmap = (hot(256).');
    end
else
    cmap = (hsv(256).');
            
end
colors = meshData2Colors(data,cmap,figParams.range,1);

% convention for 4 outputs of color is for legacy reasons - vistatools'
% mrMeshSrv (http://white.stanford.edu/newlm/index.php/MrVista) uses four
% colors. Will have an option in future to draw ROIS etc.

mshCol = zeros(4,size(data,2));
mshCol(1:3,:) = colors;
mshCol(4,:) = 1;
mshCol = (round(mshCol*255));

% now clip the map if needed.
threshVals = find(data>figParams.maxClip);
mshCol(:,threshVals) = msh.submesh.oldColors(:,threshVals);

threshVals = find(data<figParams.minClip);
mshCol(:,threshVals) = msh.submesh.oldColors(:,threshVals);
%

msh.submesh.colors = mshCol;

set(figParams.figHandle,'FaceVertexCData',msh.submesh.colors(1:3,:).'/255);
        


end