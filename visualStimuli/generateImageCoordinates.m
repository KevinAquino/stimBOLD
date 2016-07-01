function [thmat,rmat] = generateImageCoordinates(nx,ny,params)
% generateImageCoordinates.m
% Kevin Aquino 2014
%
% function here to generate the polar co-ordinates, this is done in this
% fashion to do this independently

% normalization factor to normalize each radial readout from this script
maxRad = min(floor(nx/2),floor(ny/2));
MAX_SCREEN_EC = params.MAX_SCREEN_EC;


normFactor = MAX_SCREEN_EC/maxRad;

x = 1:nx;y=1:ny;
midX = floor(nx/2);
midY = floor(ny/2);

xaxis = (x-midX)*normFactor;
yaxis = (y-midY)*normFactor;

% determine the points, note that xaxis and yaxis are switched at this
% point, because of the way that x and y are defined.
[xx,yy] = meshgrid(yaxis,xaxis);

[thmat,rmat] = cart2pol(xx,yy);

% here i have a flag, since we are dealing with the right hemifield alone,
% we only look at that
rmat(xx<=0) = -1;



thmat = thmat(:);
rmat = rmat(:);

