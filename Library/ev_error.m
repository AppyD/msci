function err = ev_error(EV_list)

    %N = ( sum(EV_list)^2 ) / ( sum(EV_list.^2) );
    
    %N = (length(EV_list)^2) / sum( EV_list.^2 );
    
    %N = length(EV_list);
    
    %c = cumsum(EV_list);
    %N = length(c(c<0.995));
    
    N = 120;
    err = EV_list*(2./N)^(0.5);
end