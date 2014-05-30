function [ cart_frame ] = polarToCart( polar_frame, window_start, window_length, resolution )
%polarToCart Convert DIDSON image to Cartesianframe
%   x is down range
%   y is 
%
%   Pedro Vaz Teixeira, May 2014
%   pvt@mit.edu

    global n_beams beam_width n_bins bin_width min_range max_range;

    
    n_beams = 96;
    beam_width = deg2rad(0.3);
    
    n_bins = 512;
    bin_width = window_lenght/n_bins;
        
    min_range = window_start;
    max_range = window_start + window_length;
    
    alpha = bean_width * n_beams/2;
    x0 = min_range*cos(alpha);
    x_span = max_range - x0;
    y0 = max_range*sin(alpha);
    y_span = 2*y0;
    
    width = y_span/resolution;
    height = x_span/resolution;
    
    cart_frame = zeros(width, height);
    
    for i=1:height
        for j=1:width
            [beam, bin] = toBeanBin(x, y);
            cart_frame(j,i) = polar_frame(bin+1, beam+1);
        end
    end

end

