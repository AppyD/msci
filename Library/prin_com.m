function PC = prin_com(field,EOF,eigenvalue,binom_filter)

    PC = field*EOF;
    PC1 = PC;
    
    std_sst = std(PC);
    PC1 = PC*eigenvalue/std_sst;
    
%     std_1 = std(PC(1:70));
%     std_2 = std(PC(71:end));
%     PC1(1:70) = PC(1:70)*eigenvalue/std_1;
%     PC1(71:end) = PC(71:end)*eigenvalue/std_2;
    PC = movmean(PC1,binom_filter);
    
end