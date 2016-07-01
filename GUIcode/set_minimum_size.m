% Romesh Abeysuriya 10/11/2014
% Updated: line 27 to turn off JavaFrame warnings.

function set_minimum_size(fhandle,minimum_size)
    % This function expects its inputs to be in characters
    old_units = get(fhandle,'Units');
    set(fhandle,'Units','characters');
    current_pos = get(fhandle,'Position');

    if nargin < 2 || isempty(minimum_size)
        minimum_size = current_pos(3:4); 
    end

    set(fhandle,'Visible','on');
    drawnow

    % Now, get the units in pixels and characters
    old_units = get(fhandle,'Units');
    set(fhandle,'Units','characters');
    ch = get(fhandle,'Position');
    px = getpixelposition(fhandle);
    xscale = px(3)/ch(3);
    yscale = px(4)/ch(4);

    % The Java window also has an x-offset to take into account the title bar
    % Need to find a way around this, currently turning this off. Warning
    % appeared on MATLAB 2015a.
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jFig = get(handle(fhandle), 'JavaFrame');
    
    try
        d = get(jFig.fHG2Client,'ClientRectangle');
    catch
        d = get(jFig.fHG1Client,'ClientRectangle');
    end

    if isnumeric(d) % pre R2014
        extra(1) = (d(3)-d(1))-px(3);
        extra(2) = (d(4)-d(2))-px(4);
    else
        extra(1) = get(d,'Width')-px(3);
        extra(2) = get(d,'Height')-px(4);    
    end
    
    try
        jFig.fHG2Client.getWindow.setMinimumSize(java.awt.Dimension(minimum_size(1)*xscale+extra(1), minimum_size(2)*yscale+extra(2) ));
    catch
        jFig.fHG1Client.getWindow.setMinimumSize(java.awt.Dimension(minimum_size(1)*xscale+extra(1), minimum_size(2)*yscale+extra(2) ));
    end

    set(fhandle,'Units',old_units);
    
