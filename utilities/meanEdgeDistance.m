% function to get mean edge distance.

function meanDist = meanEdgeDistance(triangles,vertices)

%Grab the edge list
edges = [triangles([1,2],:).'; triangles([2,3],:).'; triangles([3,1],:).'];

% This makes the edge list unique
edges = unique(edges,'rows'); 

% Get the edge length
distances = sqrt( sum( (vertices(:,edges(:,1))-vertices(:,edges(:,2))).^2 ,1) );

% Get average around each vertex
dist_edge = zeros(size(vertices,2),1);
count = zeros(size(vertices,2),1);

for k = 1:size(edges,1)
    
    % Assign nodes from each edge
    n1 = edges(k,1); n2 = edges(k,2);
    
    % Add to vertices
    dist_edge(n1) = dist_edge(n1)+distances(k); 
    dist_edge(n2) = dist_edge(n2)+distances(k); 
    
    % adding to the count for each vertex
    count(n1) = count(n1)+1;
    count(n2) = count(n2)+1;
end
dist_edge = dist_edge./count;

% Mean inter-node distance
meanDist = mean(dist_edge);