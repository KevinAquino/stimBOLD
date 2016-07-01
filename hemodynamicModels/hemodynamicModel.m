% hemodynamicModel.m
% Kevin Aquino 2014
%
% Function to calculate the hemodynamic wave equation, and the BOLD
% response.

function [BOLD F Xi] = hemodynamicModel(zeta,msh,params)

% In this case i will have to use the output from the neural drive into the
% hemodynamic model. This will be the most intensive bit of the analysis.

hemo_model = params.hemo_model;
z_n = params.z_n;
zeta = z_n*zeta;

faces = msh.submesh.triangles.';
vertices = msh.submesh.vertices.';
[L, A, ~] = calculateLaplaceBeltramiOperator(vertices,faces+1, params);


if(hemo_model== 1)
    [BOLD,F,Xi] = solve_linhwe_surface(msh,L,A,zeta,params);
elseif(hemo_model == 2)
    [boldResponse] = NonFourierForm2Dnonlinear(x,y,t,0.03*zxt);    
    boldResponse(:,:,1:2) = boldResponse(:,:,3:4);
elseif(hemo_model == 3)
    gaussianModel;
end;