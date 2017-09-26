function [summer_anomaly] = summer_average(M,startd,endd)
    
% starts from first november in dataset
    % crop data to include only full years with complete summers    
    % summer months are June - September
    
    start_month = month(startd);
    end_month = month(endd);
    nsummers = year(endd)-year(startd);
    
    %% not yet edited
    ind = circshift(1:12,7);
    sind = start_month - ind(start_month);
    
    ind = circshift(0:12,8);
    eind = ind(end_month);
    
    X = M(sind:end-eind,:);
    
    summer_data = zeros(nsummers,size(X,2));
    ctr = 1;
    
    for r = 1:12:size(X,1)
        summer_data(ctr,:) = mean(X(r:r+3,:),1);     % column-wise mean
        ctr = ctr + 1;
    end
    
    summer_anomaly = find_anomaly(summer_data);
    
end