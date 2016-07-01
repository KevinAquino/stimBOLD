function [ax,xh,yh] = xylabelDefault(ax,xLab,yLab,fontSize)
if(nargin<4)
    fontSize = 18;
end

xh = xlabel(xLab,'fontSize',fontSize);
yh = ylabel(yLab,'fontSize',fontSize);

set(ax,'fontSize',18);
end