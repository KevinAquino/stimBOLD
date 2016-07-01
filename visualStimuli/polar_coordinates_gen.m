function [thmat,rmat] = polar_coordinates_gen(nx,ny,params)
% generateImageCoordinates.m
% Kevin Aquino 2014
%
% function here to generate the polar co-ordinates, this is done in this
% fashion to do this independently
% NOTES
% SHAO Wenbin, 01-May-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 08-May-2014  Add GUI flag
% Ver. 09-Jul-2014  Add error check when user cancel the parameter input

% normalization factor to normalize each radial readout from this script
if params.useGUI
    if ~isfield(params, 'MAX_SCREEN_EC')
        prompt ={'MAX\_SCREEN\_EC'};
        def ={'5'};
        dlgTitle='Parameters for Polar coordinates';
        largest_question_length = size((char(prompt')),2);
        lineNo=[1,largest_question_length+5];
        AddOpts.Resize='on';
        AddOpts.WindowStyle='normal';
        AddOpts.Interpreter='tex';
        answer=inputdlgcol(prompt,dlgTitle,lineNo,def,AddOpts,5);
        if ~isempty(answer)
            params.MAX_SCREEN_EC =str2double(answer{1});
        else
            params.MAX_SCREEN_EC =5;
        end
    end
end


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

