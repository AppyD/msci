%% Parameters

NModes = 2;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5; %-0.5;
Longitude_max = -100.5; %-110.5;

start_date = '10-01-1870';
end_date ='05-01-2014';

% deser params
% Latitude_min = 10.5;
% Latitude_max = 75.5;
% Longitude_min = 10.5;
% Longitude_max = -100.5;
% 
% start_date = '10-01-1899';
% end_date = '05-01-1990';

%start_date = '10-01-1870';
%end_date = '05-01-2003';

abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

angle = 9;

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

%% Process data

%curvWT = curvature_edit(SST, LgSST, LtSST, angles(i));
%meanWT = curvature_edit(meanSST, LgSST, LtSST, angles(i));
%WT = curvWT + meanWT;
%mean_orig_fieldSST = mean(WT,3);
% 
WT = curvature_edit(SST, LgSST, LtSST, angle);

[fieldSST, NaNs] = process(WT, LgSST, LtSST, start_date, end_date);
mean_orig_fieldSST = mean(WT,3);
dates = linspace(datenum(start_date), datenum(end_date), size(fieldSST,1));

%compute SVD
cv = covariance(fieldSST,fieldSST);
[USST,LambdaSST,UTSST] = svd(cv,0);

%normalised eigenvalues
eigenvaluesSST = (diag(LambdaSST).')/sum(diag(LambdaSST));

%% Plots

% figure(1)
% plot_eigenvalues(eigenvaluesSST, 10);

for j = 1:NModes
    figure(2)
    subplot(2, 2, j);
    EOFSST = USST(:,j);
    
    plot_mode(LgSST, LtSST, EOFSST, NaNs, mean_orig_fieldSST,0);
    title(string('EOF Mode ') + j + string(' - ') + 100*round(eigenvaluesSST(j),2) + '%', 'FontSize', 13);

    subplot(2, 2, j+2);
    PC = prin_com(fieldSST, EOFSST, eigenvaluesSST(j),5);
    plot_PCA(PC, dates);
    title(string('Time Series for Mode ') + j + string(' - ') + 100*round(eigenvaluesSST(j),2) + '%', 'FontSize', 13);
    
    err = EOF_error(EOFSST,eigenvaluesSST,j);
    sprintf('The error for mode %d is %d.', j, mean(err))
    
    figure(3)
    subplot(2,2,j)
    plot_err(LgSST, LtSST, err, NaNs);
    title(string('Error in EOF Mode ') + j, 'FontSize', 13);
end
    
%name = 'curv2' + string(angles(i)) + '.png';
%saveas(gcf, sprintf('figures_angle%s',name), 'png');

%set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20]);
%print('-dpng', sprintf('figures_angle%s',name), '-r300');

