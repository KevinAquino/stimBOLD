function [Vs, Fs]=perform_tri_subdivision(V, F, n)

% Sub-triangulates the triangles defined by the patch format data F (faces)
% and V (vertices). Creates n addition points on the edges of the initial
% triangles, thus it creates (n+1).^2 triangles per original triangle.
% No double points are introduced.
% Input: F, the face matrix, row-wise
%        V, the vertex matrix, row-wise
%        n, how many more points per edge which is connected by two points
%
% Can be used to increase the density of triangulated data (see example
% below) or to triangulate the icosahedron to create geodesic sphere
% triangulations with desired density.
%
% %% EXAMPLE
% [X,Y] = meshgrid(linspace(-10,10,15));
% Z = sinc(sqrt((X/pi).^2+(Y/pi).^2));
% F = delaunay(X,Y); V=[X(:) Y(:) Z(:)]; C=mean(Z(F),2);
%
% n=2;
% [Fs,Vs]=subtri(F,V,n);
% Vs(:,3)=sinc(sqrt((Vs(:,1)/pi).^2+(Vs(:,2)/pi).^2)); Z=Vs(:,3);Cs=mean(Z(Fs),2);
%
% figure('units','normalized','Position',[0 0 1 1],'Color','w'); colordef('white');
% subplot(1,2,1);patch('Faces',F,'Vertices',V,'FaceColor','flat','CData',C,'FaceAlpha',0.5,'EdgeColor','k','LineWidth',2); hold on;
% axis tight; axis square; grid on; hold on; view(3); axis off;
% title('Original','FontSize',20);
% subplot(1,2,2);patch('Faces',Fs,'Vertices',Vs,'FaceColor','flat','CData',Cs,'FaceAlpha',0.5,'EdgeColor','k','LineWidth',0.5); hold on;
% axis tight; axis square; grid on; hold on; view(3); axis off;
% title(['n=',num2str(n)],'FontSize',20);
%
% Kevin Mattheus Moerman
% kevinmoerman@hotmail.com
% 01/06/2010
% ------------------------------------------------------------------------
% Modified by Wenbin
% 13/01/2013

if nargin<3, n =1; end

no_faces=size(F,1);
X=V(:,1);
Y=V(:,2);
Z=V(:,3);

%% Creating "Edge indices"
% how many points in the vertices, each row of the vector V is a point/vertex
vsize=size(V,1).*ones(1,3); %Arbitrary

IJ_1=[F(:,1) F(:,2)];
edge_IND1= sub2ind(vsize,IJ_1(:,1),IJ_1(:,2));
IJ_2=[F(:,2) F(:,3)];
edge_IND2= sub2ind(vsize,IJ_2(:,1),IJ_2(:,2));
IJ_3=[F(:,3) F(:,1)];
edge_IND3= sub2ind(vsize,IJ_3(:,1),IJ_3(:,2));

E=[edge_IND1 edge_IND2 edge_IND3]; %Edges matrix
[E_unique,ind_uni_1,ind_uni_2]=unique(E);
%To remove doubles, E_unique(ind_uni_2) =E

% reshape ind_uni_2 to make it have the same size with E, E_unique(IND_E_uni) =E
IND_E_uni=reshape(ind_uni_2,size(E));

% extract subscript values from linear indexing for edges
[I,J] = ind2sub(vsize,E_unique);

% Creating points on edges
A=X(I);
B=X(J);
% size_A=size(A);
A=A(:);
B=B(:);
Xe=(A*ones(1,n+2))+((B-A)./(n+1))*(0:1:n+1);% coordinates of points on the xy plane
% Xe is a matrix of (n+2)*(n+2)
% Xe=Xe(:,1:end);

A=Y(I);
B=Y(J);
% size_A=size(A);
A=A(:);
B=B(:);
Ye=(A*ones(1,n+2))+((B-A)./(n+1))*(0:1:n+1);% coordinates of points on the yz plane
% Ye=Ye(:,1:end);

A=Z(I);
B=Z(J);
% size_A=size(A);
A=A(:);
B=B(:);
Ze=(A*ones(1,n+2))+((B-A)./(n+1))*(0:1:n+1); %coordinates of points on the zx plane
% Ze=Ze(:,1:end);

