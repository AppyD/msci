%% Parameters
Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -15.5;
Longitude_max = -110.5;

start_date = '10-01-1870';
end_date = '05-01-2014';

abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

angles = 0:1:15;
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
    
    fieldSST = curvature_edit(SST, LgSST, LtSST, angle);
    [WT, NaNs] = process(fieldSST, LgSST, LtSST, start_date, end_date);
    mean_orig_fieldSST = mean(fieldSST,3);
    dates = linspace(datenum(start_date), datenum(end_date), size(WT,1));

    %compute SVD
    cv = covariance(WT,WT);
    [U, Lambda, UT] = svd(cv,0);

    %normalised eigenvalues
    eigenvalues = (diag(Lambda).')/sum(diag(Lambda));

%     mode = 1;
%     EOF = U(:,mode);

%     EOFs(:,i) = EOF;
%     NaN_list(:,i) = NaNs(:);
%     mfields(:,:,i) = mean_orig_fieldSST;
    eigens(:,i) = eigenvalues(:);
    
    name = 'Angle' + string(angle);
     
%     figure();
%     plot_eigenvalues(eigenvalues, 10);
%     saveas(gcf, sprintf('Eigenvalues_%s',name), 'png');
    
%     figure();
%     plot_mode(LgSST, LtSST, EOF, NaNs, mean_orig_field);
%     saveas(gcf, sprintf('EOFMode1_%s',name), 'png');
% 
%     figure();
%     plot_PCA(EOF, WT, dates, eigenvalues(mode));
%     saveas(gcf, sprintf('PCAMode1_%s',name), 'png');

end

%%  Plotting eigenvalues:

figure();
for i = 1:size(eigens,2)
    hold on;
%    plot(2:4,eigens(2:4,i));
    plot(0:15, eigens(1:16,i));
end
xlabel('Mode, k');
ylabel('Eigenvalue fraction');
%legend('10','12','14','16','18','20','22','24','26','28','30');
%legend('10','20','30');
legend('0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15');

%%

% EOFmodes = zeros(length(LgSST),length(LtSST),size(EOFs,2));
% 
% for i = 1:size(EOFs,2)
%      EOF_with_NaNs = addNaN(EOFs(:,i), NaN_list(:,i));
%      mode = reshape(EOF_with_NaNs, length(LgSST), length(LtSST));
%      EOFmodes(:,:,i) = mode;
% end
%      

    