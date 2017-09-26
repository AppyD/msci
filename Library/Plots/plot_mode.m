function plot_mode(longitude, latitude, EOF, nanlist, mfield, nans)
    
    EOF_with_NaNs = addNaN(EOF, nanlist);
    mode = reshape(EOF_with_NaNs, length(longitude), length(latitude));
    
    if nans == 1
        [lon,lat] = meshgrid(longitude,latitude);
        land = landmask(lat,lon).';
        %mode(land==1) = NaN;
        mfield(land==1) = NaN;
    end
        
    pcolor(longitude, latitude, mode');
    caxis([-0.05,0.05]);
    colormap(jet(100));
    c = colorbar;
    shading interp;

    hold on;
    [C,h] = contour(longitude,latitude,mfield.','black');
    clabel(C,h);
    load coastlines;
    geoshow(coastlat,coastlon,'LineWidth',2,'Color','Black');  
    
    xlabel('Longitude, \lambda', 'FontSize', 13);
    ylabel('Latitude, \phi', 'FontSize', 13);
   
    xticks(longitude(1:4:end));
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
    %ylabel(c, 'Anomaly, '+string(s)+'C', 'FontSize', 13);
    ylabel(c, 'SLP Anomaly, hPa', 'FontSize', 13); 
    %ylabel(c, 'Curvature Anomaly', 'FontSize', 13);
end