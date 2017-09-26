%% Time Series for SST and SLP

SST_PCs = zeros(size(fieldSST,1),NModes);
SLP_PCs = zeros(size(fieldSLP,1),NModes);

for j = 1:NModes
    EOF = U(:,j);
    PC = prin_com(fieldSST, EOF, scf(j),5);
    SST_PCs(:,j) = PC;

    EOF = VT(:,j);
    PC = prin_com(fieldSLP, EOF, scf(j),5);
    SLP_PCs(:,j) = PC;
end

%% Computer cross correlation and plot modes

for i = 1:2
    for j = 1:2
        figure();

        [acor,lag] = xcorr(SST_PCs(:,i),SLP_PCs(:,j),'coeff');

        subplot(2,1,1);
        plot_PCA(SST_PCs(:,i), dates);
        hold on;
        plot_PCA(SLP_PCs(:,j), dates);
        legend('SST','SLP');
        title('SST Mode ' + string(i) + '; SLP Mode ' + string(j));

        subplot(2,1,2);
        bar(lag,acor);
        xlabel('Lag (years)');
        ylabel('Cross Correlation');
        
        name = 'sst' + string(i) + 'slp' + string(j);
        
        %saveas(gcf, sprintf('xcorr_%s',name), 'png');
        
        disp('SST Mode ' + string(i) + '; SLP Mode ' + string(j));
        correlation_coefficients = corrcoef(SST_PCs(:,i),SLP_PCs(:,j))
        
    end
end