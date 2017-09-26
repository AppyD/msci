function curvature_field = curvature_edit(field, longitude, latitude, cdeg)
    
    curvature_field = zeros(size(field));

    for i = 1:size(field, 3)
        snapshot = field(:,:,i);
        
        [zonal_grad, merid_grad] = hessian_edit(snapshot, longitude, latitude);
        [dx2, dxdy] = hessian_edit(zonal_grad, longitude, latitude);
        [~, dy2] = hessian_edit(merid_grad, longitude, latitude);

        u = [-sind(cdeg); cosd(cdeg)];
        curvature_field(:,:,i) = (dx2 .* (u(1).^2)) + (2*dxdy .* u(1) .* u(2)) + (dy2 .* (u(2).^2));
        
    end

end