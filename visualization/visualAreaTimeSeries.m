%mvibe_output.params.t mvibe_output.params.t

% neural.v1 = zMeanV1;neural.v2 = zMeanV2;neural.v3 = zMeanV3;
% bold.v1 = BOLDMeanV1;bold.v2 = BOLDMeanV2;bold.v3 = BOLDMeanV3;

function out = visualAreaTimeSeries(t,neural,bold,ParentAxes)
out = [];

if(nargin<4)
    figure;
    a1 = subplot(3,1,1);
    a2 = subplot(3,1,2);
    a3 = subplot(3,1,3);        
else
    a1 = (ParentAxes(1));
    a2 = (ParentAxes(2));
    a3 = (ParentAxes(3));
    
    cla(a1);
    cla(a2);
    cla(a3);
end


if(size(fields(neural),1)==1)
    v1n = line(t,neural.v1,'Parent',a1);hold on;
    v1B = line(t,bold.v1,'Parent',a1);hold off;
else
    
    v1n = line(t,neural.v1,'Parent',a1);hold on;
    v1B = line(t,bold.v1,'Parent',a1);hold off;
    
    
    v2n = line(t,neural.v2,'Parent',a2);hold on;
    v2B = line(t,bold.v2,'Parent',a2);hold off;
    
    
    v3n = line(t,neural.v2,'Parent',a3);hold on;
    v3B = line(t,bold.v2,'Parent',a3);hold off;
end

% setting colors and such
for k=1:3,
    lineWidth = 2;
    nCol = 'k';
    bCol = 'r';
    x_lims = [t(1) t(end)];
    eval(['tn = neural.v' num2str(k) ';']);
    eval(['tb = bold.v' num2str(k) ';']);
    abLim = max(max(abs(tn)),max(abs(tb)));
    
    y_lims = [-1,1];
    
    eval(['an = v' num2str(k) 'n;']);
    eval(['aB = v' num2str(k) 'B;']);
    
    set(an,'lineWidth',lineWidth,'Color',nCol);
    set(aB,'lineWidth',lineWidth,'Color',bCol);
    
    eval(['axP = a' num2str(k) ';']);
    set(axP,'fontSize',18);
    xlabel(axP,'t(s)');
    ylabel(axP,['V' num2str(k)]);
    xlim(axP,x_lims);
    ylim(axP,y_lims);
    
    if(size(fields(neural),1)==1)
        ylabel(axP,['No Map']);
        return
    end;
    
end


samexaxis('xmt','on','ytac','join','yld',1,'axes',[a1 a2 a3])