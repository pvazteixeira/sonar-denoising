function [ psf ] = cpsf( N )
%CPSF Generate custom PSF for the DIDSON
%   "The DIDSON has 12 active channels. Assuming the DIDSON-Std at HF, 
%   using 96 beams, this means that it takes 8 ping cycles (transmitting on
%   and receiving from 12 transducers for each ping cycle) to build a 
%   single complete frame." (from Sound Metrics Support)
%
%   N = number of beams to consider to each side;
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu
   
    

    psf = zeros(1,1+2*N*12);
    psf(1:12:end) = 1;
    
    alpha = 15/90;
    
    for i = 1:N
        psf(N*12+1 - i*12) = alpha^i;
        psf(N*12+1 + i*12) = alpha^i;
    end

end

% frame_polar_enhanced_deconv = deconvreg(edgetaper(frame_polar_enhanced_padded, cpsf(4)),cpsf(4))
