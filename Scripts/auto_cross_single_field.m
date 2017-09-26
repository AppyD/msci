%% Time Series for SST

SST_PCs = zeros(size(fieldSST,1),NModes);

for j = 1:NModes
    EOF = USST(:,j);
    PC = prin_com(fieldSST, EOF, eigenvaluesSST(j),5);
    SST_PCs(:,j) = PC;
end

%% Computer autocorrelation and plot modes

for i = 1:2
    for j = 1:2
        figure();

        [acor,lag] = xcorr(SST_PCs(:,i),SST_PCs(:,j),'coeff');

        subplot(2,1,1);
        plot_PCA(SST_PCs(:,i), dates);
        hold on;
        plot_PCA(SST_PCs(:,j), dates);
        legend('Mode '+string(i),'Mode '+string(j));
        
        if i == j
            title('Autocorrelation');
        else
            title('Cross-correlation');
        end

        subplot(2,1,2);
        bar(lag,acor);
        xlabel('Lag (years)');
        ylabel('Correlation');
              
        disp('SST Mode ' + string(i) + '; SST Mode ' + string(j));
        correlation_coefficients = corrcoef(SST_PCs(:,i),SST_PCs(:,j))
        
    end
end