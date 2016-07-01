% displaySummaryGUI.m
%
% This function displays the summary figure, i.e. it draws
% everything onto the GUI and used for the simulation outputs
function plotHandles = interactive_visualization(stimBOLD_output,parent)

% check that stimBOLD_output makes sense --
% function here.

if(nargin<2)
    % If the figure is not there then add it in.
    position = [60 25 100 60];
    parent = figure('Units','Character','OuterPosition', position,'Renderer','zbuffer');
end

% This calculation to find out the ratio of the height to the width for
% units character

position = get(parent,'Position');
set(parent,'Units','Pixel');
pxpos = get(parent,'Position');
Y = pxpos(4)/position(4);
X = pxpos(3)/position(3);
heightToWidthRatio = Y/X;
stimBOLD_output.heightToWidthRatio = heightToWidthRatio;

set(parent,'Units','Character');


% first make the figure with zero colors

% then check iteratively if there is any data to be added, then add in the
% data if there is any, if there isnt any, then don't add anything and set
% to zero.

% first initalize the figure with the function below:
[plotHandles,stimBOLD_output] = intializeFigure(stimBOLD_output,parent);

% now update but check first if there is any data to update - this is
% better and can be used to control thresholding if that is a feature that
% we want to have..

%

% update the neural Function
if(isfield(stimBOLD_output,'zeta'));
    mZeta = mean(stimBOLD_output.zeta,1);
    plotHandles.neural_fig_params.range = [min(mZeta) max(mZeta)];
    [plotHandles.neural_fig_params] =  updateFlatMesh(stimBOLD_output.msh,plotHandles.neural_fig_params,mZeta);
end


if(isfield(stimBOLD_output,'BOLD'));
    mBOLD = mean(stimBOLD_output.BOLD,1);
    plotHandles.BOLD_fig_params.range = [min(mBOLD) max(mBOLD)];
    [plotHandles.BOLD_fig_params] =  updateFlatMesh(stimBOLD_output.msh,plotHandles.BOLD_fig_params,mBOLD);
end


% now add the cursor functions


GUI_data = guidata(parent);
GUI_data.stimBOLD_output = stimBOLD_output;


GUI_data.plotHandles = plotHandles;

guidata(parent,GUI_data);

% Set the click callback for the flattened maps
set(plotHandles.mapping_fig_params.figHandle,'ButtonDownFcn',@getCursorFlat);
set(plotHandles.mapping_area_fig_params.figHandle,'ButtonDownFcn',@getCursorFlat);
set(plotHandles.neural_fig_params.figHandle,'ButtonDownFcn',@getCursorFlat);
set(plotHandles.BOLD_fig_params.figHandle,'ButtonDownFcn',@getCursorFlat);


% Now draw the retinal response:
update_retinalResponse(parent);

% Here set the callbacks for the time plots
set(plotHandles.a1,'ButtonDownFcn',@getCursorTimePlots);
set(plotHandles.a2,'ButtonDownFcn',@getCursorTimePlots);
set(plotHandles.retinalResponse,'ButtonDownFcn',@getCursorTimePlots);


set(parent,'ResizeFcn',@resizeFunction);

resizeFunction(parent,[]);
end


function [plotHandles,stimBOLD_output] = intializeFigure(stimBOLD_output,parent)

plotHandles.visInput = axes('Parent',parent,'Units','Character','position',[5 40 32 11]);

% imshow(rand(100),'Parent',plotHandles.visInput);

imshow(stimBOLD_output.visual_stimulus{2},'Parent',plotHandles.visInput);


% Show the retinal response at a particular eccentricty and polar angle.

plotHandles.retinalResponse = axes('Parent',parent,'Units','Character','position',[5+32+5+5 40 100-32-20-5 11]);

% intialize the surface - Don't add the surface in
% plotHandles.surface = axes('Parent',parent,'Units','Character','position',[5 17 55 20]);

%
% surface_figParams.figView = [60 10];
% surface_figParams.figParentAxis =  plotHandles.surface;
% surface_figParams.range = [0 0];
% surface_figParams.thresh = 1;

data = zeros(size(stimBOLD_output.msh.submesh.mappedInds));

