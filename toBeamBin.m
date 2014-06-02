function [ beam, bin ] = toBeamBin( x, y )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    global n_beams beam_width n_bins bin_width min_range;
    
    beam = (n_beams/2) - floor(atan2(y, x)/beam_width);
    bin = floor( (sqrt( x*x + y*y) - min_range)/bin_width );
    
     if ( beam < 0 || beam >= n_beams || bin < 0 || bin >= n_bins)
%          disp(['x: ', num2str(x),', y: ', num2str(y)]);
%          disp(['angle: ', num2str(rad2deg(atan2(y, x)))]);
%          disp(['beam: ', num2str(beam),', bin: ', num2str(bin)]);
         beam = -1; 
         bin = -1;
%          error('failed conversion!');
%      else
%          disp('!');
     end
   
end