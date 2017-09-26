%%%%%%%% PARAMETERS %%%%%%%%%%%
NModes = 2;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5; %-0.5;
Longitude_max = -100.5; %-110.5;

start_date = '10-01-1870';
end_date = '05-01-2003';

abs_start_SLP = '01-01-1850';
abs_end_SLP = '01-01-2004';


%% Data

SLP = reshape_Had_SLP(dlmread('hadslp2_data.asc'));
lonSLP = -180:5:175;     % from notes accompanying data
latSLP = -90:5:90;

% n.b. here SLP is longitude*latitude*time
%SLP data is interpolated so no missing values

%% Crop data

[LtSLP, Ltmin, Ltmax] = cropped(latSLP, round(Latitude_min/5)*5, round(Latitude_max/5)*5);
[LgSLP, Lgmin, Lgmax] = cropped(lonSLP, round(Longitude_min/5)*5, round(Longitude_max/5)*5);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SLP, abs_end_SLP);
SLP = SLP(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latSLP lonSLP abs_end_SLP abs_start_SLP

%% Process data

[fieldSLP, NaNs] = process(SLP, LgSLP, LtSLP, start_date, end_date);
mean_orig_field = mean(SLP,3);
dates = linspace(datenum(start_date), datenum(end_date), size(fieldSLP,1));

%compute SVD
cv = covariance(fieldSLP,fieldSLP);
[U,Lambda,UT] = svd(cv,0);

%normalised eigenvalues
eigenvalues = (diag(Lambda).')/sum(diag(Lambda));

%% Plots

figure()
plot_eigenvalues(eigenvalues, 10);
title('Eigenvalues');


for j = 1:NModes
    figure(2)
    subplot(2, 2, j);
    EOF = U(:,j);
    plot_mode(LgSLP, LtSLP, EOF, [], mean_orig_field,1);
    title(string('EOF Mode ') + j + string(' - ') + 100*round(eigenvalues(j),2) + '%');

    subplot(2, 2, j+2);
    PC = prin_com(fieldSLP, EOF, eigenvalues(j),5);
    plot_PCA(PC, dates);
    title(string('Time Series for Mode ') + j + string(' - ') + 100*round(eigenvalues(j),2) + '%');
    
    err = EOF_error(EOF,eigenvalues,j);
    sprintf('The error for mode %d is %d.', j, mean(err))
    
    figure(3)
    subplot(2,2,j)
    plot_err(LgSLP, LtSLP, err, []);
    title(string('Error in EOF Mode ') + j);
end