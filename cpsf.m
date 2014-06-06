function [ psf ] = cpsf( input_args )
%CPSF Generate custom PSF for the DIDSON
%   Detailed explanation goes here
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu
    
    % GET THE RIGHT SPATIAL FREQUENCIES HERE
    ix = -47:48;
    iy = 
    
    [x,y] = meshgrid(ix, iy);
    % a 2D sinc should model the correlation
    % caused by the 8 firings/image (x part)
    % and along-range returns (y part)
    psf = abs(sinc(x)*sinc(y));

end