%% Creating points on faces
Xi=[]; Yi=[]; Zi=[];
for i=0:1:n+1
    if i==0
        X1=Xe(IND_E_uni(:,1),end); % Xe, Ye, Ze new vertex point coordinates
        Y1=Ye(IND_E_uni(:,1),end);
        Z1=Ze(IND_E_uni(:,1),end);
    else
        no_steps=i+1;
        pfrom=Xe(IND_E_uni(:,1),end-i); pto=Xe(IND_E_uni(:,2),i+1);
        X1=(pfrom*ones(1,no_steps))+((pto-pfrom)./(no_steps-1))*(0:1:no_steps-1);
        pfrom=Ye(IND_E_uni(:,1),end-i); pto=Ye(IND_E_uni(:,2),i+1);
        Y1=(pfrom*ones(1,no_steps))+((pto-pfrom)./(no_steps-1))*(0:1:no_steps-1);
        pfrom=Ze(IND_E_uni(:,1),end-i); pto=Ze(IND_E_uni(:,2),i+1);
        Z1=(pfrom*ones(1,no_steps))+((pto-pfrom)./(no_steps-1))*(0:1:no_steps-1);
    end
    X1=X1(:,1:end);Y1=Y1(:,1:end);  Z1=Z1(:,1:end);
    Xi=[Xi; X1(:)]; Yi=[Yi; Y1(:)]; Zi=[Zi; Z1(:)];
end