% [surface_figParams] = updateSurface(stimBOLD_output.msh,surface_figParams,data);
% plotHandles.surface_figParams = surface_figParams;


% initialize Mapping Flat Surface

% first, load the retinotopic map
% [stimBOLD_output.msh.submesh.visualAreas,stimBOLD_output.msh.submesh.ecMap,stimBOLD_output.msh.submesh.polMap] = load_v1_v2_v3_area_Masks(stimBOLD_output.params);
[msh,retinotopicTemplate] = load_cortical_template(stimBOLD_output.params);

stimBOLD_output.msh.submesh.visualAreas = retinotopicTemplate.visualAreas;
stimBOLD_output.msh.submesh.ecMap = retinotopicTemplate.eccentricityAreas;
stimBOLD_output.msh.submesh.polMap = retinotopicTemplate.polarAreas;

% [stimBOLD_output.msh.submesh.visualAreas,stimBOLD_output.msh.submesh.ecMap,stimBOLD_output.msh.submesh.polMap] = load_v1_v2_v3_area_Masks(stimBOLD_output.params);
[stimBOLD_output.msh] = transferMappingToSubmesh(stimBOLD_output.msh);


posVector = get(parent,'position');
timeSeriesPanelWidth = 25;
width = (posVector(3) - 30 - timeSeriesPanelWidth)/2;
height = (posVector(4) - 10)/3;


% load in the flattened map (premade)
% stimBOLD_output.msh.flatCoord = flatCoord;


% then initialize the Mapping surface
plotHandles.mappingFlat = axes('Parent',parent,'Units','Character','position',[5 5 width height],'HitTest','off');
mapping_fig_params.figParentAxis = plotHandles.mappingFlat;
mapping_fig_params.map = 'ecMap';
mapping_fig_params.range = [0.02,stimBOLD_output.params.MAX_SCREEN_EC];
[mapping_fig_params] = updateFlatMesh(stimBOLD_output.msh,mapping_fig_params,[]);
plotHandles.mapping_fig_params = mapping_fig_params;

plotHandles.areasFlat = axes('Parent',parent,'Units','Character','position',[10+width 5 width height],'HitTest','off');
mapping_area_fig_params.figParentAxis = plotHandles.areasFlat;
mapping_area_fig_params.map = 'areaMap';
mapping_area_fig_params.colorMap = 'jet';
[mapping_area_fig_params] = updateFlatMesh(stimBOLD_output.msh,mapping_area_fig_params,[]);
plotHandles.mapping_area_fig_params = mapping_area_fig_params;


% initialize Neural Flat Surface
plotHandles.neuralFlat = axes('Parent',parent,'Units','Character','position',[5 5+height width height]);
neural_fig_params.figParentAxis = plotHandles.neuralFlat;
neural_fig_params.colorMap = 'jet';
[neural_fig_params] = updateFlatMesh(stimBOLD_output.msh,neural_fig_params,[]);
plotHandles.neural_fig_params = neural_fig_params;

% initialize BOLD Flat Surface
plotHandles.BOLDFlat = axes('Parent',parent,'Units','Character','position',[10+width 5+height width height]);
BOLD_fig_params.figParentAxis = plotHandles.BOLDFlat;
BOLD_fig_params.colorMap = 'jet';
[BOLD_fig_params] = updateFlatMesh(stimBOLD_output.msh,BOLD_fig_params,[]);
plotHandles.BOLD_fig_params = BOLD_fig_params;


% intialize the mean Plots


v1Co = stimBOLD_output.msh.submesh.visualAreas.v1;
v2Co = stimBOLD_output.msh.submesh.visualAreas.v2;
v3Co = stimBOLD_output.msh.submesh.visualAreas.v3;


zMeanV1V2V3 = mean(stimBOLD_output.zeta(:,unique([v1Co;v2Co;v3Co(:)])),2);
BOLDMeanV1V2V3 = mean(stimBOLD_output.BOLD(:,unique([v1Co;v2Co;v3Co(:)])),2);

% normZ = max(zMeanV1V2V3);
% normB = max(BOLDMeanV1V2V3);

normZ = max(stimBOLD_output.zeta(:));
normB = max(stimBOLD_output.BOLD(:));

