% DIDSON_ENHANCER.M A live script to DIDSON frames and extract returns
% 
% The purpose of this script is to listen for DIDSON frames, enhance them
% using deconvolution/noise reduction/... and then extract returns, which
% are then registered spatially using information from SONAR and vehicle 
% poses.
%
% Pedro Vaz Teixeira (PVT), July 2014
% pvt@mit.edu

%% Clean up
close all;  % close any open figures
clc;        % clear the console
clear;
addjars;

%% LCM 
lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();
lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames

%% DIDSON parameters
beam_width = deg2rad(29/96);    % 29 degree HFOV x 96 beams

%% Initialization

message_count = 0;

live_view = true; % enable to get live viewing of raw and enhanced data
make_movie = false;
if (make_movie)
    outputVideo = VideoWriter('myfile');
    open(outputVideo);
end
figh = figure;

%% Main processing loop
while true
    millis_to_wait = 1;
    msg = aggregator.getNextMessage(millis_to_wait);

    if ~isempty(msg) > 0
        tic
        message_count = message_count + 1;      % increase message counter;
        message_in = hauv.didson_t(msg.data);   % got a new message
                                 
        serialized_image_data = typecast(message_in.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
        
        window_start = 0.375 * message_in.m_nWindowStart;       
        window_length = 1.125*(power(2,(message_in.m_nWindowStart)));
        
        %
        subplot(2,1,1)
        imshow(frame);
        ylabel('angle')
        xlabel('range')
        title('raw frame')
        %}
        %% enhance frame
        enhanced_frame = enhance(frame, 0, 0);      
        %
        subplot(2,1,2);
		hold off;        
		imshow(enhanced_frame);
        ylabel('angle')
        xlabel('range')
        title('enhanced frame');
		hold on;        
        %}
        %% extract returns
        %
        returns_didson_frame = [];
        threshold = max(0.43, mean(enhanced_frame(:)) + 3 * sqrt(var(enhanced_frame(:))));
        
        %
        for beam = 1:96
            % find max in beam
            [value, index] = max(enhanced_frame(beam, : ));          
            if value > threshold;
                % if the return exceeds the threshold, map it in the sonar frame
                plot(index, beam, 'r.');
                range = window_start + window_length * ((index)/512);
                theta = beam_width * (48 - beam);
                returns_didson_frame = [returns_didson_frame, [range*cos(theta); range*sin(theta); 0; 1]];
            end
        end
        %}
        %returns_didson_frame = [0;0;0;1];   % DEBUG
        return_count = size(returns_didson_frame, 2);
              
        %drawnow;
        %}
        
        if(return_count>0)
            %% register returns 
            %

            % convention: 
            % - aTb transforms from 'b' to 'a' (homogenous transformation
            % matrix)
            % - aRb is the rotation from 'b' to 'a'
            % - r_a is a pose in the 'a' reference frame
            % - r_Ob_a is the position of the origin of the 'b' frame in
            % the 'a' frame
            % - homogeneous transform matrices are thus:
            %   [ aRb        r_Ob_a
            %     zeros(3,1) 1]
            %
            %{
            Reference frames:
                0/g - global
                1/v - vehicle
                2/d - dvl/basket
                3/c - didson cage
                4/f - didson focal point
                5/i - image frame
            %}

            %% HALF-SPLIT
            %
            % vehicle to global (from NAV)
            gTv = getTransform( [message_in.m_fSonarX; message_in.m_fSonarY; message_in.m_fSonarZ;], ...
                                deg2rad([message_in.m_fHeading, message_in.m_fPitch, message_in.m_fRoll]));
            % DVL/basket to vehicle - basket pitch is variable
            vTd = getTransform( [], ...
                                deg2rad([]));
            % didson cage to DVL/basket - cage pitch/pan is variable
            dTc = getTransform( [0, 0.2, 0], ...
                                deg2rad([]));
            % focus point to didson cage - focus point position is variable
            cTf = getTransform( [], ...
                                deg2rad([]));
            % image to focus point - (should be) fixed
            fTi = getTransform( [], ...
                                deg2rad([]));
            %}

            %% publish returns
            %
            msg_out = hauv.sonar_points_t();
            msg_out.pos = (local_position_global + R_global_local*didson_position_local)';
            [y, p, r ] = dcm2angle(R_global_local*R_local_didson);
            msg_out.orientation = [y, p, r, 0];

            msg_out.n = int32(return_count);
            msg_out.points_global = returns_global(1:3,:)';
            msg_out.points_local = returns_local(1:3,:)';

            lc.publish('SONAR_POINTS', msg_out);
            %}
        end
            
        %% plotting
        
        if ( live_view )
            if (mod(message_count, 1)==0)
                % auv position
                %{
                pose = cell2mat(data.vehicle_pose);
                subplot(1,3,1:2);
                plot3(pose(1,:), pose(2,:), pose(3,:),'-b.');
                axis equal;
                %}

                % sonar
                %{
                subplot(1,2,1);
                imshow(frame);
                xlabel('Azimuth');
                ylabel('Range');  
                title('Raw');
                
                subplot(1,2,2);
                imshow(enhanced_frame);
                xlabel('Azimuth');
                ylabel('Range');  
                title('Enhanced');               
                %}
            
               
                %{
                subplot(1,4,3)
                [counts, x] = imhist(enhanced_frame);
                
                subplot(1,4,4);
                threshold = max(0.4, mean(enhanced_frame(:)) + 5*sqrt(var(enhanced_frame(:))))
                imshow(im2bw(enhanced_frame, threshold));
                %}
                %{
                hold on
                for beam=1:96
                   [val, idx] = max(enhanced_frame(:,beam)); 
                   if val > 0.5
                       plot(idx, beam, 'r.');
                   end
                end
                %}
                
                
                if ( make_movie )
                    imshow([frame,enhanced_frame]);
                    %set(figh, 'Position', [100, 100, 800, 600]);
                    drawnow;
                    F(message_count) = getframe;
                   
                else
                    drawnow
                end
            end
        end
        toc
    end
end


%% export movie
clc;
for k=1:message_count-1
    writeVideo(outputVideo,F(k));
end

close(outputVideo);