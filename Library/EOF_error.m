function err = EOF_error(EOF,EV_list,i)
% i: mode number
% EOF: eigenvector of mode i
% EV_list: list of all eigenvalues

ev_err_all = ev_error(EV_list);
ev_err = ev_err_all(i);

mid = EV_list(i);

if i == 1
    j = i+1;
else
    iplus = EV_list(i+1);
    iminus = EV_list(i-1);
    if abs(mid-iminus) > abs(mid-iplus)
        j = i+1;
    else
        j = i-1;
    end
end
nn = EV_list(j);

err = EOF*ev_err/(nn-mid);

end