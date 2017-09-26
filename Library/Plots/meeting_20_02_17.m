neof = 6;

WT_eofs = zeros(size(mean_orig_fieldSST,1),size(mean_orig_fieldSST,2),neof);

for i = 1:neof
    EOF = USST(:,i); 
    EOF_with_NaNs = addNaN(EOF, NaNs);
    mode = reshape(EOF_with_NaNs, length(LgSST), length(LtSST));
    WT_eofs(:,:,i) = mode;
end

WT_1 = curvature_edit(WT_eofs ,LgSST, LtSST, 9);
mof = mean(WT_1,3);

%%

 figure();

for i = 1:neof
    
    
    mi = min(min(min(WT_1(:,:,i))));
    
    subplot(2,3,i)
   
    pcolor(LgSST,LtSST,WT_1(:,:,i).');
    shading interp
    colormap(jet(100));
    colorbar;
    caxis([mi,-mi]);
    hold on
    [C,h] = contour(LgSST,LtSST,mean_orig_fieldSST.','black');
    title(sprintf('Curvature of SST EOF Mode %d',i));
    
    xlabel('Longitude');
    ylabel('Latitude');
    
end
