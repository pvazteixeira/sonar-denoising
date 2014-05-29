% LCM_TO_MAT.M A function to convert DIDSON data to a MATLAB-friendly format
% 
% 

close all;  % close any open figures
clc;        % clear the console

lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();

lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames


data.time = [];
data.u_time = [];   

% poses [ x y z yaw pitch roll ]
data.sonar_pose = [];   % the sonar's pose
data.sonar_offset = []; % the offset from the vehicle to the sonar
data.vehicle_pose = []; % the vehicle's pose

% image data
data.frame = [];
data.gain

message_count = 0;

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
        
        
        
    end
end

