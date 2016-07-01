function [BOLD,F,Xi] = solve_linhwe_surface(msh,L,A,zeta,params)
% solve_linhwe_surface.m
% Kevin Aquino 2014
%
% Function here to calculate the linear hemodynamic wave equation.

dt      = params.dt;
Gamma   = params.Gamma;
v_b     = params.v_b;
gam     = params.gam;
kappa   = params.kappa;
rho_f   = params.rho_f;
eta     = params.eta;
tau     = params.tau;
beta    = params.beta;
k1      = params.k1;
k2      = params.k2;
k3      = params.k3;
V_0     = params.V_0;

zL      = params.L;
k0      = params.k0;
Cz      = params.Cz;
D       = params.D;

k_z     = params.k_z;
t       = params.t;


% have to incorporate two things:
% 1. The surface hwe code
% 2. The code for the source term in the wave equation
% 3. V3!


A2 = A;
% seems to work with thresholding of this level - to get rid of singular
% points in the mesh

A2(A<1e-1) = 1e-1;

% A2 = A;
AA = sparse(1:length(A),1:length(A),A2.^-1);
L2 = AA*L;

faces = msh.triangles.';
vertices = msh.vertices.';




Xi(1,:) = 0*zeta(1,:);
Xi(2,:) = 0*zeta(1,:);


F(1,:) = 0*zeta(1,:);
F(2,:) = 0*zeta(2,:);

% First calculate the flow term:

for kk=3:length(t)
    F(kk,:) = (1/dt^2 + kappa/(2*dt))^(-1)*( (2/dt^2 - gam)*F(kk-1,:) + (kappa/(2*dt) - 1/dt^2)*F(kk-2,:) + zeta(kk-1,:));
    DF(kk,:) = (F(kk,:) - F(kk-1,:))/(2*dt);
end;


if(params.flowNoise==1)
    F = F + randn(size(F))*0.1;
end



FDrive = Cz*(D/rho_f*F + DF);
% FDrive = Cz*(DF);

% v_b^2*k_z^2

for n = 3:length(t),
%     lapop = L2*Xi(n-1,:).';   
    lapop = L2*Xi(n-1,:).'*(1e3)^2;   % factor here to convert to m as L2 contains division by area.
    Xi(n,:) = 1/(1/dt^2 + Gamma/dt)*(2*Xi(n-1,:)/dt^2 + (Gamma/dt - 1/dt^2)*Xi(n-2,:) - v_b^2*k_z^2*Xi(n-1,:) - v_b^2*lapop.' + rho_f*FDrive(n-1,:));% + exp(-n*dt)*F0*(1+sin(n*dt/4));
%     Xi(isnan(Xi)) = 0;
    
end

q(1,:) = 0*zeta(1,:);

for kk=2:length(t);
    q(kk,:) = q(kk-1,:) - dt*q(kk-1,:)*(eta + 1/tau) + Xi(kk-1,:)*dt*Cz*(1/(rho_f*V_0*tau))*(eta*tau - beta + 2)  + (1/rho_f)*(Xi(kk,:) - Xi(kk-1,:));
end;

% Now calculate the bold response
BOLD = V_0*((k2-k3)*Xi/(rho_f*V_0) - (k1+k2)*q);



%     Xi(n,:) = 1/(1/dt^2 + Gamma/dt)*(2*Xi(n-1,:)/dt^2 + (Gamma/dt - 1/dt^2)*Xi(n-2,:) + 0*v_b^2*k_z^2*Xi(n-1,:) - v_b^2*lapop.' + rho_f*F(n-1,:));% + exp(-n*dt)*F0*(1+sin(n*dt/4));
% 

% BOLD = Xi;
% hh = max(BOLD,[],2);figure;plot(hh);