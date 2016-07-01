% ODEs for the BOLD response, taken from FRISTON et al. paper, just here to
% use a regressor

function out = boldeqtnsPulse(t,y)%,times,zfunc)

times = -100:0.001:100;
zfunc = (times<=0.5).*(times>=0);


%== ODES for the bold response
k = 0.65;
gam = 0.41;

tau = 0.98;
alpha = 0.32;
rho = 0.34;

% z = the input that we use for the input neural function!
z = interp1(times,zfunc,t);

s = z - k*y(1) - gam*(y(2) - 1);
F = y(1);
v = 1/tau*(y(2) - y(3)^(1/alpha));
q = 1/tau*(y(2)*(1 - (1 - rho)^(1/y(2)))/rho - y(3)^(1/alpha)*y(4)/y(3));

out = [s, F, v, q]';

