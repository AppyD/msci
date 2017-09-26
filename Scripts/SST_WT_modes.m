%% Parameters

NModes = 2;

Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5; %-0.5;
Longitude_max = -100.5; %-110.5;

start_date = '10-01-1870';
end_date ='05-01-2014';

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

WT = curvature_edit(SST, LgSST, LtSST, angle);
[fieldWT, NaNs] = process(WT, LgSST, LtSST, start_date, end_date);
[fieldSST, NaNsSST] = process(SST, LgSST, LtSST, start_date, end_date);

mean_orig_fieldWT = mean(WT,3);
mean_orig_fieldSST = mean(SST,3);

dates = linspace(datenum(start_date), datenum(end_date), size(fieldSST,1));

%compute SVD
cvSST = covariance(fieldSST,fieldSST);
cvWT = covariance(fieldWT, fieldWT);

[USST,LambdaSST,UTSST] = svd(cvSST,0);
[UWT,LambdaWT,UTWT] = svd(cvWT,0);

%normalised eigenvalues
eigenvaluesSST = (diag(LambdaSST).')/sum(diag(LambdaSST));
eigenvaluesWT = (diag(LambdaWT).')/sum(diag(LambdaWT));

%% cross-corr

SST_PCs = zeros(size(fieldSST,1),NModes);
WT_PCs = zeros(size(fieldWT,1),NModes);

for j = 1:NModes
    EOFSST = USST(:,j);
    EOFWT = UWT(:,j);
    
    PC = prin_com(fieldSST, EOFSST, eigenvaluesSST(j),5);    
    SST_PCs(:,j) = PC;
    
    PC = prin_com(fieldWT, EOFWT, eigenvaluesWT(j), 5);
    WT_PCs(:,j) = PC; 
end

for i = 1:2
    for j = 1:2
        figure();

        [acor,lag] = xcorr(SST_PCs(:,i),WT_PCs(:,j),'coeff');

        subplot(2,1,1);
        plot_PCA(SST_PCs(:,i), dates);
        hold on;
        plot_PCA(WT_PCs(:,j), dates);
        legend('SST Mode '+string(i),'Curvature Mode '+string(j));
        title('Cross-correlation');

        subplot(2,1,2);
        bar(lag,acor);
        xlabel('Lag (years)');
        ylabel('Correlation');
              
        disp('SST Mode ' + string(i) + '; Curvature Mode ' + string(j));
        correlation_coefficients = corrcoef(SST_PCs(:,i),WT_PCs(:,j))
        
        [pksh, lcsh] = findpeaks(acor);
        short = mean(diff(lcsh));
        hold on
        pks = plot(lag(lcsh),pksh,'vr');
        legend('Lag: ' + string(short))
    end
end
