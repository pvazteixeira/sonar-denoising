function [ psf ] = cpsf( N )
%CPSF Generate custom PSF for the DIDSON
%   "The DIDSON has 12 active channels. Assuming the DIDSON-Std at HF, 
%   using 96 beams, this means that it takes 8 ping cycles (transmitting on
%   and receiving from 12 transducers for each ping cycle) to build a 
%   single complete frame." (from Sound Metrics Support)
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu
   
    % number of beams to consider to each side;
    %N = 1;
    psf = zeros(1,1+2*N*12);
    psf(1:12:end) = 1;
    
    alpha = 15/90;
    
    for i = 1:N
        psf(N*12+1 - i*12) = alpha^i;
        psf(N*12+1 + i*12) = alpha^i;
    end
    % 
    %ix = -48:48;
    %iy = -48:48;
    
    %[x,y] = meshgrid(ix, iy);
    % a 2D sinc should model the correlation
    % caused by the 8 firings/image (x part)
    % and along-range returns (y part)
    %psf = abs(sinc(x)*sinc(y));

end

% frame_polar_enhanced_deconv = deconvreg(edgetaper(frame_polar_enhanced_padded, cpsf(4)),cpsf(4))
