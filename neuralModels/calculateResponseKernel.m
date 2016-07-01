function responseKernel = calculateResponseKernel(params)
% calculateResponseKernel.m
% Kevin Aquino 2014
%
% This code is here to calculate the response kernel used to convolve the
% contrast response with.
%
% This is a simple linear convolution model to determine the neural
% response, however this can be made more complicated in future. 

t_kern = -1:params.dt:1;


% Old version
responseKernel = ((t_kern<0.5).*(t_kern>=0))/0.5;

% responseKernel = 1;

% 
% % tester:
% t_upsamp = linspace(-1,1,1000);
% 
% [t,y] = ode45(@(t,y) temporalNeuralField(t,y,params),t_upsamp,[0 0]);
% 
% responseKernel = interp1(t_upsamp,y(:,1),t_kern);