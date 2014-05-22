function [ G ] = green(N, r, window_length)
%GREEN Summary of this function goes here
%   Detailed explanation goes here
    
%     if ( mod(N,2)==0)
%         N=N+1;
%     end
%     
    delta_r = window_length/512.0;
    delta_a = r*deg2rad(0.3);

    [X,Y] = meshgrid(-(delta_a*N/2):delta_a:(delta_a*N/2), -(delta_r*N/2):delta_r:(delta_r*N/2));
    G = 1./sqrt(X.^2 + Y.^2);
    G = (1/max(max(G))).*G;
    [C,h]=contourf(X,Y,G);
%     surf(X,Y,G);
    clabel(C,h);
    axis equal

end

