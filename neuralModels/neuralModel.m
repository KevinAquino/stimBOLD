% this function generated a template file called neuralModel_nearest.mat
% in the ../GUIcode/data folder
% this template is used by cortical_receptive_field_pooling.m to the end
% of blurring the cortical neuronal responses to mimic the cortical point
% spread function.

%
% load('matlab_np.mat'')
% Version 1, check the points one by one and find the points that in the
% range.

% add path
% addpath('/ramonschiralab/projects/wenbin/toolbox_fast_marching',...
%     '/ramonschiralab/projects/wenbin/toolbox_fast_marching/toolbox');

% read in v1, v2, v3 information
data = MRIread('areas-template.sym.mgh');
area_template = data.vol;

vec_thresh =[1.5, 4, 6]; % unit; mm

%  msh.submesh
%           triangles: [3x29309 double]: mesh structure
%            vertices: [3x14866 double]: vertices

mat_face =msh.submesh.triangles; % here is the index starts from 0
mat_vertex =msh.submesh.vertices;

% the index for index starts from 1 instead of 0
if min(mat_face(:)) ==0;
    mat_face =mat_face+1;
end

% for m =1:size(mat_face, 2)
% if   sum(mat_face(:,m) ==4) >0
%     mat_face(:,m)
% end
%
% end
% calculte the first ring for each vertex
ring_vertex = compute_vertex_ring(mat_face);

% process the stimMap vertices
cell_neighbours_all =cell(1, 3);
cell_vmSubVerts =cell(1, 3);
cell_dis_all =cell(1, 3);

% hence the v1 vertices on neural activity are given by v1SubVerts
matlabpool open

c =fix(clock);

fprintf('\r\nStart time %g, %g, %g - %g:%g:%g\n', c(1:6))

for m =1:3 % v1, v2, v3
    
%     statusbar(main_gui,'Calculating neural Model, phase %g...', m)
    
    vmFullVerts = find(area_template==m); % vmFullVerts starts from 1 if possible,
    [nold,vmSubVerts] = find(msh.submesh.fullToSub(vmFullVerts,:)); % vmSubVerts starts from 1
    
%     no need to add 1
%     vmSubVerts =vmSubVerts+1;
    
    val_dis_thresh =vec_thresh(m);
    
    cell_neighbours =cell(1, length(vmSubVerts));
    cell_dis =cell(1, length(vmSubVerts));
    
    
    parfor n =1:length(vmSubVerts) % process it one by one
        
%         fprintf('\nProcessing index %g\n', n)
        %         statusbar(main_gui,'Calculating neural Model, phase %g, %3.2f%%', m, n/length(vmSubVerts_matlab));
        vec_me_index =vmSubVerts(n);
        
        val_dis_next =0;
        ind_seed_parents =0;
        flag_while =true;
        
        vec_neighbours_all =[];
        vec_dis_all =[];
        
        while flag_while
            
            [vec_next_index, dis_next]= search_nearest_neighbours(vec_me_index,...
                ring_vertex, mat_vertex, val_dis_next, val_dis_thresh, ind_seed_parents, vmSubVerts);
            
            ind_seed_parents =cat(2, vec_next_index, ind_seed_parents);
            vec_me_index =vec_next_index;
            val_dis_next =dis_next;
            
            
            vec_neighbours_all =cat(2,  vec_neighbours_all, vec_next_index);
            vec_dis_all =cat(2, vec_dis_all, dis_next);
            if isempty(vec_next_index)
                flag_while =false;
            end
            
        end
        
        cell_neighbours{n} =vec_neighbours_all;
        cell_dis{n} =vec_dis_all;
       
    end
%      save(['neuralModel_nearest_v' num2str(m)], 'cell_neighbours', 'vmSubVerts');
    
     cell_neighbours_all{m} =cell_neighbours;
     cell_vmSubVerts{m} =vmSubVerts;
     cell_dis_all{m} =cell_dis;
     
end

save('neuralModel_nearest', 'cell_neighbours_all', 'cell_vmSubVerts', 'cell_dis_all', 'vec_thresh');
c =fix(clock);

fprintf('\r\nEnd time %g, %g, %g - %g:%g:%g\n', c(1:6))

matlabpool close

% save('neuralModel_nearest', 'cell_neighbours_all');

% do the same for V2,V3 which cause area_template to be 2, or 3