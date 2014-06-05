% DIDSON_LCM_TO_MAT.M A function to convert DIDSON data to a MATLAB-friendly format
% 
% Pedro Vaz Teixeira (PVT), May 2014
% pvt@mit.edu

close all;  % close any open figures
clc;        % clear the console

lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();

lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames

% time
data.time = [];
data.u_time = [];   

% poses [ x y z yaw pitch roll ]
data.sonar_pose = [];   % the sonar's pose (in the platform frame)
data.vehicle_pose = []; % the vehicle's pose (in the global frame)

% image data
data.frame = [];
data.gain = [];

message_count = 0;


live_view = true;

while true
    millis_to_wait = 10;
    msg = aggregator.getNextMessage(millis_to_wait);
    if ~isempty(msg) > 0
        message_count = message_count + 1;  % increase message counter;
        message = hauv.didson_t(msg.data);    % got a new message
        
        % time ( [ Y M D H M S ] )
        data.time{message_count} = [ message.m_nYear, ...
                                     message.m_nMonth, ...
                                     message.m_nDay, ...
                                     message.m_nHour, ...
                                     message.m_nMinute, ...
                                     message.m_nSecond];
        data.u_time{message_count} = message.m_dVehicleTime;
                                 
        % receiver gain
        data.gain{message_count} = message.m_nReceiverGain;
                                 
        % frame data
        serialized_image_data = typecast(message.m_cData, 'uint8');
        data.frame{message_count} = flip(reshape(serialized_image_data, 96, 512)'); % deserialize & store
        data.window_start{message_count} = 0.375*message.m_nWindowStart;       
        data.window_length{message_count} = 1.125*(power(2,(message.m_nWindowStart)));
        
        % pose data
        x = message.m_fSonarXOffset;
        y = message.m_fSonarYOffset;
        z = message.m_fSonarZOffset;
        yaw = deg2rad(message.m_fSonarPan + message.m_fSonarPanOffset);
        pitch = deg2rad(message.m_fSonarTilt + message.m_fSonarTiltOffset);
        roll = deg2rad(message.m_fSonarRoll + message.m_fSonarRollOffset);
        data.sonar_pose{message_count} = [x; y; z; yaw; pitch; roll;];
        
        x = message.m_fSonarX;
        y = message.m_fSonarY;
        z = message.m_fSonarZ;
        yaw = message.m_fHeading;
        pitch = message.m_fPitch;
        roll = message.m_fRoll;
        data.vehicle_pose{message_count} = [x; y; z; yaw; pitch; roll;];
        
        if ( live_view )
            if (mod(message_count, 10)==0)
                % auv position
                pose = cell2mat(data.vehicle_pose);
                subplot(1,3,1:2);
                plot3(pose(1,:), pose(2,:), pose(3,:),'-b.');
                axis equal;

                % sonar
                subplot(1,3,3);
                imshow(data.frame{message_count});
                xlabel('Azimuth');
                ylabel('Range');   

                drawnow;
            end
        end
             
    end
end

