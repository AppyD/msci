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

curvature_line_deg = 13.5;   % for calculating the curvature

%% Data
load('HadleySSTVars', 'SST', 'latitude', 'longitude');

% n.b. here SST is longitude*latitude*time

%% Crop data, remove NaNs

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

dates = linspace(datenum(start_date), datenum(end_date), size(SST,1));

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST

%% Calculate Curvature

WT = curvature(SST,LgSST,LtSST,curvature_line_deg);
[WT,numNaNs] = insertNaNs(WT,SST);

mean_orig_field = mean(WT,3);

%mean_orig_field = mean(SST,3);

%%

WT_2D = reshape_for_EOF(LgSST,LtSST,WT);
[wt,NaNs] = removeNaN(WT_2D);

% detrend data and remove seasonality
WT_2D = find_anomaly(wt);
wt = detrend(WT_2D);
WT = remove_seasonality_2(wt);
WT = season_average(WT, start_date, end_date);

clearvars WT_2D wt

%compute SVD
cv = covariance(WT,WT);
[U,Lambda,UT] = svd(cv,0);

%normalised eigenvalues
eigenvalues = (diag(Lambda).')/sum(diag(Lambda));

%%
figure();
plot(eigenvalues(1:20),'rx-');
dx = 0.5;
dy = 0.003;

hold on
for i = 1:5
    text(i+dx,eigenvalues(i)+dy,num2str(round(eigenvalues(i),3)));
end
hold off

xlabel('Mode')
ylabel('Eigenvalue fraction')
%%
% plot the modes

figure();
for i = 1:NModes
    totrows = ceil(NModes/3);
    subplot(totrows, 3, i); 
    
    EOF = U(:,i);
    EOF_with_NaNs = addNaN(EOF, NaNs);
    mode = reshape(EOF_with_NaNs, length(LgSST), length(LtSST));
    
    pcolor(LgSST, LtSST, mode');
    caxis([-0.05,0.05]);
    colormap(jet(100));
    colorbar;
    shading interp;
    
    hold on;
    [C,h] = contour(LgSST,LtSST,mean_orig_field.','black');
    
    title(string('EOF Mode ') + i + string(' - ') + round(eigenvalues(i),3) + string('%'));
end

%%
%plot time series for data

figure()
for i = 1:NModes
    totrows = ceil(NModes/2);
    subplot(totrows, 2, i); 
    
    EOF = U(:,i);
    PC = WT*EOF;
    std_sst = std(PC);
    PC1 = PC*eigenvalues(i)/std_sst;
    PC1 = mapminmax(PC1);
    PC = movmean(PC1,5);
    
    plot(dates,PC,'b-');
    datetick('x','yyyy');
    title(string('Time Series for Mode ') + i + string(' - ') + round(eigenvalues(i),3) + string('%'));
    xlabel('Year');
    ylabel('Curv. Anom');
    xlim([dates(1)-1,dates(end)+1]);
end