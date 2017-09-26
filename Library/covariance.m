function cv = covariance(A,B)
% A,B are nxp and nxq matrices respectively, where p=q is a possibility.

    if size(A,1) ~= size(B,1)
        throw(Exception('Error: matrices do not have the same number of time points'));
    else
        n = size(A,1);
        cv = (1/n)*(A'*B);
    end

end