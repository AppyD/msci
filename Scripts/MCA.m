%% Parameters

NModes = 4;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5;
Longitude_max = -100.5;

start_date = '10-01-1870';
end_date = '05-01-2003';

abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

abs_start_SLP = '01-01-1850';
abs_end_SLP = '01-01-2004';

angle = 9;

%% Data

load('HadleySSTVars', 'SST', 'latitude', 'longitude');
SLP = reshape_Had_SLP(dlmread('hadslp2_data.asc'));
lonSLP = -180:5:175;     
latSLP = -90:5:90;

% longitude*latitude*time

%% Crop Data, Remove NaNs

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

[LtSLP, Ltmin, Ltmax] = cropped(latSLP, round(Latitude_min/5)*5, round(Latitude_max/5)*5);
[LgSLP, Lgmin, Lgmax] = cropped(lonSLP, round(Longitude_min/5)*5, round(Longitude_max/5)*5);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SLP, abs_end_SLP);
SLP = SLP(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST abs_start_SLP abs_end_SLP

%% Process data

WT = curvature_edit(SST, LgSST, LtSST, angle);

[fieldSST, NaNs] = process(WT, LgSST, LtSST, start_date, end_date);
[fieldSLP, ~] = process(SLP, LgSLP, LtSLP, start_date, end_date);

mSST = mean(WT,3);
mSLP = mean(SLP,3);

dates = linspace(datenum(start_date), datenum(end_date), size(fieldSST,1));

C_xy = (1/(size(fieldSST,1)-1))*fieldSST.'*fieldSLP;
[U,Lambda,VT] = svd(C_xy,0);

% all covariance sigmas
s = diag(Lambda);
scf = power(s,2)/sum(power(s,2));   % square covariance fraction

%% 
figure(1);
plot_eigenvalues(scf, 10);

%%
% plot time series for data
figure(2);
for i = 1:NModes
    totrows = ceil(NModes/2);
    subplot(totrows, 2, i); 
    
    PC = prin_com(fieldSST, U(:,i), scf(i), 5);
    plot_PCA(PC, dates);
    title(string('Time Series for Mode ') + i + string(' - ') + 100*round(scf(i),2) + '%');
end

%% 
figure(3);
for i = 1:NModes
    totrows = ceil(NModes/2);
    subplot(totrows, 2, i); 
    
    PC = prin_com(fieldSLP, VT(:,i), scf(i), 5);
    plot_PCA(PC, dates);
    title(string('Time Series for Mode ') + i + string(' - ') + 100*round(scf(i),2) + '%');
end

%%
figure(4)

for i = 1:NModes
    totrows = ceil(NModes/2);
    subplot(totrows, 2, i); 
    
    EOFSST = U(:,i);
    plot_mode(LgSST, LtSST, EOFSST, NaNs, mSST, 1);
    title(string('Curvature Mode ') + i);
end


%%
figure(5)

for i = 1:NModes
    totrows = ceil(NModes/2);
    subplot(totrows, 2, i); 
    
    EOFSLP = VT(:,i);
    plot_mode(LgSLP, LtSLP, EOFSLP, [], mSLP, 1);
    title(string('SLP Mode ') + i);
end