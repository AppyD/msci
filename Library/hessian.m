function [gradX, gradY] = hessian(field,longitude,latitude)
% nb. input column/row vector longitude and latitude, and a 2D field vector
% where the dimensions of the field vector are longitude*latitude

%% initialisation

    gradX = zeros(size(field));
    gradY = zeros(size(field));
    
    longitude = longitude(:);
    latitude = latitude(:);     % need column vectors
    
    %% distance correction
    
    R = 6371;      % Earth's radius, km
    lgGrid = (longitude/360) * 2 * pi * R * (cosd(latitude)');  % each column has longitudes weighted by a given latitude
    lt = (latitude/360) .* (2*pi*R);
    ltGrid = repmat(lt', [length(longitude), 1]);   % repeated rows of corrected latitudes

    %% horizontal gradient
    
    for i = 1:length(latitude)
        x = lgGrid(:,i);
        y = field(:, i);
        grad = grad1D(x,y);   % return m x 1 vector
        gradX(:,i) = grad;
    end
    
    %% vertical gradient
    
    for i = 1:length(longitude)
        x = ltGrid(i, :);
        y = field(i,:);
        grad = grad1D(x,y); % return m x 1 vector
        gradY(i,:) = grad.';
    end
    
end