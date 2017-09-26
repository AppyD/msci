function [gradX, gradY] = hessian_edit(field, longitude, latitude)
% nb. input column/row vector longitude and latitude, and a 2D field vector
% where the dimensions of the field vector are longitude*latitude
    
    %% initialisation

    gradX = zeros(size(field));
    gradY = zeros(size(field));
    
    longitude = longitude(:);
    latitude = latitude(:);     % need column vectors

    %% distance conversion (degrees to km) corrections
    
    R = 6371;      % Earth's radius, km
    lg = (longitude*pi*R/180) * (cosd(latitude)');  % each column has longitudes weighted by a given latitude
    lt = latitude*pi*R/180;
    
    %% gradient calculation
    
    for i = 1:length(latitude)
        x = lg(:,i);
        y = field(:, i);
        grad = grad1D(x,y);   % return m x 1 vector
        gradX(:,i) = grad;
    end
    
    for i = 1:length(longitude)
        x = lt;
        y = field(i,:);
        grad = grad1D(x,y); % return m x 1 vector
        gradY(i,:) = grad.';
    end
    
end