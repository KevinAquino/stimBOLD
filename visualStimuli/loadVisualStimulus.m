function [visualStimulus,params] = loadVisualStimulus(params)
% loadVisualStimuls loads the images, it supplies a GUI
%
%   Inputs: params, a struct value, it has the following fields
%               useGUI, true or false,
%
%
%   Outputs:
%
%
% EXAMPLE
%
%
% NOTES
% Kevin Aquino, 22-Apr-2014
% SHAO Wenbin, 29-Apr-2014
% UOW, email: wenbin@ymail.com
% History:
% Ver. 22-Apr-2014  1st ed
% Ver. 29-Apr-2014  Add the code for GUI, add help to the function.
% Ver. 01-May-2014  To cope with GUI, move the polar coordinates generation
%                   out.
% Ver. 10-Jun-2014  Move the GUI code outside this function
% Ver. 12-May-2014

  

        
    switch params.visualStimulus
        case 'test'
            
            visualStimulus = imread('Game-of-Thrones-Girlie-T-Shirt-Stark-Logo_b2.jpg');
            % %         visualStimulus = imread('LEGO.jpg');
            %         visualStimulus = imread('Olympic-rings.jpg');
            
            imgTest = double(visualStimulus);
            
            [im_m,im_n,nc, ns] =return_size_stimulus(imgTest, true);
            %             [im_m,im_n,nc] = size(imgTest);
            params.t = 1;
            params.num_stimuli = 1;
            time_indices{1} = 1;
            params.time_indices = time_indices;
            
            visualStimulus_new = ones([im_m,im_n,1,nc]);
            visualStimulus_new(:,:,1,:) = visualStimulus;
            visualStimulus = visualStimulus_new;
            
        case 'savedMaskImage'
            switch params.savedImageType
                case 'wedgeMaskedStimulus'
                    load visualStimuli/WedgeMask.mat
                    visualStimulus = maskImgs;
                    [im_m,im_n,nc, ns] =return_size_stimulus(visualStimulus);
                case 'ringMaskedStimulus'
                    load visualStimuli/RingMask.mat
                    visualStimulus = maskImgs;
                    [im_m,im_n,nc, ns] =return_size_stimulus(visualStimulus);
                case 'shockStimulus'
                    load visualStimuli/shockMask.mat
                    visualStimulus = maskImg;
                    [im_m,im_n,nc, ns] =return_size_stimulus(visualStimulus);
                    params.stim_time = d_s/params.v_n;
            end
            
            num_stimuli = ns;
            params.num_stimuli = ns;
            isi_time = params.isi_time;
            stim_time = params.stim_time;
            params.dt = 0.05;
            t = params.t_start:params.dt:params.t_end;
            params.t = t;
            
            t_0 = params.t_0;
            
            % here is the time index.
            for ns=1:num_stimuli
                time_indices{ns} = find((t>(t_0 + (isi_time + stim_time)*(ns-1) )).*(t<(t_0 + stim_time + (isi_time + stim_time)*(ns-1)) ));
            end;
            
            params.time_indices = time_indices;
            
            
    end




% move this function out
% now code here to load the thmat and rmat vectors used to transform images
% into cortical space.
% [thmat,rmat] = generateImageCoordinates(nx,ny,params);