%Setting up new faces matrix
no_points_per_face=(0.5.*n+1).*(n+3);
IND_F1=1+(no_faces.*((1:1:no_points_per_face)-1));
IND_IND_F1=1:1:length(IND_F1);
line_pairs=[IND_IND_F1(2:end-1)' IND_IND_F1(3:end)'];
N=1:n+2;
IND_skip_edge=(N.*(N+1))./2;
L_keep=~ismember(line_pairs(:,1),IND_skip_edge);
line_pairs=line_pairs(L_keep,:);
F11=[line_pairs(:,1) (1:1:size(line_pairs,1))' line_pairs(:,2)];
line_pairs=line_pairs(1:end-(n+1),:);
F12=[line_pairs sum(line_pairs,2)-(0:1:size(line_pairs,1)-1)'];
F1=[IND_F1(F11); IND_F1(F12)];
A=ones(size(F1,1),1)*(0:1:size(F,1)-1);A=A(:)*ones(1,3);
Fs=repmat(F1,[size(F,1),1])+A;

%% Removing double points
%Getting minimum triangle distance to assist rounding and "unique"
%operation
x_vert=Xi(Fs); y_vert=Yi(Fs); z_vert=Zi(Fs);
c_from=1:1:size(Fs,2);
c_upto=[c_from(end) c_from(1:end-1)];
dc=zeros(size(Fs,1),1);
for c=c_from;
    dc=hypot(hypot((x_vert(:,c_from(c))-x_vert(:,c_upto(c))),(y_vert(:,c_from(c))-y_vert(:,c_upto(c)))),(z_vert(:,c_from(c))-z_vert(:,c_upto(c))));
    Fs_dist(:,c)=dc;
end

d_min=min(Fs_dist(:));
min_dist=10;
mult_fac=min_dist./d_min;
V=round(mult_fac.*[Xi Yi Zi]);

%%Slower distance calculation based correction
% AX=V(:,1)*ones(1,size(V,1));
% AY=V(:,2)*ones(1,size(V,1));
% AZ=V(:,3)*ones(1,size(V,1));
% BX=ones(size(V,1),1)*V(:,1)';
% BY=ones(size(V,1),1)*V(:,2)';
% BZ=ones(size(V,1),1)*V(:,3)';
% d=hypot(hypot((AX-BX),(AY-BY)),(AZ-BZ));
% d(1:size(d,1)+1:numel(d))=1;
% L=triu(d<max(eps(d(:))));
% [IND_double_1,IND_double_2]=find(L);
% V(IND_double_1,:)=V(IND_double_2,:);

[Vs,ind_uni_1,ind_uni_2]=unique(V,'rows');

Vs=[Xi(ind_uni_1) Yi(ind_uni_1) Zi(ind_uni_1)];

%Changing indices in faces matrix
[IND_uni_F,ind_uni_1_F,ind_uni_2_F]=unique(Fs);
Fs=reshape(ind_uni_2(ind_uni_2_F),size(Fs));

end

function [f1,face1] = perform_mesh_subdivision(f, face, nsub, options)

% perform_mesh_subdivision - perfrom a mesh sub-division
%
%   [face1,f1] = perform_mesh_subdivision(f, face, nsub, options);
%
%   face is a (3,nface) matrix of original face adjacency
%   face1 is the new matrix after subdivision
%   f is a (d,nvert) matrix containing the value f(:,i) of a function
%       at vertex i on the original mesh. One should have
%           nvert=max(face(:))
%       (can be multi dimensional like point position in R^3, d=3)
%   f1 is the value of the function on the subdivided mesh.
%   nsub is a scalar that indicates that how many iterations required
%   
%   options.sub_type is the kind of subdivision applied:
%       'linear4': 1:4 tolopoligical subdivision with linear interpolation
%       'linear3': 1:3 tolopoligical subdivision with linear interpolation
%       'loop': 1:4 tolopoligical subdivision with loop interpolation
%       'butterfly': 1:4 tolopoligical subdivision with linear interpolation
%       'sqrt3': 1:3 topological subdivision with sqrt(3) interpolation
%          (dual scheme).
%       'spherical4': 1:4 tolopoligical subdivision with linear
%           interpolation and projection of f on the sphere
%       'spherical3': 1:3 tolopoligical subdivision with linear
%           interpolation and projection of f on the sphere
%
%   An excellent reference for mesh subdivision is
%       Subdivision for Modeling and Animation,
%       SIGGRAPH 2000 Course notes.
%       http://mrl.nyu.edu/publications/subdiv-course2000/
%
%   The sqrt(3) subdivision is explained in
%       \sqrt{3}-subdivision, Leif Kobbelt
%       Proc. of SIGGRAPH 2000
%
%   Copyright (c) 2007 Gabriel Peyré
%   modified by Wenbin

options.null = 0;
if nargin<2
    error('input:check','Not enough arguments');
end
if nargin==2
    nsub=1;
end

sub_type = getoptions(options, 'sub_type', '1:4');
spherical = getoptions(options, 'spherical', 0);
sanity_check = getoptions(options, 'sanity_check', 1);

switch lower(sub_type)
    case 'linear3'
        interpolation = 'linear';
        topology = 3;
    case 'linear4'        
        interpolation = 'linear';
        topology = 4;
    case '1:3'
        interpolation = 'linear';
        topology = 3;
    case '1:4'
        interpolation = 'linear';
        topology = 4;
end

if nsub==0
    f1 = f;
    face1 = face;
    return;
end

if nsub>1
    % special case for multi-subdivision
    f1 = f;
    face1 = face;
    for i = 1:nsub
         [f1,face1] = perform_mesh_subdivision(f1,face1,1, options);
    end
    return;    
end


if size(f,1)>size(f,2) && sanity_check
    f=f';
end

% if size(face,1)>size(face,2) && sanity_check
%     face=face';
% end
if (size(face, 1)~=3) && sanity_check
     face=face';
     if size(face, 1)~=3
         error('dim:check', 'The face matrix provides wrong data, please check.')
     end
end

m = size(face,2);
n = size(f,2);

verb = getoptions(options, 'verb', n>500);
loop_weigths = getoptions(options, 'loop_weigths', 1);

if topology==3
    f1 = ( f(:,face(1,:)) + f(:,face(2,:)) + f(:,face(3,:)))/3;
    f1 = cat(2, f, f1 );
    %%%%%% 1:3 subdivision %%%%%
    switch interpolation
        case 'linear'
            face1 = cat(2, ...
                [face(1,:); face(2,:); n+(1:m)], ...
                [face(2,:); face(3,:); n+(1:m)], ...
                [face(3,:); face(1,:); n+(1:m)] );
                 
        otherwise 
            error('Unknown scheme for 1:3 subdivision');
    end
else
    %%%%%% 1:4 subdivision %%%%%
    i = [face(1,:) face(2,:) face(3,:) face(2,:) face(3,:) face(1,:)];
    j = [face(2,:) face(3,:) face(1,:) face(1,:) face(2,:) face(3,:)];
    I = find(i<j);
    i = i(I); j = j(I);
    [tmp,I] = unique(i + 1234567*j);
    i = i(I); j = j(I);
    ne = length(i); % number of edges
    s = n+(1:ne);

    A = sparse([i;j],[j;i],[s;s],n,n);

    % first face
    v12 = full( A( face(1,:) + (face(2,:)-1)*n ) );
    v23 = full( A( face(2,:) + (face(3,:)-1)*n ) );
    v31 = full( A( face(3,:) + (face(1,:)-1)*n ) );

    face1 = [   cat(1,face(1,:),v12,v31),...
        cat(1,face(2,:),v23,v12),...
        cat(1,face(3,:),v31,v23),...
        cat(1,v12,v23,v31)   ];
    
    
    switch interpolation
        case 'linear'            
            % add new vertices at the edges center
            f1 = [f, (f(:,i)+f(:,j))/2 ];
            
        otherwise 
            error('Unknown scheme for 1:3 subdivision');
    end
end

if spherical
    % project on the sphere
    d = sqrt( sum(f1.^2,1) );
    d(d<eps)=1;
    f1 = f1 ./ repmat( d, [size(f,1) 1]);
end
end