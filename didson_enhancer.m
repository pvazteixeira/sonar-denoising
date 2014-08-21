% DIDSON_ENHANCER.M A live script to DIDSON frames and extract returns
% 
% The purpose of this script is to listen for DIDSON frames, enhance them
% using deconvolution/noise reduction/... and then extract returns, which
% are then registered spatially using information from SONAR and vehicle 
% poses.
%
% Pedro Vaz Teixeira (PVT), July 2014
% pvt@mit.edu

%% init

close all;  % close any open figures
clc;        % clear the console
clear;
addjars;

%% LCM 
lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();
lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames

%% DIDSON parameters
beam_width = deg2rad(29/96);

%%

message_count = 0;

live_view = true; % enable to get live viewing of raw and enhanced data
make_movie = false;
if (make_movie)
    outputVideo = VideoWriter('myfile');
    open(outputVideo);
end
figh = figure;

% psf creation (isotropic, simplified)
beam = zeros(1,96);
beam(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[  24 24 24 27 32 40 70 40 32 27 24 24];
PSF = (1/sum(sum(beam)))*beam;

window_length_ref = [ 1.125, 2.25, 4.5, 9.0];

while true
    millis_to_wait = 10;
    msg = aggregator.getNextMessage(millis_to_wait);
    if ~isempty(msg) > 0
        message_count = message_count + 1;  % increase message counter;
        message_in = hauv.didson_t(msg.data);    % got a new message
                                 
        % frame data
        serialized_image_data = typecast(message_in.m_cData, 'uint8');
        frame = im2double((reshape(serialized_image_data, 96, 512)')); % deserialize & store
        window_start = 0.375 * message_in.m_nWindowStart;       
        %window_length = 1.125*(power(2,(message_in.m_nWindowStart)));
        window_length = window_length_ref(message_in.m_nWindowStart+1);
        
        %% enhance frame
        enhanced_frame = enhance(frame, 0, 0);      

        %% extract returns
        %
        
        returns_didson_frame = [];
        threshold = 110/255;    % IMPORTANT : replace with something better (e.g. mean + N*stddev)
        threshold = max(0.43, mean(enhanced_frame(:)) + 3 * sqrt(var(enhanced_frame(:))));
        hold off;
        imshow(enhanced_frame);
        hold on;
        
        for beam = 1:96
            % find max in beam
            [value, index] = max(enhanced_frame(:, beam));          
            if value > threshold;
                % if the return exceeds the threshold, map it in the sonar frame
                plot(beam, index, 'r.');
                range = window_start + window_length * ((index)/512);
                theta = beam_width * (48 - beam);
                returns_didson_frame = [returns_didson_frame, [range*cos(theta); range*sin(theta); 0; 1]];
            end
             
        end
        return_count = size(returns_didson_frame,2);
       
        drawnow;
        %}
        
        %% register returns 
        
        % didson pose in the platform frame (m_pose_didson_local in didson_cv)
        didson_position = [ message_in.m_fSonarXOffset; 
                            message_in.m_fSonarYOffset; 
                            message_in.m_fSonarZOffset; ];
        didson_pan = deg2rad(message_in.m_fSonarPan + message_in.m_fSonarPanOffset);
        didson_tilt = deg2rad(message_in.m_fSonarTilt + message_in.m_fSonarTiltOffset);
        didson_roll = deg2rad(message_in.m_fSonarRoll + message_in.m_fSonarRollOffset);
        R_didson_local = angle2dcm(didson_pan, didson_tilt, didson_roll)';
        T_didson_local = [  R_didson_local, didson_position;
                            zeros(1,3),     1;];
        returns_local = T_didson_local*returns_didson_frame;
                        
        % platform pose in the global frame (m_pose_local_global in didson_cv)
        local_position = [  message_in.m_fSonarX; 
                            message_in.m_fSonarY; 
                            message_in.m_fSonarZ;];
        local_heading = deg2rad(message_in.m_fHeading);
        local_pitch = deg2rad(message_in.m_fPitch);
        local_roll = deg2rad(message_in.m_fRoll);       
        R_local_global = angle2dcm(local_heading, local_pitch, local_roll)';
        T_local_global = [  R_local_global, local_position;
                            zeros(1,3),     1;];
        returns_global = T_local_global*returns_local;
             
        
        %% publish returns
        msg_out = hauv.sonar_points_t();
        
        msg_out.pos = (local_position + R_local_global*didson_position)';
        [y, p, r ] = dcm2angle(R_local_global*R_didson_local);
        msg_out.orientation = [ y, p, r, 0];

        msg_out.n = int32(return_count);
        msg_out.points_global = returns_global(1:3,:)';
        msg_out.points_local = returns_local(1:3,:)';
        
        lc.publish('SONAR_POINTS', msg_out);
        
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
    end
end


%% export movie
clc;
for k=1:message_count-1
    writeVideo(outputVideo,F(k));
end

close(outputVideo);