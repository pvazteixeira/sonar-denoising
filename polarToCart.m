function [ cart_frame, res_x, res_y ] = polarToCart( polar_frame, window_start, window_length, width )
%polarToCart Convert DIDSON image to Cartesianframe
%   x is down range
%   y is 
%   resolution is the number of pixels per meter
%
%   Pedro Vaz Teixeira, May 2014
%   pvt@mit.edu

    % frame: rows are beams, columns are bins!

    % these are constants
    persistent n_beams beam_width n_bins alpha a 
    if ( isempty(n_beams))
        n_beams = 96;
        beam_width = deg2rad(0.3);
        n_bins = 512;
        alpha = beam_width * n_beams/2;
        a = [0.0030, -0.0055, 2.6829, 48.04];   % coeffs for distortion aware formula
    end
        
    % these change only if the sonar window changes (no need to compute
    % them constantly
    persistent bin_width min_range max_range x0 x_span y0 y_span y_scale height x_scale lut
    if ( isempty(bin_width) ||  min_range ~= window_start || max_range ~= window_start + window_length ) 
        bin_width = window_length/n_bins;     
        min_range = window_start;
        max_range = window_start + window_length;  

        x0 = min_range*cos(alpha);
        x_span = max_range - x0;
        y0 = -max_range*sin(alpha);
        y_span = -2*y0;

        y_scale = y_span ./ width;
        height = round(x_span ./ y_scale);
        x_scale = x_span ./ height;

%     res_x = abs(height./x_span); % px/m (invert to obtain size of each pixel)
%     res_y = abs(-width./y_span); % px/m 
        
        fprintf('Computing look-up table...');
        lut = zeros(height*width, 1);
        for j=1:width
            y = y0 + (j-1)*y_scale;
            for i=1:height
                x = x0 + (i-1)*x_scale;

                % simple geometry formula
                % beam = n_beams/2 - floor(atan2(y, x)/beam_width);

                % distortion-aware formula
                theta = rad2deg(atan2(y, x));
                beam = round(a(1)*theta^3 + a(2)*theta^2+a(3)*theta+a(4)+1);

                bin = floor( (sqrt( x*x + y*y) - min_range)/bin_width );

                
                if ( beam < 0 || beam >= n_beams || bin < 0 || bin >= n_bins)
                    lut(sub2ind([width height],j,i)) = 1;
                else
                     % frame: rows are beams, columns are bins!
                    lut(sub2ind([width height],j,i)) = sub2ind([n_beams n_bins], beam+1, bin+1);
%                     cart_frame(j,i) = double(polar_frame(beam+1,bin+1));
                end
            end
        end
        fprintf('done!\n');

    end
    
    polar_frame(1) = double(1.0); % sorry :(
    
    cart_frame = ones(width, height); % for publishing
    cart_frame(:) = double(polar_frame(lut));
    
    %{
    for i=1:height
        x = x0 + (i-1)*x_scale;
        for j=1:width
            y = y0 + (j-1)*y_scale;
            
            % simple geometry formula
            %beam = n_beams/2 - floor(atan2(y, x)/beam_width);
            
            % distortion-aware formula
            theta = rad2deg(atan2(y, x));
            beam = round(a(1)*theta^3 + a(2)*theta^2+a(3)*theta+a(4)+1);
            
            bin = floor( (sqrt( x*x + y*y) - min_range)/bin_width );
                
            if ( beam < 0 || beam >= n_beams || bin < 0 || bin >= n_bins)
                %cart_frame(j,i) = 0; % no need
            else
                cart_frame(j,i) = double(polar_frame(beam+1,bin+1));
            end
        end
    end
    %}
end

