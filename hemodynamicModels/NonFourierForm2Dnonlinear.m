function [Yxt] = NonFourierForm2Dnonlinear(spacex,spacey,time,zxt)
% Function to calculate the nonlinear hemodynamic wave equation
% Kevin Aquino and Thomas Lacy 2014


Nt = length(time);
deltat = mean(diff(time));
deltax = mean(diff(spacex));
deltay = mean(diff(spacey));

% hemodynamicConstants
parameterList
% beta = 3;
beta = 3;
% These parameters depend on the parameters that you specify
c2 = 10^4*(Xi_0^(-beta));
P_0 = c2*Xi_0^(beta);
c_p = F_0/P_0;



%T_z = 0.008;
k_0 = acos(0.8)/L;
C_z = L*k_0/sin(k_0*L);

c1 = v_b^2/(c2*beta*Xi_0^(beta-1));

% c1 = 4e-9;


% v_b = sqrt(c1*c2*beta*Xi_0^(beta-1));


C = deltat*v_b/deltax+deltat*v_b/deltay;

A_1 = 1/k_0/L*sin(k_0*L);
cosk0l = cos(k_0*[0:L/100000:L]).^(beta);
A_2 = sum(cosk0l)/100000;
A_b = A_2/A_1;

B_b = beta*k_0^2*(cos(k_0*L))^(beta-1);
C_p = F_0/P_0 - B_b*c1/D/C_z;
k_z = D*C_z*C_p + B_b*c1;




% [yy xx tt] = meshgrid(spacey, spacex, time);

% zxt = 0.028/1.21/6*(exp(-((xx-tt.*v_b.*v_wave).^2+yy.^2)/spread.^2/2)).*(tt<=signal_time).*(tt>=0);



Fxt = 0*meshgrid(spacey, spacex, [0 0]);
Zxt = 0*meshgrid(spacey, spacex, [0 0])+Xi_0;
P = 0*meshgrid(spacey, spacex, [0 0])+P_0;
Pderiv = 0*meshgrid(spacey,spacex);



Fxtmax = 0;
Zxtmin = Xi_0;
Zxtmax = Xi_0;

for a = 3:Nt;
    Fxt = cat(3, Fxt(:,:,2), (zxt(:,:,a)*deltat^2+Fxt(:,:,2)*(2-gam*deltat^2)+Fxt(:,:,1)*(kappa*deltat/2-1))/(1+kappa*deltat/2));
    P = c2*Zxt(:,:,2).^beta;
    Pderiv = padarray(diff(diff(P)),[1,0])/deltax^2+(padarray(diff(diff(P')),[1,0]))'/deltay^2;
    Zxt = cat(3,Zxt(:,:,2),(2*Zxt(:,:,2)/deltat^2+Zxt(:,:,1).*(-1/deltat^2+1/2/deltat*(D/rho_f+rho_f*C_z*C_p*c2*beta*Zxt(:,:,2).^(beta-1)))-k_z*c2*Zxt(:,:,2).^beta+A_b*c1*Pderiv+D*(Fxt(:,:,2)+F_0)*C_z+C_z*rho_f/deltat.*(Fxt(:,:,2)-Fxt(:,:,1)))./(1/deltat^2+(D/rho_f+C_z*rho_f*C_p*c2*beta*Zxt(:,:,2).^(beta-1))/2/deltat));
    Fxtmax = max(Fxtmax,max(max(max(Fxt))));
    Zxtmin = min(Zxtmin,min(min(min(Zxt))));
    Zxtmax = max(Zxtmax,max(max(max(Zxt))));       
    
    xit = Zxt - Xi_0;    
    Fxtout(:,:,a) = Fxt(:,:,1);
    Xixtout(:,:,a) = Zxt(:,:,1);
end

% Calculate dependet variables such as the velocity field, derived form the
% wave equation and boundary conditions
[Nx Ny Nt] = size(Fxtout);

[yy xx] = meshgrid(spacey, spacex);


% no calculate the nonlinear q equation. Do so in two steps:

% Step 1. Calculate the flow velocity terms

Pxtout = c2*Xixtout.^beta;
[v_Fx v_Fy] = calculateVelocityConditions(xx,yy,Fxtout,Nx,Ny,Nt);
[v_Px v_Py] = calculateVelocityConditions(xx,yy,-c_p*Pxtout,Nx,Ny,Nt);

vx = zeros(Nx,Ny,Nt);vy = vx;

for kk=2:Nt,    
    [Py Px] = gradient(Pxtout(:,:,kk),deltay,deltax);
    vx(:,:,kk) = - c1*deltat/rho_f*Px + vx(:,:,kk-1)*(-D/rho_f*deltat + 1);
    vy(:,:,kk) = - c1*deltat/rho_f*Py + vy(:,:,kk-1)*(-D/rho_f*deltat + 1);
end


% now use thse in the nonlinear q equation.

Q_0 = 0.028; % this is close the value, need to recheck this value against experiment. this corresponds to 30mm mol kg-1
psi = 0.0018; % This makes Q in terms of mol kg-1
Qout = zeros(Nx,Ny,Nt);
Qout(:,:,3) = Q_0*ones(Nx,Ny);

for kk=4:Nt, % we can't start from the value we have have at the beginning, since we start off with 0
    % calculate the gradients
    Qx = Qout(:,:,kk-1).*(vx(:,:,kk-1) - v_Fx(:,:,kk-1) - v_Px(:,:,kk-1) );
    Qy = Qout(:,:,kk-1).*(vy(:,:,kk-1) - v_Fy(:,:,kk-1) - v_Py(:,:,kk-1) );
    
    [Qxy Qxx] = gradient(Qx,deltay,deltax);
    [Qyy Qyx] = gradient(Qy,deltay,deltax);
    
    divQv = Qxx + Qyy;
    
    Qout(:,:,kk) = Qout(:,:,kk-1) - deltat*(divQv) + deltat*(Xixtout(:,:,kk-1)*psi - Qout(:,:,kk-1))*eta - deltat*c_p*Pxtout(:,:,kk-1).*Qout(:,:,kk-1)./(Xixtout(:,:,kk-1)/rho_f);
end

% currently I dont have the right Q_0 it will have to be calculated from
% the equations, i.e. the value at rest. The averaging of Q in the z
% direction is also needed, this will be done shortly. This here can be
% used as a first pass.

% Now calculate Y properly.
Yxt = V_0*(k1*(1-Qout/Q_0)+k2*(1-rho_f*V_0*Qout/Q_0./Xixtout)+k3*(1-Xixtout/rho_f/V_0));



Yxtout = 0;

Fnormalization = Fxtmax/F_0+1;
Xinormalization = Zxtmax/Xi_0;
Xilowernormalization = Zxtmin/Xi_0;


end


