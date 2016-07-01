% Code here beginnings of linear hemodynamic wave equation in xi:

l = dx;
h = mean(diff(t));
M = length(x);
N = length(y);


% We have to match CFL condition or else the code will not work, need
% to recheck this step: 

if(2*v_b*h>l);
    warndlg('CFL condition not satisfied! Need (2Hv_b <= L)');
    break;
end;



% Now to genereate intial time points etc:
[xx2 yy2 tt2] = ndgrid(x,y,t);

% Flow term: simulate independendtly (or put it in the explicit time series
% calcuation) 

ii = 1:M;
jj = 1:N;
clear F
F(ii,jj,1) = 0;F(ii,jj,2) = 0;

for kk=3:length(t)
    F(ii,jj,kk) = (1/h^2 + kappa/(2*h))^(-1)*( (2/h^2 - gam)*F(ii,jj,kk-1) + (kappa/(2*h) - 1/h^2)*F(ii,jj,kk-2) + zeta(ii,jj,kk-1));
    DF(ii,jj,kk) = (F(ii,jj,kk) - F(ii,jj,kk-1))/(2*h);
end;

if(flowNoise==1)
    F = F + randn(size(F))*0.1;
end

% here is the Flow drive:
FDrive = Cz*(D/rho_f*F + DF);

% Simulation conditions/variables:
% choose NaNs because if poitns are not specified code will crash instead
% of working incorrectly

xi = NaN(length(x),length(y),length(t));
C = (-2/h^2 + 4*v_b^2/l^2 + v_b^2*k_z^2);
E = 1/(1/h^2 + Gamma/h);


% start with 0
xi(:,:,1) = 0;


% Initial time step 
% ====================================================================
% Boundary conditions set up here:

% First the corners:
xi(1,1,2) = E*(-C*xi(1,1,1) + v_b^2/l*2*( xi(2,1,1) + xi(1,2,1) ));
xi(1,length(y),2) = E*(-C*xi(1,length(y),1) + v_b^2/l*2*(xi(2,length(y),1) + xi(1,length(y)-1,1)));
xi(length(x),1,2) = E*(-C*xi(length(x),1,1) + v_b^2/l*2*(xi(length(x),2,1) + xi(length(x)-1,1,1)));
xi(length(x),length(y),2) = E*(-C*xi(end,end,1) + v_b^2/l*2*(xi(length(x)-1,length(y),1) + xi(length(x),length(y)-1,1)));

% now the sides:
xi(1,2:end-1,2) = E* ( -C*xi(1,2:end-1,1) + v_b^2/l^2*(2*xi(2,2:end-1,1) + xi(1,1:end-2,1) + xi(1,3:end,1)));
xi(end,2:end-1,2) =E*( -C*xi(end,2:end-1,1)  +v_b^2/l^2*(2*xi(end-1,2:end-1,1) + xi(end,1:end-2,1) + xi(end,3:end,1)));
xi(2:end-1,1,2) = E* ( -C*xi(2:end-1,1,1) + v_b^2/l^2*(2*xi(2:end-1,2,1) + xi(1:end-2,1,1) + xi(3:end,1,1)));
xi(2:end-1,end,2) =E*( -C*xi(2:end-1,end,1)  +v_b^2/l^2*(2*xi(2:end-1,end-1,1) + xi(1:end-2,end,1) + xi(3:end,end,1)));

% now the rest of first time step:
xi(2:end-1,2:end-1,2) = E*(-C*xi(2:end-1,2:end-1,1) + v_b^2/l^2*(xi(3:end,2:end-1,1) + xi(2:end-1,3:end,1) + xi(1:end-2,2:end-1,1) + xi(2:end-1,1:end-2,1)));
xi(:,:,2) = xi(:,:,2) + rho_f*E*FDrive(:,:,1);
% ===================================================v=================

% Now simulate the resposne


clear q

for kk = 3:length(t)        
    

    % put in corner terms
    xi(1,1,kk) = E*(-C*xi(1,1,kk-1) + xi(1,1,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*2*(xi(2,1,kk-1) + xi(1,2,kk-1)));
    xi(1,N,kk) = E*(-C*xi(1,N,kk-1) + xi(1,N,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*2*(xi(2,1,kk-1) + xi(1,N-1,kk-1)));
    xi(M,1,kk) = E*(-C*xi(M,1,kk-1) + xi(M,1,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*2*(xi(M-1,1,kk-1) + xi(M,2,kk-1)));
    xi(M,N,kk) = E*(-C*xi(M,N,kk-1) + xi(M,N,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*2*(xi(M-1,N,kk-1) + xi(M,N-1,kk-1)));
    
    % put in side terms
    ii = 2:length(x)-1;
    jj = 2:length(y)-1;
    
    xi(1,jj,kk) = E*(-C*xi(1,jj,kk-1) + xi(1,jj,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*(2*xi(2,jj,kk-1) + xi(1,jj-1,kk-1) + xi(1,jj+1,kk-1)));        
    xi(M,jj,kk) = E*(-C*xi(M,jj,kk-1) + xi(M,jj,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*(2*xi(M-1,jj,kk-1) + xi(M,jj-1,kk-1) + xi(M,jj+1,kk-1) ));    
    xi(ii,1,kk) = E*(-C*xi(ii,1,kk-1) + xi(ii,1,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*(2*xi(ii,2,kk-1) + xi(ii-1,1,kk-1) + xi(ii+1,1,kk-1) ));    
    xi(ii,N,kk) = E*(-C*xi(ii,N,kk-1) + xi(ii,N,kk-2)*(Gamma/h - 1/h^2)   + (v_b/l)^2*(2*xi(ii,N-1,kk-1) + xi(ii-1,N,kk-1) + xi(ii+1,N,kk-1) ));

    % place the rest of the terms
    

    xi(ii,jj,kk) = E*(-C*xi(ii,jj,kk-1) + (Gamma/h - 1/h^2)*xi(ii,jj,kk-2) + (v_b/l)^2*(xi(ii+1,jj,kk-1) + xi(ii,jj+1,kk-1) + xi(ii-1,jj,kk-1) + xi(ii,jj-1,kk-1)));

    xi(:,:,kk) = xi(:,:,kk) + rho_f*E*FDrive(:,:,kk-1);
        
end;

% intial condition for q
q(:,:,1) = zeros(length(x),length(y));

for kk=2:length(t);
    q(:,:,kk) = q(:,:,kk-1) - h*q(:,:,kk-1)*(eta + 1/tau) + xi(:,:,kk-1)*h*Cz*(1/(rho_f*V_0*tau))*(eta*tau - beta + 2)  + (1/rho_f)*(xi(:,:,kk) - xi(:,:,kk-1));
end;

% Now calculate the bold response
boldResponse = V_0*((k2-k3)*xi/(rho_f*V_0) - (k1+k2)*q);

