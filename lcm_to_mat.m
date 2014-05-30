% LCM_TO_MAT.M A function to convert DIDSON data to a MATLAB-friendly format
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
        data.time{message_count} = [ typecast(message.m_nYear, 'int32'), ...
                                     typecast(message.m_nMonth, 'int32'), ...
                                     typecast(message.m_nDay, 'int32'), ...
                                     typecast(message.m_nHour, 'int32'), ...
                                     typecast(message.m_nMinute, 'int32'), ...
                                     typecast(message.m_nSecond, 'int32')];
        data.u_time{message_count} = typecast(message.m_dVehicleTime, 'double');
                                 
        % receiver gain
        data.gain{message_count} = typecast(message.m_nReceiverGain, 'int32');
        
                                 
        % frame data
        serialized_image_data = typecast(message.m_cData, 'uint8');
        data.frame{message_count} = flip(reshape(serialized_image_data, 96, 512)'); % deserialize & store
               
        % pose data
        x = typecast(message.m_fSonarXOffset, 'double');
        y = typecast(message.m_fSonarYOffset, 'double');
        z = typecast(message.m_fSonarZOffset, 'double');
        yaw = deg2rad(typecast(message.m_fSonarPan, 'double') + typecast(message.m_fSonarPanOffset, 'double'));
        pitch = deg2rad(typecast(message.m_fSonarTilt, 'double') + typecast(message.m_fSonarTiltOffset, 'double'));
        roll = deg2rad(typecast(message.m_fSonarRoll, 'double') + typecast(message.m_fSonarRollOffset, 'double'));
        data.sonar_pose{message_count} = [x; y; z; yaw; pitch; roll;];
        
        x = typecast(message.m_fSonarX, 'double');
        y = typecast(message.m_fSonarY, 'double');
        z = typecast(message.m_fSonarZ, 'double');
        yaw = typecast(message.m_fHeading, 'double');
        pitch = typecast(message.m_fPitch, 'double');
        roll = typecast(message.m_fRoll, 'double');
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