% BOLDMeanV1 = mean(stimBOLD_output.BOLD(:,v1Co),2)/normB;
% BOLDMeanV2 = mean(stimBOLD_output.BOLD(:,v2Co),2)/normB;
% BOLDMeanV3 = mean(stimBOLD_output.BOLD(:,v3Co),2)/normB;
%
% zMeanV1 = mean(stimBOLD_output.zeta(:,v1Co),2)/normZ;
% zMeanV2 = mean(stimBOLD_output.zeta(:,v2Co),2)/normZ;
% zMeanV3 = mean(stimBOLD_output.zeta(:,v3Co),2)/normZ;

stimBOLD_output.normB = normB;
stimBOLD_output.normZ = normZ;


stimBOLD_output.neural_ylim = abs(max(stimBOLD_output.zeta(:)))*[-1,1];
stimBOLD_output.BOLD_ylim   = abs(max(stimBOLD_output.BOLD(:)))*[-1,1];

plotHandles.timeSeriesPanel = uipanel('Units','Character','Position',[20+2*width 5 timeSeriesPanelWidth 37-5],'Parent',parent);

plotHandles.a1 = subplot(2,1,1,'Parent',plotHandles.timeSeriesPanel);
plotHandles.a2 = subplot(2,1,2,'Parent',plotHandles.timeSeriesPanel);
% plotHandles.a3 = subplot(3,1,3,'Parent',plotHandles.timeSeriesPanel);

%         subplot(4,1,4,'Parent',plotHandles.timeSeriesPanel);
% 
neural = zMeanV1V2V3;
bold = BOLDMeanV1V2V3;
% % neural.v1 = zMeanV1;neural.v2 = zMeanV2;neural.v3 = zMeanV3;
% % bold.v1 = BOLDMeanV1;bold.v2 = BOLDMeanV2;bold.v3 = BOLDMeanV3;
% 
displayTimeSeries(stimBOLD_output.params.t,neural,bold,'Mean',[plotHandles.a1 plotHandles.a2]);

% initialization of the values for the plot.
plotHandles.currentStateTimePlots.ec = [];
plotHandles.currentStateTimePlots.pol = [];
plotHandles.currentStateTimePlots.vis = [];
plotHandles.currentStateTimePlots.vertex = [];
plotHandles.currentStateTimePlots.index = 1;
plotHandles.currentStateTimePlots.action = 'mean';


end
%
% function [figParams] = updateSurface(msh,figParams,data)
% % this will force a recolor of the surfaces/images
% [msh,figParams] = display_sim_movie_matlab(data,msh,figParams.range,1,figParams.thresh,'original',figParams);
%
% end

function [figParams] = updateFlatMesh(msh,figParams,data)

% here we have a case that if we have the "mapping" function, then
% change the data source to the appropriate map.

% These lines of code are there just incase there is a
% pre-defined range, will happen if the user wants to adjust
% the range of the mapping (future feature).
storedFigParams = struct;

if(isfield(figParams,'range'))
    storedFigParams.range = figParams.range;
end

if(isfield(figParams,'maxClip'))
    storedFigParams.maxClip = figParams.maxClip;
end

if(isfield(figParams,'minClip'))
    storedFigParams.minClip = figParams.minClip;
end

if(isfield(figParams,'map'))
    
    
    data = 1000*ones(size(msh.submesh.mappedInds));
    switch figParams.map
        case 'polMap'
            data(msh.submesh.visualAreas.v1) = msh.submesh.polMap.v1;
            data(msh.submesh.visualAreas.v2) = msh.submesh.polMap.v2;
            data(msh.submesh.visualAreas.v3) = msh.submesh.polMap.v3;
            figParams.range = [-pi/2 pi/2];
            figParams.minClip = [-pi/2];
            figParams.maxClip = [pi/2];
            
        case 'ecMap'
            data(msh.submesh.visualAreas.v1) = msh.submesh.ecMap.v1;
            data(msh.submesh.visualAreas.v2) = msh.submesh.ecMap.v2;
            data(msh.submesh.visualAreas.v3) = msh.submesh.ecMap.v3;
            figParams.range = [0.02 6];
            figParams.minClip = [0.01];
            figParams.maxClip = [90];
            
        case 'areaMap'
            data(msh.submesh.visualAreas.v1) = msh.submesh.visTag.v1;
            data(msh.submesh.visualAreas.v2) = msh.submesh.visTag.v2;
            data(msh.submesh.visualAreas.v3) = msh.submesh.visTag.v3;
            figParams.range = [-3 5];
            figParams.minClip = [1];
            figParams.maxClip = [3];
    end
    
