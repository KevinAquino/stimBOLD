function out = dendriticNeuralField(t,y,params,zeta)

gam = params.neuralGamma;


z = interp1(params.t,zeta,t);
% z = (t>0.01)*(t<0.05);


out(1) = y(2);
out(2) = - 2*gam*y(2) - gam^2*y(1) + gam^2*z;

out = out.';