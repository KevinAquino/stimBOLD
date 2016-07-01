function perimeter = getPerimeterFromROI(msh,ROI)


% This is the first step: create a smaller mesh from the ROI specified.
[msh2] = getSubMesh(msh,ROI);
msh = msh2.submesh;
clear msh2


% first get the list of vertices
intList = 1:size(msh.vertices,2);
faces = msh.triangles + 1;
excludeList = [];
perimeter = [];
% now go through the list to see which ones are connected to an edge
% that only has one triangle

% first find a vertex on the perimeter, then gerneate the rest from
% that
for k=intList,
    
    
    % find all triangles connected to it first
    listInd = ismember(faces,k);
    [nr,nc] = find(listInd);
    
    % get all the faces
    indFaces = faces(:,nc);
    
    % now that we have all the faces need to look at the edges, each
    % each has to only have one triangle to it.
    
    % now go through all the edges
    connectedNodes = setdiff(setdiff(unique(reshape(indFaces,numel(indFaces),1)),k),excludeList(:).');
    notList=[];
    for j=1:length(connectedNodes)
        count = 0;
        for indf=1:length(nc),
            if(~isempty(setdiff(indFaces(:,indf),[k,connectedNodes(j)])))
                count = count+1;
            end;
            
            if(count>1)
                notList = [notList,connectedNodes(j)];
                break;
            end
        end
    end
    
    perimNode = (setdiff(connectedNodes,notList));
    %         size(connectedNodes)
    
    if(isempty(perimNode))
        excludeList = [excludeList,k];
    else
        perimeter = [k,perimNode(1)];
        break;
    end
    % then write
    
    
end

%now begin the perimeter construction, get the ball rolling.
% now that we have the start of the perimeter, connect up the remaining
% points.
startPoint = perimeter(1);
closedCondition = 0;
while(~closedCondition)
    listInd = ismember(faces,perimeter(end));
    [nr,nc] = find(listInd);
    
    % get all the faces
    indFaces = faces(:,nc);
    connectedNodes = (unique(reshape(indFaces,numel(indFaces),1)));
    
    
    if(length(perimeter)>3 && ismember(startPoint,connectedNodes))
        closedCondition = 1;
    end
    
    connectedNodes = setdiff(connectedNodes,perimeter);
    
    for j=1:length(connectedNodes)
        count = 0;
        for indf=1:length(nc),
            
            if(length(setdiff(indFaces(:,indf),[perimeter(end),connectedNodes(j)]))==1)
                
                count = count+1;
            end;
        end
        
        if(count==1)
            
            perimeter = [perimeter,connectedNodes(j)];
            break;
        end
    end    
end

% now transform back to the larger mesh
perimeter = msh.fullMeshIndices(perimeter);
% [nsub,perimeter] = find(msh.subToFull(perimeter,:));
end


