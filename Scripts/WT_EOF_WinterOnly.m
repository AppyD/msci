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

curvature_line_deg = 9;   % for calculating the curvature

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


WT = curvature(SST,LgSST,LtSST,curvature_line_deg);
mean_orig_field = mean(WT,3);
WT = insertNaNs(WT,SST);

[WT, NaNs] = process(WT, LgSST, LtSST, start_date, end_date);
dates = linspace(datenum(start_date), datenum(end_date), size(WT,1));

mean_orig_fieldSST = mean(SST,3);
[SST1, NaNSST] = process(SST, LgSST, LtSST, start_date, end_date);
    
%compute SVD
cv = covariance(WT,WT);
cvs = covariance(SST1,SST1);
[U, Lambda, UT] = svd(cv,0);
[U1, Lambda1, UT1] = svd(cvs,0);

%normalised eigenvalues
eigenvalues = (diag(Lambda).')/sum(diag(Lambda));
eigenvalues1 = (diag(Lambda1).')/sum(diag(Lambda1));


%%
figure(1);
plot_eigenvalues(eigenvalues, 10);

figure(2);
figure(3);

for i = 1:NModes
    totrows = ceil(NModes/3);
  
    EOF = U(:,i);
    
    figure(2);
    subplot(totrows, 3, i); 
    plot_mode(LgSST, LtSST, EOF, NaNs, mean_orig_field);
    title(string('EOF Mode ') + i + string(' - ') + round(eigenvalues(i),3));
    
    figure(3);
    subplot(totrows, 3, i); 
    plot_PCA(EOF, WT, dates, eigenvalues(i));
    title(string('Time Series for Mode ') + i + string(' - ') + round(eigenvalues(i),3));
    
end

%% oplot figures

figure(1);
plot_eigenvalues(eigenvalues, 10);
hold on
plot_eigenvalues(eigenvalues1,10);
legend('Curvature','SST');

figure(2);
for i = 1:NModes
    totrows = ceil(NModes/3);
  
    EOF = U(:,i);
    EOF1 = U1(:,i);
    
    subplot(totrows, 3, i); 
    plot_PCA(EOF, WT, dates, eigenvalues(i));
    hold on
    plot_PCA(EOF1, SST1, dates, eigenvalues1(i));
    title(string('Time Series for Mode ') + i + string(' - ') + round(eigenvalues(i),3));
    
end