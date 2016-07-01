function [upsampledResponse,ecSampledPoints,polSampledPoints] = upsampleResponse(neuralResponse,retinotopicTemplate,visualArea)
% This function upsamples the response with respect to eccentricity and
% polar angle in order to calculate receptive field responses. This
% probably should be worked on surface space instead, however the available
% templates do not cover enough regions, in future they will be able to do
% so.
%

switch visualArea
    case 'v1'                
        
        
        [xx,yy] = pol2cart((retinotopicTemplate.polarAreas.v1),retinotopicTemplate.eccentricityAreas.v1);
        TRI = delaunay(xx,yy);
        xx = xx(:);
        yy = yy(:);
        xx_centroid = mean(xx(TRI),2).';
        yy_centroid = mean(yy(TRI),2).';
%         
%         [th,ec] = cart2pol(xx_centroid,yy_centroid);
%         
%         ecSampledPoints = [retinotopicTemplate.eccentricityAreas.v1;ec.'];
%         polSampledPoints = (180/pi)*([retinotopicTemplate.polarAreas.v1;th.'] + pi/2);
%         
%         startPt = 0;
%         endPt   = 90;
%         d = 100;
%         
%         P = polyfit([1 100],[startPt,endPt],4);
%         N = 1:100;
% %         v1EC = logspace(log10(0.2),log10(90),N);
%         v1EC = polyval(P,N);
%         v1POL = linspace(0,180,101);
%         [ecc,poll] = meshgrid(v1EC,v1POL);                
        
%         ecSampledPoints = ecc(:);
%         polSampledPoints = poll(:);
        
%         TRI = delaunay(retinotopicTemplate.eccentricityAreas.v1,rad2deg(retinotopicTemplate.polarAreas.v1+pi/2));
%         
%         ecVal = retinotopicTemplate.eccentricityAreas.v1;
%         polVal = rad2deg(retinotopicTemplate.polarAreas.v1+pi/2);
%         ec_centroid = mean(ecVal(TRI),2).';
%         pol_centroid = mean(polVal(TRI),2).';
%         ecSampledPoints = [ecVal;ec_centroid.'];
%         polSampledPoints = [polVal;pol_centroid.'];
        % CENTROID! DO IT ON THIS
        
%         [Vs, Fs]=perform_tri_subdivision([retinotopicTemplate.eccentricityAreas.v1,rad2deg(retinotopicTemplate.polarAreas.v1+pi/2)], TRI, 1);
%         
%         F = TriScatteredInterp();        
% %         F.DT = delaunay([retinotopicTemplate.eccentricityAreas.v1,rad2deg(retinotopicTemplate.polarAreas.v1+pi/2)]);        
%         F.X = [retinotopicTemplate.eccentricityAreas.v1,rad2deg(retinotopicTemplate.polarAreas.v1+pi/2)]; 
%         F.Method = 'natural';
%         tic
%         for nt = 1:size(neuralResponse,1),
%             F.V = full(neuralResponse(nt,:)).';
%             upsampledResponse(nt,:) = F(ecSampledPoints,polSampledPoints);
%         end
%         toc
        
        xx_new = [xx;xx_centroid.'];
        yy_new = [yy;yy_centroid.'];

        F = TriScatteredInterp();
%         F.DT = delaunay([retinotopicTemplate.eccentricityAreas.v1,rad2deg(retinotopicTemplate.polarAreas.v1+pi/2)]);        
        F.X = [xx,yy]; 
        F.Method = 'natural';
        tic
        for nt = 1:size(neuralResponse,1),
            F.V = full(neuralResponse(nt,:)).';
            upsampledResponse(nt,:) = F(xx_new,yy_new);
        end
        toc
        
        % Transform to polar co-ordinates
        [th,ec] = cart2pol(xx_new,yy_new);        
        ecSampledPoints = ec.';
        polSampledPoints = (180/pi)*(th.' + pi/2);

        
    case 'v2d'
    case 'v2v'
    case 'v3d'        
    case 'v3v'
end
end


