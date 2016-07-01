function msh = display_sim_movie(Ft,msh,range,frameStep,thresh,display_surface)    
% display_sim_movie.m
% Kevin Aquino 2014
%
% Function to display the simulation movie, must have vistatools installed
% to use this properly.

normal_id = 1;
inflated_id = 2;
sphere_id = 3;

if (nargin<6),
    display_surface = 'original';
end



switch display_surface,
    case 'original'        
        if(msh.id ~= normal_id)
            msh.id = normal_id;
            msh.vertices = msh.originalvertices;
            if(~(ismember(normal_id,msh.idOpen)))
                msh = meshVisualize(msh);
                msh.idOpen = [msh.idOpen,msh.id];
            end
        end
        disp('Displaying the evolution on the normal surface');

    case 'inflated'
        if(msh.id ~= inflated_id)
            msh.vertices = msh.inflatedvertices;
            msh.id = inflated_id;
            if(~(ismember(inflated_id,msh.idOpen)))
                msh = meshVisualize(msh);
                msh.idOpen = [msh.idOpen,msh.id];
            end
        end
        disp('Displaying the evolution on the inflated surface');
    case 'sphere'
        if(msh.id~= sphere_id)
            msh.vertices = msh.spherevertices;
            msh.id = sphere_id;
            if(~(ismember(sphere_id,msh.idOpen)))
                msh = meshVisualize(msh);
                msh.idOpen = [msh.idOpen,msh.id];
            end
        end
        disp('Displaying the evolution on the inflated sphere');
end

if (nargin<5),
    thresh = [];
end

if(nargin < 3)
    range = [0 1];
    frameStep = 1;
end



for nn=1:frameStep:size(Ft,1)        
    colors = meshData2Colors(Ft(nn,:), (jet(256).'),range,1);
    mshCol = zeros(4,size(Ft,2));
    mshCol(1:3,:) = colors;
    mshCol(4,:) = 1;
    mshCol = (round(mshCol*255));
    
    if(~isempty(thresh))
        threshVals = find(abs(Ft(nn,:))<thresh);
        mshCol(:,threshVals) = msh.submesh.oldColors(:,threshVals);
    end
    
    
    
%     msh.colors = mshCol;

    msh.colors(:,msh.submesh.fullMeshIndices) = mshCol;
    
    p.actor = 32;
    p.colors = uint8(msh.colors);
    [id,stat,res] = mrMesh('localhost', msh.id, 'modify_mesh', p);
    
end

