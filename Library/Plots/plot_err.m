function plot_err(longitude, latitude, EOF, nanlist)

    EOF_with_NaNs = addNaN(EOF, nanlist);
    mode = reshape(EOF_with_NaNs, length(longitude), length(latitude));

    pcolor(longitude, latitude, mode');
    caxis([-0.05,0.05]);
    colormap(jet(100));
    c = colorbar;
    shading interp;

    hold on;
    [C,h] = contour(longitude,latitude,mode.','black');
    clabel(C,h)
    load coastlines;
    geoshow(coastlat,coastlon,'LineWidth',2,'Color','Black');
    
    xlabel('Longitude, \lambda', 'FontSize', 13);
    ylabel('Latitude, \phi', 'FontSize', 13);
    
    xticks(longitude(1:20:end))
    xt = ceil(xticks);
    xl = string(zeros(1,length(xt)));
    for i = 1:length(xticks)
        if xt(i) < 0
            xl(i) = string(abs(xt(i)))+'W';
        elseif xt(i) > 0
            xl(i) = string(abs(xt(i)))+'E';
        end
    end
    xticklabels({xl});
    
    yl = string(abs(yticks))+'N';
    yticklabels({yl});
    
    s = sprintf('%c', char(176));
    %ylabel(c, 'Anomaly error, '+string(s)+'C', 'FontSize', 13);
    %ylabel(c, 'Anomaly Error, hPa', 'FontSize', 13);
    ylabel(c, 'Curvature Anomaly', 'FontSize', 13);
end