end

% now check if anything has been stored, if it has overwrite what
% has defined in the mapping

if(isfield(storedFigParams,'range'))
    figParams.range = storedFigParams.range;
end
if(isfield(storedFigParams,'maxClip'))
    figParams.maxClip = storedFigParams.maxClip;
end
if(isfield(storedFigParams,'minClip'))
    figParams.minClip = storedFigParams.minClip;
end

% this is now the drawing function.
[msh,figParams] = display_sim_movie_flat(data,msh,figParams);
end


function [msh] = transferMappingToSubmesh(msh)

counter = 1;
areaCodes = {'v1','v2','v3'};
for vis = 1:length(areaCodes);
    va = areaCodes{vis};
    eval(['coords = msh.submesh.visualAreas.' va ';']);
    [nold,coords] = find(msh.submesh.fullToSub(coords,:));
    eval(['msh.submesh.visualAreas.' va ' = coords;']);
    
    eval(['msh.submesh.ecMap.' va ' = msh.submesh.ecMap.' va '(nold);']);
    eval(['msh.submesh.polMap.' va ' = msh.submesh.polMap.' va '(nold);']);
    visTagInArea = counter*ones(size(coords));
    eval(['msh.submesh.visTag.' va ' = visTagInArea;']);
    counter = counter + 1;
end

end

% here make an anyonomous function to store all the visualization

% here getting the cursor position for the flat
function getCursorFlat(hObject,~)

% pos=get(hObject,'CurrentPoint');
% find nearest vertex

curPoint = get(get(hObject,'Parent'),'CurrentPoint');

GUI_data = guidata(get(hObject,'Parent'));

stimBOLD_output = GUI_data.stimBOLD_output;
plotHandles = GUI_data.plotHandles;

point = curPoint(1,1:2);

[ec,pol,vis,vertex] = getEccentricity(point,'flat',get(hObject,'Parent'));

currentStateTimePlots = plotHandles.currentStateTimePlots;

currentStateTimePlots.ec = ec;
currentStateTimePlots.pol = pol;
currentStateTimePlots.vis = vis;
currentStateTimePlots.vertex = vertex;
currentStateTimePlots.action = 'Regular';



update_time_series_plot(currentStateTimePlots,get(hObject,'Parent'));

plotHandles.currentStateTimePlots = currentStateTimePlots;

GUI_data.plotHandles = plotHandles;
guidata(get(hObject,'Parent'),GUI_data);

% now that we have the point will have to see what the EC is?

% ind = dsearch(,Y,TRI,XI,YI)

end


% here getting the cursor position for the flat
function getCursorTimePlots(hObject,~)

% pos=get(hObject,'CurrentPoint');
% find nearest vertex

curPoint = get(hObject,'CurrentPoint');

GUI_data = guidata(get(hObject,'Parent'));


stimBOLD_output = GUI_data.stimBOLD_output;
plotHandles = GUI_data.plotHandles;

point = curPoint(1,1:2);

