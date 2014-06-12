function [ cart_frame, res_x, res_y ] = polarToCart( polar_frame, window_start, window_length, width )
%polarToCart Convert DIDSON image to Cartesianframe
%   x is down range
%   y is 
%   resolution is the number of pixels per meter
%
%   Pedro Vaz Teixeira, May 2014
%   pvt@mit.edu

    n_beams = 96;
    beam_width = deg2rad(0.3);
    
    n_bins = 512;
    bin_width = window_length/n_bins;
        
    min_range = window_start;
    max_range = window_start + window_length;
    
    alpha = beam_width * n_beams/2;
    x0 = min_range*cos(alpha);
    x_span = max_range - x0;
    y0 = -max_range*sin(alpha);
    y_span = -2*y0;
    
    y_scale = y_span ./ width;
    height = round(x_span ./ y_scale);
    x_scale = x_span ./ height;

    res_x = abs(height./x_span); % px/m (invert to obtain size of each pixel)
    res_y = abs(-width./y_span); % px/m 
    
    cart_frame = zeros(width, height);
    
    for i=1:height
        x = x0 + (i-1)*x_scale;
        for j=1:width
            y = y0 + (j-1)*y_scale;
            
            beam = n_beams/2 - floor(atan2(y, x)/beam_width);
            bin = floor( (sqrt( x*x + y*y) - min_range)/bin_width );
                
            if ( beam < 0 || beam >= n_beams || bin < 0 || bin >= n_bins)
                cart_frame(j,i) = 0;
            else
                cart_frame(j,i) = double(polar_frame(bin+1, beam+1));
            end
        end
    end

end

