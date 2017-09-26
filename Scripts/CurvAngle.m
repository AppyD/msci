%% Parameters

NModes = 6;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -0.5;
Longitude_max = -110.5;

start_date = '10-01-1870';
end_date = '05-01-2014';
abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

angles = 0:5:90;
%curvature_line_deg = 13.5;   % for calculating the curvature

%% Data
load('HadleySSTVars', 'SST', 'latitude', 'longitude');

% n.b. here SST is longitude*latitude*time

%% Crop data, remove NaNs

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST

%% Calculate curvature, process data

for i = 1:length(angles)

    angle = angles(i);
    [WT, NaNs, mean_orig_field] = curv_and_process(SST, LgSST, LtSST, angle, start_date, end_date);
    dates = linspace(datenum(start_date), datenum(end_date), size(WT,1));

    %compute SVD
    cv = covariance(WT,WT);
    [U, Lambda, UT] = svd(cv,0);

    %normalised eigenvalues
    eigenvalues = (diag(Lambda).')/sum(diag(Lambda));

    mode = 1;
    EOF = U(:,mode);

    figure();
    plot_eigenvalues(eigenvalues, 10);
    %title('Eigenvalues, Angle: ' + angle);

    figure();
    plot_mode(LgSST, LtSST, EOF, NaNs, mean_orig_field);
    %title(string('Mode ') + mode + string(' - ') + round(eigenvalues(mode),2) + string('%') + ' - Angle: ' + angle);

    figure();
    plot_PCA(EOF, WT, dates, eigenvalues(mode));
    %title(string('Mode ') + mode + string(' - ') + round(eigenvalues(mode),2) + string('%') + ' - Angle: ' + angle);

end