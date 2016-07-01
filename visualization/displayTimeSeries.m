function displayTimeSeries(t,neural,bold,visArea,ParentAxes,y_limsN,y_limsB,skipFlag)



if(nargin<5)
    figure;
    a1 = subplot(2,1,1);
    a2 = subplot(2,1,2);
else
    a1 = (ParentAxes(1));
    a2 = (ParentAxes(2));
    cla(a1);
    cla(a2);
    
end

if(nargin<8)
    skipFlag = 0;
end

lineWidth = 2;
nCol = 'k';
bCol = 'r';
vn = line(t,neural,'Parent',a1);hold on;

vB = line(t,bold,'Parent',a2);hold off;

set(vn,'lineWidth',lineWidth,'Color',nCol,'HitTest','off');
set(vB,'lineWidth',lineWidth,'Color',bCol,'HitTest','off');

x_lims = [t(1) t(end)];
maxN = max(abs(neural));
maxB = max(abs(bold));

if(maxN == 0)
    maxN = 0.01;
end

if(maxB == 0)
    maxB = 0.01;
end

% In case no lims are specified.
if(nargin<6 || isempty(y_limsB))
    y_limsN = [-maxN,maxN];
    y_limsB = [-maxB,maxB];
end;

set(a1,'fontSize',18);
set(a2,'fontSize',18);

xlabel(a1,'t(s)');
ylabel(a1,['neural ' visArea]);
xlim(a1,x_lims);
ylim(a1,y_limsN);

xlabel(a2,'t(s)');
ylabel(a2,['BOLD ' visArea]);
xlim(a2,x_lims);
ylim(a2,y_limsB);

if(~skipFlag)
    samexaxis('xmt','on','ytac','join','yld',1,'axes',[a1 a2])
end

end