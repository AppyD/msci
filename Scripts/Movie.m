Latitude_min = 25.5;
Latitude_max = 60.5;
Longitude_min = -0.5;
Longitude_max = -110.5;

start_date = '10-01-1900';
end_date = '05-01-1991';

abs_start_SST = '01-01-1870';
abs_end_SST = '01-01-2015';

load('HadleySSTVars', 'SST', 'latitude', 'longitude');

SST(SST < -200) = NaN;
[LtSST, Ltmin, Ltmax] = cropped(latitude, Latitude_min, Latitude_max);
[LgSST, Lgmin, Lgmax] = cropped(longitude, Longitude_min, Longitude_max);
[tmin, tmax] = date_indices(start_date, end_date, abs_start_SST, abs_end_SST);
SST = SST(Lgmin:Lgmax, Ltmin:Ltmax, tmin:tmax);

clearvars Ltmin Ltmax Lgmin Lgmax tmin tmax latitude longitude abs_end_SST abs_start_SST

N = size(SST,3);

sd = datetime(1900,10,1);

for i = 1:N
    %plot
    
    pcolor(LgSST, LtSST, SST(:,:,i).');
    title('SST - ' + string(month(sd,'Longname')) + ' ' + string(year(sd)));
    shading interp;
    colormap(jet(100));
    colorbar;
    caxis([0,37]);
    % Store the frame
    M(i)=getframe(gcf); % leaving gcf out crops the frame in the movie.
    
    sd = sd + calmonths(1);
    
end