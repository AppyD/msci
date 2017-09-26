%% Parameters

NModes = 2;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5; %-0.5;
Longitude_max = -100.5; %-110.5;

start_date = '10-01-1870';
end_date = '05-01-2003'; %'05-01-2014';

abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

abs_start_SLP = '01-01-1850';
abs_end_SLP = '01-01-2004';

angle = 9;

%% Data
load('HadleySSTVars', 'SST', 'latitude', 'longitude');
SLP = reshape_Had_SLP(dlmread('hadslp2_data.asc'));
lonSLP = -180:5:175;     % from notes accompanying data
latSLP = -90:5:90;

%% Crop data, remove NaNs

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

[LtSLP, Ltmin, Ltmax] = cropped(latSLP, round(Latitude_min/5)*5, round(Latitude_max/5)*5);
[LgSLP, Lgmin, Lgmax] = cropped(lonSLP, round(Longitude_min/5)*5, round(Longitude_max/5)*5);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SLP, abs_end_SLP);
SLP = SLP(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST latSLP lonSLP abs_end_SLP abs_start_SLP

%% Process data

WT = curvature_edit(SST, LgSST, LtSST, angle);
[fieldWT, NaNs] = process(WT, LgSST, LtSST, start_date, end_date);

[fieldSLP, ~] = process(SLP, LgSLP, LtSLP, start_date, end_date);

mean_orig_fieldWT = mean(WT,3);
mean_orig_fieldSLP = mean(SLP,3);

dates = linspace(datenum(start_date), datenum(end_date), size(fieldSLP,1));

%compute SVD
cvSLP = covariance(fieldSLP,fieldSLP);
cvWT = covariance(fieldWT, fieldWT);

[USLP,LambdaSLP,UTSLP] = svd(cvSLP,0);
[UWT,LambdaWT,UTWT] = svd(cvWT,0);

%normalised eigenvalues
eigenvaluesSLP = (diag(LambdaSLP).')/sum(diag(LambdaSLP));
eigenvaluesWT = (diag(LambdaWT).')/sum(diag(LambdaWT));

%% cross-corr

SLP_PCs = zeros(size(fieldSLP,1),NModes);
WT_PCs = zeros(size(fieldWT,1),NModes);

for j = 1:NModes
    EOFSLP = USLP(:,j);
    EOFWT = UWT(:,j);
    
    PC = prin_com(fieldSLP, EOFSLP, eigenvaluesSLP(j),5);    
    SLP_PCs(:,j) = PC;
    
    PC = prin_com(fieldWT, EOFWT, eigenvaluesWT(j), 5);
    WT_PCs(:,j) = PC; 
end

for i = 1:2
    for j = 1:2
        figure();

        [acor,lag] = xcorr(SLP_PCs(:,i),WT_PCs(:,j),'coeff');

        subplot(2,1,1);
        plot_PCA(SLP_PCs(:,i), dates);
        hold on;
        plot_PCA(WT_PCs(:,j), dates);
        legend('SLP Mode '+string(i),'Curvature Mode '+string(j));
        title('Cross-correlation');

        subplot(2,1,2);
        bar(lag,acor);
        xlabel('Lag (years)');
        ylabel('Correlation');
              
        disp('SLP Mode ' + string(i) + '; Curvature Mode ' + string(j));
        correlation_coefficients = corrcoef(SLP_PCs(:,i),WT_PCs(:,j))
        
        [pksh, lcsh] = findpeaks(acor);
        short = mean(diff(lcsh));
        hold on
        pks = plot(lag(lcsh),pksh,'vr');
        legend('Lag: ' + string(short))
    end
end