% Find the time index
index = dsearchn(stimBOLD_output.params.t.',point(1));

% Save this information for later use.
plotHandles.currentStateTimePlots.index = index;

% Update the current plots
update_time_series_plot(plotHandles.currentStateTimePlots,get(hObject,'Parent'));

% Update the image plot

GUI_data.plotHandles = plotHandles;
guidata(get(hObject,'Parent'),GUI_data);

% now update the BOLD flat Response.
% But, now change some stuff in the BOLD flat fig Params

maxB = max(stimBOLD_output.BOLD(:));
minB = min(stimBOLD_output.BOLD(:));
plotHandles.BOLD_fig_params.maxClip = maxB;
plotHandles.BOLD_fig_params.minClip = minB;
plotHandles.BOLD_fig_params.range = [minB maxB];

[plotHandles.BOLD_fig_params] = updateFlatMesh(stimBOLD_output.msh,plotHandles.BOLD_fig_params,stimBOLD_output.BOLD(index,:));

% do the same for the flat response

maxN = max(stimBOLD_output.zeta(:));
minN = min(stimBOLD_output.zeta(:));
plotHandles.neural_fig_params.maxClip = maxN;
plotHandles.neural_fig_params.minClip = minN;
plotHandles.neural_fig_params.range = [minN maxN];

[plotHandles.neural_fig_params] = updateFlatMesh(stimBOLD_output.msh,plotHandles.neural_fig_params,stimBOLD_output.zeta(index,:));



% disp(point);

end

function [ec,pol,vis,vertex] = getEccentricity(point,view,parent)

ec = [];
pol = [];
vis = [];

switch view
    case 'flat'
        % if we are in one of the flattened representations
        GUI_data = guidata(parent);
        
        stimBOLD_output = GUI_data.stimBOLD_output;
        plotHandles = GUI_data.plotHandles;
        K = dsearchn(stimBOLD_output.msh.flatCoord,stimBOLD_output.msh.submesh.triangles.'+1,point);
        vertex = K(1);
        % now find which area the click is from.
        visAreas = struct2cell(stimBOLD_output.msh.submesh.visualAreas);
        ecMap = struct2cell(stimBOLD_output.msh.submesh.ecMap);
        polMap = struct2cell(stimBOLD_output.msh.submesh.polMap);
        
        for vs = 1:3,
            pt = find(visAreas{vs} == vertex);
            if(~isempty(pt))
                vis = vs;
                pol = polMap{vs}(pt);
                ec = ecMap{vs}(pt);
                break
            end
        end
end


end

function update_time_series_plot(currentStateTimePlots,parent)


ec = currentStateTimePlots.ec;
pol = currentStateTimePlots.pol;
vis = currentStateTimePlots.vis;
vertex = currentStateTimePlots.vertex;
index = currentStateTimePlots.index;

% updates the time series plots based on the vertex that is loaded.
GUI_data = guidata(parent);

stimBOLD_output = GUI_data.stimBOLD_output;
plotHandles = GUI_data.plotHandles;

visAreas = struct2cell(stimBOLD_output.msh.submesh.visualAreas);
ecMap = struct2cell(stimBOLD_output.msh.submesh.ecMap);
polMap = struct2cell(stimBOLD_output.msh.submesh.polMap);

if(strcmp(currentStateTimePlots.action,'mean'))
    
    
    v1Co = stimBOLD_output.msh.submesh.visualAreas.v1;
    v2Co = stimBOLD_output.msh.submesh.visualAreas.v2;
    v3Co = stimBOLD_output.msh.submesh.visualAreas.v3;

    
    zMeanV1V2V3 = mean(stimBOLD_output.zeta(:,unique([v1Co;v2Co;v3Co(:)])),2);
    BOLDMeanV1V2V3 = mean(stimBOLD_output.BOLD(:,unique([v1Co;v2Co;v3Co(:)])),2);
    displayTimeSeries(stimBOLD_output.params.t,zMeanV1V2V3,BOLDMeanV1V2V3,'Mean',[plotHandles.a1 plotHandles.a2],[],[],1);
else

    % this finds the eccentricity closest in all the visual areas with the
    % specified ec and pol. This should probably be replaced at one point to
    % reflect the mapping used, as we have receptive field sizes etc in
    % action.
    if(~isempty(ec))
        for va = setdiff(1:3,vis),
            dist = sqrt(((ecMap{va}-ec).^2 + (polMap{va}-pol).^2));
            [Y] = find(dist == min(dist));
            vertices(va) = Y;           
        end        
        if(~isempty(vertex))
            vertices(vis) = vertex;
        end
        neural = stimBOLD_output.zeta(:,vertices(vis));
        bold = stimBOLD_output.BOLD(:,vertices(1));                
        displayTimeSeries(stimBOLD_output.params.t,neural,bold,['V' num2str(vis)],[plotHandles.a1 plotHandles.a2],stimBOLD_output.neural_ylim,stimBOLD_output.BOLD_ylim,1);
        
        
    else
        
        neural = stimBOLD_output.zeta(:,vertex);
        bold = stimBOLD_output.BOLD(:,vertex);        
        displayTimeSeries(stimBOLD_output.params.t,neural,bold,'',[plotHandles.a1 plotHandles.a2],stimBOLD_output.neural_ylim,stimBOLD_output.BOLD_ylim,1);
    end
    
    
end;


% Now update this function, currently just refreshes, but may change in
% future.
update_retinalResponse(parent);


allTimeAxes = [plotHandles.retinalResponse,plotHandles.a1,plotHandles.a2];
for tAxis = allTimeAxes;
%     hold(tAxis,'on');
    lh = line([stimBOLD_output.params.t(index) stimBOLD_output.params.t(index)],get(tAxis,'Ylim'),'Color','m','lineStyle','--','Parent',tAxis);
    set(lh,'HitTest','off');
%     hold(tAxis,'off');
end



end

function out = normalizeTS(timeSeries,normFact)
if(nargin<2)
    normFact = max(timeSeries);
end

out = timeSeries/normFact;
end

function update_retinalResponse(parent)
GUI_data = guidata(parent);
stimBOLD_output = GUI_data.stimBOLD_output;
plotHandles = GUI_data.plotHandles;
cla(plotHandles.retinalResponse);
line_data = line(stimBOLD_output.params.t,mean(stimBOLD_output.retinal_response,1),'Parent',plotHandles.retinalResponse);
set(line_data,'HitTest','off');
xlim(plotHandles.retinalResponse,[stimBOLD_output.params.t(1) stimBOLD_output.params.t(end)]);
xlabel('time (s)','FontSize',14,'Parent',plotHandles.retinalResponse);
ylabel('Retinal Contrast Response','FontSize',14,'Parent',plotHandles.retinalResponse);
set(plotHandles.retinalResponse,'fontSize',14);
end


function resizeFunction(hObject,~)

% disp('Changing a size')

%Setting different sizes for gui data

GUI_data = guidata(hObject);
outerPosition = get(hObject,'Position');

parentWidth = outerPosition(3);
parentHeight = outerPosition(4);
plotHandles = GUI_data.plotHandles;

% retPos = plotHandles.retinalResponse;
retPos = [(parentWidth)*0.47 (parentHeight)*0.66 0.5*parentWidth 0.18*parentHeight];
% retPos = [47 40 0.4*parentWidth 11];
set(plotHandles.retinalResponse,'Position',retPos);

leftOverSpace = parentWidth-retPos(1)- retPos(3);

%reset all the sizes for the flat surfaces


timeSeriesPanelWidth = 0.3*parentWidth;




% width = (parentWidth - timeSeriesPanelWidth - timeSeriesPanelWidth)/2;

width = min(GUI_data.stimBOLD_output.heightToWidthRatio*parentHeight*0.8/3,(parentWidth - timeSeriesPanelWidth- timeSeriesPanelWidth)/2);


height = width/GUI_data.stimBOLD_output.heightToWidthRatio;%(parentHeight - 10)/3;
heightSpacing = (parentHeight*0.6-2*height)/3;


visPos = [(parentWidth)*0.05 (parentHeight)*0.66 parentWidth*0.32 parentHeight*0.183];
set(plotHandles.visInput,'Position',visPos);

tsPos = [parentWidth-timeSeriesPanelWidth-leftOverSpace heightSpacing timeSeriesPanelWidth visPos(2)-2*heightSpacing];
set(plotHandles.timeSeriesPanel,'Position',tsPos);



% neurPos = [5 5+height width height];

neurPos = [5 heightSpacing+heightSpacing+height width height];
set(plotHandles.neuralFlat,'Position',neurPos);

boldPos = [10+width heightSpacing+heightSpacing+height width height];
set(plotHandles.BOLDFlat,'Position',boldPos);


arePos = [10+width heightSpacing width height];
set(plotHandles.areasFlat,'Position',arePos);

mapPos = [5 heightSpacing width height];
set(plotHandles.mappingFlat,'Position',mapPos);




end

% 
% function update_image(parent)
% 
% imshow(im_labrgb_convert(stimBOLD_output.visual_response{2}),'Parent',plotHandles.visInput);
% GUI_data = guidata(parent);
% set(h,'CData',im_labrgb_convert(gdata.stimBOLD_output.visual_response{30}));
% 
% end