function [cf2D,nanlist] = process(field,longitude,latitude,start_date,end_date)
    
    weights = diag(sqrt(cos(latitude*pi/180)));
    area_weighting(field,weights);

    % Reshape data for next steps

    cf2D = reshape_for_EOF(longitude,latitude,field);
    [cf2D,nanlist] = removeNaN(cf2D);

    % detrend data and remove seasonality
    cf2D = find_anomaly(cf2D);
    cf2D = detrend(cf2D);
    cf2D = remove_seasonality_2(cf2D);
    %cf2D = summer_average(cf2D, start_date, end_date);
    cf2D = season_average(cf2D, start_date, end_date);

end