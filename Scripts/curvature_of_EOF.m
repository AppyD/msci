%% Parameters

NModes = 4;

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

%% Crop data, remove NaNs

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST

%% Process data

[fieldSST, NaNs] = process(SST, LgSST, LtSST, start_date, end_date);
mean_orig_fieldSST = mean(SST,3);

dates = linspace(datenum(start_date), datenum(end_date), size(fieldSST,1));

%compute SVD
cv = covariance(fieldSST,fieldSST);
[USST,LambdaSST,UTSST] = svd(cv,0);

%normalised eigenvalues
eigenvaluesSST = (diag(LambdaSST).')/sum(diag(LambdaSST));

%% Curvature

EOFs = USST(:,1:NModes);
modes = zeros(length(LgSST),length(LtSST),size(EOFs,2));

for d = 1:size(EOFs,2)
    EOF_with_NaNs = addNaN(EOFs(:,d), NaNs);
    mode = reshape(EOF_with_NaNs, length(LgSST), length(LtSST));
    modes(:,:,d) = mode;
end

curv = curvature_edit(modes,LgSST,LtSST,angle);
lim = abs(max(max(max(curv))))*0.5;

%% Plots

figure()

for j = 1:NModes
    subplot(2, 2, j);
   
    pcolor(LgSST, LtSST, curv(:,:,j)');
    caxis([-lim,lim]);
    colormap(jet(100));
    c = colorbar;
    shading interp;

    hold on;
    load coastlines;
    geoshow(coastlat,coastlon,'LineWidth',2,'Color','Black');
    
    xticks(LgSST(1:20:end));
    xt = ceil(xticks);
    xl = string(zeros(1,length(xt)));
    for i = 1:length(xticks)
        if xt(i) < 0
            xl(i) = string(abs(xt(i)))+'W';
        elseif xt(i) > 0
            xl(i) = string(abs(xt(i)))+'E';
        end
    end
    xticklabels({xl});
    
    yl = string(abs(yticks))+'N';
    yticklabels({yl});
    
    
    xlabel('Longitude, \lambda', 'FontSize', 13);
    ylabel('Latitude, \phi', 'FontSize', 13);
    
    s = sprintf('%c', char(176));
    ylabel(c, 'Curvature of Anomaly', 'FontSize',13);
    
    title(string('Curvature of EOF Mode ') + j + string(' - ') + 100*round(eigenvaluesSST(j),2) + '%', 'FontSize', 13);
end