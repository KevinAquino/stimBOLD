function [L, A, Convergence] = calculateLaplaceBeltramiOperator(vertices,faces,params)
%% Calculates Discrete Laplacian Beltrami Operator on triangulated surfaces.
% Meyer et al.,  2003 "Discrete Differential Geometry Operators ..."
% Belkin et al., 2008 "Discrete Laplace Operator On Meshed Surface"
%
% ARGUMENTS:
%           vertices  -- a matrix of size num_vertices x 3  
%           faces     -- a matrix of size num_faces x 3
%           params    -- the model parameters to determine which should be
%                        used.
%           
% OUTPUT: 
%           L  -- Discrete approximation to Laplace-Beltrami operator.
%                 Size is num_vertices x num_vertices
%           A  -- Local surface area around each vertex.
%                 Size is num_vertices x 1.
%           Convergence -- <some description here>
%
% REQUIRES:
%           BelkinMeshLaplacian() -- LBO as described in Belkin et al.,
%           2008
%
% USAGE:
%{
       [LapOp, Area, Convergence] = calculateLaplaceBeltramiOperator(vertices, faces, params);

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ver. 06-Nov-2014 Disable the command window output

if size(vertices,1) < size(vertices,2);
    error(strcat('stimBOLD:', mfilename,':WrongMatrixDimensions'), ...
        'Try transposing the input matrices ...');
else
 num_vertices = size(vertices,1);
 num_faces = size(faces,1);
end

LBO_model = params.LBO_model;

% fprintf('Computing Laplace-Beltrami operator...');
switch LBO_model,
    case 'Meyer'
        Convergence = [];
        % Compute inner face angles and squared edge lengths. 
        % Fig. 3 in Meyer et al., 2013.
        pp = zeros(num_faces,3);
        qq = zeros(num_faces,3);
        angles = 0*faces;
        squared_edge_length = 0*faces;

        for i=1:3
            i1 = mod(i-1,3)+1;
            i2 = mod(i  ,3)+1;
            i3 = mod(i+1,3)+1;
            pp = vertices(faces(:,i2),:) - vertices(faces(:,i1),:);
            qq = vertices(faces(:,i3),:) - vertices(faces(:,i1),:);
            % normalize the vectors
            pp = pp ./ repmat( max(sqrt(sum(pp.^2,2)),eps), [1 3] );
            qq = qq ./ repmat( max(sqrt(sum(qq.^2,2)),eps), [1 3] );
            % compute angles
            angles(:,i1) = acos(sum(pp.*qq,2));
            squared_edge_length(:,i1) = sum((vertices(faces(:,i2)) - vertices(faces(:,i3))).^2,2);

        end
        clear pp qq;

        % Compute cotangent Laplace-Beltrami Operator.
        L = sparse(num_vertices,num_vertices);
        for i=1:3
            i1 = mod(i-1,3)+1;
            i2 = mod(i  ,3)+1;
            i3 = mod(i+1,3)+1;
            L = L + sparse(faces(:,i1),faces(:,i2),-cot(angles(:,i3)),...
                num_vertices,num_vertices,num_faces);       
        end


        L = 1/2 * (L + L');
        L = sparse(1:num_vertices,1:num_vertices,-sum(L,2),num_vertices,num_vertices,...
            num_vertices) + L;

        % fprintf('done. \n');

        % Compute area of each triangle
        faces_area = zeros(num_faces,1);

        norm = @(x) sqrt(sum(x.^2,2)); % norm of a vector
        area = @(vi,vj) norm(cross(vi,vj))./2;

        vv1 = vertices(faces(:,3),:) - vertices(faces(:,2),:);
        vv2 = vertices(faces(:,2),:) - vertices(faces(:,1),:);
        faces_area = area(vv1,vv2);

        % Compute surface area for each vertex. It checks whether the region is
        % Voronoi safe or not as in Fig. 4 from Meyer et al., 2003
        A = zeros(num_vertices,1);
        for j = 1:num_vertices
            for i = 1:3
                i1 = mod(i-1,3)+1;
                i2 = mod(i,3)+1;
                i3 = mod(i+1,3)+1;
                ind_j = find(faces(:,i1) == j);
                for l = 1:size(ind_j,1)
                    face_index = ind_j(l);
                    % Voronoi safe
                    if (max(angles(face_index,:)) <= pi/2),
                        A(j) = A(j) + 1/8 * (1/tan(angles(face_index,i2))* ...
                            squared_edge_length(face_index,i2) + ... 
                            1/tan(angles(face_index,i3))*...
                            squared_edge_length(face_index,i3));
                    % Voronoi innapropriate
                    elseif angles(face_index,i1) > pi/2,
                        % if angle of *face* at *j* is obtuse
                        A(j) = A(j) + faces_area(face_index)/2; 
                    else
                        A(j) = A(j) + faces_area(face_index)/4;
                    end
                end        
            end
        end
    case 'Belkin'
    A = [];    
    TR = triangulation(faces, vertices);
    [L, Convergence] =  ThisMeshLaplacian(TR,1);
end
end %function calculateLaplaceBeltramiOperator