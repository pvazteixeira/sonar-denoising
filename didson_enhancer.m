% DIDSON_LCM_TO_MAT.M A script to enhance DIDSON frames
% 
% The purpose of this script is to listen for DIDSON frames, enhance them
% using deconvolution/noise reduction/... and republish them on a different
% channel.
% Could modify this script to also serve as a lcm to mat converter.
%
% Pedro Vaz Teixeira (PVT), May 2014
% pvt@mit.edu

close all;  % close any open figures
clc;        % clear the console

lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();

lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames

message_count = 0;

live_view = true;
figure;

beam=zeros(1,96);
beam(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[  24 24 24 27 32 40 70 40 32 27 24 24];
PSF = (1/sum(sum(beam)))*beam;

while true
    millis_to_wait = 10;
    msg = aggregator.getNextMessage(millis_to_wait);
    if ~isempty(msg) > 0
        message_count = message_count + 1;  % increase message counter;
        message_in = hauv.didson_t(msg.data);    % got a new message
        
        % time ( [ Y M D H M S ] )
        %{
        data.time{message_count} = [ message.m_nYear, ...
                                     message.m_nMonth, ...
                                     message.m_nDay, ...
                                     message.m_nHour, ...
                                     message.m_nMinute, ...
                                     message.m_nSecond];
        data.u_time{message_count} = message.m_dVehicleTime;
        %}
                       
        % receiver gain
        %data.gain{message_count} = message.m_nReceiverGain;
                                 
        % frame data
        serialized_image_data = typecast(message_in.m_cData, 'uint8');
        frame = im2double(flip(reshape(serialized_image_data, 96, 512)')); % deserialize & store
        window_start = 0.375*message_in.m_nWindowStart;       
        window_length = 1.125*(power(2,(message_in.m_nWindowStart)));
        
        % pose data
        x = message_in.m_fSonarXOffset;
        y = message_in.m_fSonarYOffset;
        z = message_in.m_fSonarZOffset;
        yaw = deg2rad(message_in.m_fSonarPan + message_in.m_fSonarPanOffset);
        pitch = deg2rad(message_in.m_fSonarTilt + message_in.m_fSonarTiltOffset);
        roll = deg2rad(message_in.m_fSonarRoll + message_in.m_fSonarRollOffset);
        
        x = message_in.m_fSonarX;
        y = message_in.m_fSonarY;
        z = message_in.m_fSonarZ;
        yaw = message_in.m_fHeading;
        pitch = message_in.m_fPitch;
        roll = message_in.m_fRoll;
        
        % enhance        
        estimated_nsr = 0.0018; % replace with experimentally determined value
        enhanced_frame = deconvwnr(frame, PSF, estimated_nsr);
        enhanced_frame = (1/max(enhanced_frame(:)))*enhanced_frame;
        %enhanced_frame = max(frame(:))*enhanced_frame; %correct for same max intensity as the original image
    
        % serialize
        
        % republish on other channel
        message_out = message_in;
        %message_out.m_cData =
        lc.publish('HAUV_DIDSON_FRAME_ENHANCED', message_out);

        
        if ( live_view )
            if (mod(message_count, 1)==0)
                % auv position
                %pose = cell2mat(data.vehicle_pose);
                %subplot(1,3,1:2);
                %plot3(pose(1,:), pose(2,:), pose(3,:),'-b.');
                %axis equal;

                % sonar
                subplot(1,4,1);
                imshow(frame);
                xlabel('Azimuth');
                ylabel('Range');   
                
                subplot(1,4,2);
                imshow(enhanced_frame);
                xlabel('Azimuth');
                ylabel('Range');   
                
                subplot(1,4,3)
                [counts, x] = imhist(enhanced_frame);
                
                subplot(1,4,4);
                threshold = max(0.4, mean(enhanced_frame(:)) + 5*sqrt(var(enhanced_frame(:))))
                imshow(im2bw(enhanced_frame, threshold));
                %{
                hold on
                for beam=1:96
                   [val, idx] = max(enhanced_frame(:,beam)); 
                   if val > 0.5
                       plot(idx, beam, 'r.');
                   end
                end
                %}
                drawnow;
            end
        end             
    end
end
