moden = 1;

%% Time Series for SST

EOF = USST(:,moden);
PC = prin_com(fieldSST, EOF, eigenvaluesSST(moden),12);

%% Computer autocorrelation and plot modes
figure();

[acor,lag] = xcorr(PC,PC,'coeff');

subplot(2,1,1);
plot_PCA(PC, dates);
title('Mode ' + string(moden));

subplot(2,1,2);
bar(lag,acor);
xlabel('Lag (years)');
ylabel('Autocorrelation');

%% Determine period

[pksh, lcsh] = findpeaks(acor);
short = mean(diff(lcsh));

subplot(2,1,2);
hold on
pks = plot(lag(lcsh),pksh,'vr');
legend('Period: ' + string(short))