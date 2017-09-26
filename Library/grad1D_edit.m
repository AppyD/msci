function gradient = grad1D_edit(x,y)

    x = x(:);
    y = y(:);

    delta_x = [NaN; diff(x)];

    delta_x_ip1_ = [delta_x(2:end); NaN];

    delta_x_i = delta_x_i_(2:end-1);
    delta_x_ip1 = delta_x_ip1_(2:end-1);

    denom = (delta_x_i + delta_x_ip1).*(delta_x_i .* delta_x_ip1);

    % % %

    y_i = y(2:end-1);
    y_im1 = y(1:end-2);
    y_ip1 = y(3:end);

    part1 = (delta_x_i.^2) .* y_ip1;
    part2 = ( (delta_x_ip1.^2)  - (delta_x_i.^2) ) .* y_i;
    part3 = y_im1 .* ( delta_x_ip1.^2 );

    numer = part1 + part2 - part3;

    grad = numer ./ denom;

    % FIRST GRAD
    part1 = y(3) * (x(2) - x(1))^2;
    part2 = y(2) * (x(3) - x(1))^2;
    part3 = y(1) * ( (x(3) - x(1))^2   -  (x(2) - x(1))^2 );
    part4_denom = (x(2)-x(1))*(x(3)-x(1))*(x(3)-x(2));
    grad1 = (-part1 + part2 - part3) / part4_denom;
    grad = [grad1; grad];

    % LAST GRAD
    part1 = y(end-2) * (x(end) - x(end-1))^2;
    part2 = y(end-1) * (x(end) - x(end-2))^2;
    part3 = y(end)   * (  (x(end) - x(end-2))^2  - (x(end)- x(end-1))^2 );
    part4_denom = (x(end)-x(end-1))*(x(end)-x(end-2))*(x(end-1)-x(end-2));
    grad_end = (part1 - part2 + part3) / part4_denom;
    gradient = [grad;grad_end];

end