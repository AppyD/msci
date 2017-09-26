function plot_eigenvalues(EV_list, num_eig)
    
    err = ev_error(EV_list);

    errorbar(1:num_eig,EV_list(1:num_eig),err(1:num_eig),'b');
    dx = 0.3;
    dy = 0.01;

    hold on
    for i = 1:5
        text(i+dx,EV_list(i)+dy,num2str(round(EV_list(i),3)));
    end
    hold off

    xlabel('Mode, k', 'FontSize', 13);
    ylabel('Eigenvalue fraction', 'FontSize', 13);
    ylim([0,max(EV_list)+0.05]);

end