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
beam_width = deg2rad(28.8/96);    % 29 degree HFOV x 96 beams

%% Main processing loop
while true
    millis_to_wait = 1;
    msg = aggregator.getNextMessage(millis_to_wait);
    
    if ~isempty(msg)
        %tic
        message_in = hauv.didson_t(msg.data);   % got a new message
        
        serialized_image_data = typecast(message_in.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
                
        window_start = 0.375 * message_in.m_nWindowStart;
        window_length = 1.125*(power(2,(message_in.m_nWindowLength)));
        max_range = window_start + window_length;
        
        enhanced_frame = enhance(frame, 0, 0);
                
        %% extract returns
        returns_didson_frame = zeros(4,96);
        ranges = zeros(1,96)
        threshold = max(0.43, mean(enhanced_frame(:)) + 3 * sqrt(var(enhanced_frame(:))));
        
        % TO DO: 
        % - don't extract unless depth > 0.5
        % - try and replace with something other than a for loop;
        %     else, merge the two for loops
        for beam = 1:96
            % find max in beam
            [value, index] = max(enhanced_frame(beam, : ));
            if value > threshold;
                % if the return exceeds the threshold, map it in the sonar frame
                range = window_start + window_length * ((index)/512);
                theta = beam_width * (48 - beam);
                returns_didson_frame(:, beam) = [range*cos(theta); ...
                                    range*sin(theta); 0; 1];
                ranges(beam) = range;
            else
                % else, consider the beam to be "empty/free"
                returns_didson_frame(:, beam) = [range*cos(theta); range*sin(theta); 0; 1];
                ranges(beam) = -1; 
            end
        end      

        sonar_origin = [message_in.m_fSonarX; message_in.m_fSonarY; message_in.m_fSonarZ;]
        
        % move transform computation here.
        
        scan_msg = hauv_sonar_scan_t();
        for beam = 1:96
            beam_msg = hauv_sonar_range_t();

            beam_msg.origin = sonar_origin;
            beam.msg.orentation =           
            beam_msg.range = ranges(beam)
            beam_msg.max_range = max_range;
            beam_msg.endpoint = 
            beam_msg.hfov = rad2deg(0.3);
            beam_msg.vfov = rad2deg(1.0);
            
            scan_msg.beams(beam) = beam_msg;
        end
       
            %% register returns
            %{
            Reference frames:
                0/g - global
                1/v - vehicle
                2/d - dvl/basket
                3/c - didson cage
                4/f - didson focal point
                5/i - image frame
            %}

            %% SPLIT
            %
            clc
%             disp('Vehicle pose')
%             disp([message_in.m_fSonarX; message_in.m_fSonarY; message_in.m_fSonarZ; message_in.m_fHeading; message_in.m_fPitch; message_in.m_fRoll]')
%             disp('Sonar attitude')
%             disp([message_in.m_fSonarPan, message_in.m_fSonarTilt, message_in.m_fSonarRoll]);
%             disp('Sonar attitude - offsets')
%             disp([message_in.m_fSonarPanOffset, message_in.m_fSonarTiltOffset, message_in.m_fSonarRollOffset]);
            % vehicle/platform to global (from NAV)
            gTv = getTransform( [message_in.m_fSonarX; message_in.m_fSonarY; message_in.m_fSonarZ;], ...
                                deg2rad([message_in.m_fHeading, message_in.m_fPitch, message_in.m_fRoll]));

            % DVL/basket to vehicle - basket pitch is variable, but not
            % reported in the didson frame!!!!
            vTd = getTransform( [0 0 0]', ...
                                deg2rad([0 message_in.m_fSonarRoll + message_in.m_fSonarRollOffset 0]));

            % didson cage to DVL/basket - cage pitch/pan is variable
            dTc = getTransform( [0, 0.30, 0]', ...
                                deg2rad([message_in.m_fSonarPan+message_in.m_fSonarPanOffset message_in.m_fSonarTilt + message_in.m_fSonarTiltOffset 0]));

            % focus point to didson cage - focus point position is variable
            % (assume fixed for now)
            cTf = getTransform( [-0.115, 0, -0.07]', ...
                                deg2rad([0 0 0]));

            % image to focus point - (should be) fixed
            fTi = getTransform( [0 0 0]', ...
                                deg2rad([0 0 0]));
            %}

            returns_local = vTd * dTc * cTf * fTi * returns_didson_frame;
            returns_global = gTv * returns_local;

            %% publish returns
            %{
            points_msg = hauv.sonar_points_t();
            points_msg.pos = [message_in.m_fSonarX; message_in.m_fSonarY; message_in.m_fSonarZ;];
            %[y, p, r ] = dcm2angle(R_global_local*R_local_didson);
            %points_msg.orientation = [y, p, r, 0];

            points_msg.n = int32(return_count);
            points_msg.points_global = returns_global(1:3,:)';
            points_msg.points_local = returns_local(1:3,:)';

            lc.publish('SONAR_POINTS', points_msg);
            %}       
    end
end
