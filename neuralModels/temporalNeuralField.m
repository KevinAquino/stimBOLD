function out = temporalNeuralField(t,y,params)

gam = params.neuralGamma;

z = (t>0.1)*(t<0.2);

a = 80;1/0.00060;
b = 10;1/0.000100;


out(1) = y(2);
out(2) = - a*b*(1/a + 1/b)*y(2) - a*b*y(1) + a*b*z;

out = out.';