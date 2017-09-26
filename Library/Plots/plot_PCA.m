function plot_PCA(PC, dates)
    
    plot(dates,PC,'-');
    datetick('x','yyyy');
    xlabel('Year', 'FontSize', 13);
    s = sprintf('%c', char(176));
    %ylabel('Anomaly, '+string(s)+'C', 'FontSize',13);
    %ylabel('SLP Anomaly, hPa', 'FontSize', 13);
    ylabel('Curvature Anomaly', 'FontSize', 13);
    xlim([dates(1)-1,dates(end)+1]);
    ylim([-1,1]);
    
end