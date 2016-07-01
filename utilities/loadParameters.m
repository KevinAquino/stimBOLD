
function params = loadParameters(params)

% loadParameters.m
% Kevin Aquino 2014
% This file contains all the parameters relevant to the simulation
% including the physical parameters and also the computational parameters,
% i.e. the numerical accuracy

% ======================================================================
% TODO:
% In the future, this should be replaced with something that reads in a
% text file. This is so that they can be easily distributed. Having a text
% file is better for cross platform too.


% ============== Visual Field and neural parameters =================
% some of these parameters are detailed in the specified visual field representation.

% If you don't define the neural wave speed, then it will be predefined to
% value.
% if(~exist('params.v_n'));
%     params.v_n = 2.5;                      % neural wave speed
% end

if(nargin==1)
    params = refresh_dependent_params(params);
    return
else
    % do nothing;
end

params.z_n = 0.1;                          % neural normalization constant
params.t_0 = 2;                            % start Interval, i.e. when to start the stimulus
% params.stim_time = 2;0.5;                    % how long for each image
% params.isi_time = 0;0.25;                    % how long between each image
%
% params.d_s = params.v_n*(params.isi_time + params.stim_time);   % distance shifted per step to attain a neural wave with the parameters listed above.

% ============== Hemodynamic parameters =====================

params.hemo_model = 1;
params.LBO_model = 'Meyer'; %Cotangent LBO


params.v_b     = 2e-3;
params.Gamma   = 1;

params.eta     = 0.4;
params.tau     = 2;
params.beta    = 3;
params.k1      = 4.2;
params.k2      = 1.7;
params.k3      = 0.41;
params.gam     = 0.41;
params.kappa   = 0.65;
params.rho_f   = 1e3;
params.V_0     = 0.03;
params.Xi_0    = params.rho_f*params.V_0;

params.F_0     = 0.01;

params.L       = 3e-3;
params.k0      = acos(0.8)/(params.L);
params.Cz      = 1e-3/(params.k0^(-1)*sin(params.k0*params.L));
params.D       = params.rho_f*(2*params.Gamma - params.beta/params.tau*params.Cz);

params.k_z = sqrt((params.k0)^2 + 1/(params.v_b)^2*params.Cz*(params.beta/params.tau)*(params.D/params.rho_f));

params.flowNoise = 0;

% ============== Computational parameters ===================

params.t_start = 0;                     % Start time for the simulation
params.t_end = 44+2;                      % End time for the stimulation
params.num_time = 500; % number of time points used in the calculation
% params.dx = 0.5e-3;
% params.dy = params.dx;             % just use this current dx and dy in mm
% params.extra_cortex = 6e-3;             % how many mm of extra cortex in x and in y
% params.y_bounds = 20e-3;                 % the distance from the origin to the max y.
params.plotting = 0;
params.dt = 0.05;
params.time_afterStim = 20;              % right now set to 20 as the default user has to define this.


params.MAX_SCREEN_EC = 5; % i.e. the maximum eccentricity that the screen is, this will be used to normalize it all.
params.polMappingDecay = 1; % This the parameter for the polar mapping decay function - probably should be based on physiology
% need some help on this guy.

% ============== Template Parameters =======================
params.retinotopicTemplate = 'corticalMapping/2014-11-03-Benson_Template.mgz';
params.occpitalPole = 'corticalMapping/savedOcciptalPole.mat';
params.normalizedTemplate = 1;
params.flattenedSurface = 'savedOcciptalPole.mat';

% ============== Neural Modeling parameters =================
params.prf_slope_V2 = 0.5/5.5; % Harvey et al.
params.prf_offset_V2 = 0.2; % Harvey et al.

params.prf_slope_V3 = 2/5.5; % Harvey et al.
params.prf_offset_V3 = 0.3; % Harvey et al.

params.neuralVascularModel = 'inputModel';

params.freesurferpath = 'freesurfer/';

params.neuralGamma = 120; % Taken from data.


end

function params = refresh_dependent_params(params)

% reload dependent parameters - important if we change some parameters like
% velocity or damping, as it will change more parameters along the way.

params.Xi_0    = params.rho_f*params.V_0;
params.k0      = acos(0.8)/(params.L);
params.Cz      = 1e-3/(params.k0^(-1)*sin(params.k0*params.L));
params.D       = params.rho_f*(2*params.Gamma - params.beta/params.tau*params.Cz);
params.k_z = sqrt((params.k0)^2 + 1/(params.v_b)^2*params.Cz*(params.beta/params.tau)*(params.D/params.rho_f));
end