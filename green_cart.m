function [ G ] = green_cart(N, delta_x, delta_y)
%GREEN Summary of this function goes here
%   Detailed explanation goes here
    
%     if ( mod(N,2)==0)
%         N=N+1;
%     end
%     
    %delta_r = window_length/512.0;
    %delta_a = r*deg2rad(0.3);

    [X,Y] = meshgrid(-(delta_x*N/2):delta_x:(delta_x*N/2), -(delta_y*N/2):delta_y:(delta_y*N/2));
    G = 1./sqrt(X.^2 + Y.^2);
    G = (1/max(max(G))).*G;
    %[C,h]=contourf(X,Y,G);
%     surf(X,Y,G);
    %clabel(C,h);
    %axis equal

end

