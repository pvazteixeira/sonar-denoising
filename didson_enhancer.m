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
beam_width = deg2rad(28.8/96);    % 0.3 degree HFOV/beam x 96 beams

%% Main processing loop
while true
    millis_to_wait = 1;
    msg = aggregator.getNextMessage(millis_to_wait);
    
    if ~isempty(msg)
        %tic
        frame_msg = hauv.didson_t(msg.data);   % got a new message
        
        serialized_image_data = typecast(frame_msg.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
                
        window_start = 0.375 * frame_msg.m_nWindowStart;
        window_length = 1.125*(power(2,(frame_msg.m_nWindowLength)));
        max_range = window_start + window_length;
        
        enhanced_frame = enhance(frame, 0, 0);
                
        %% extract returns
        returns_didson_frame = zeros(4,96);
        ranges = zeros(1,96);
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

        sonar_origin = [frame_msg.m_fSonarX; frame_msg.m_fSonarY; frame_msg.m_fSonarZ;];
        
        %{
        Reference frames:
        0/g - global
        1/v - vehicle
        2/d - dvl/basket
        3/c - didson cage
        4/f - didson focal point
        5/i - image frame
        %}
        
        %             disp('Vehicle pose')
        %             disp([frame_msg.m_fSonarX; frame_msg.m_fSonarY; frame_msg.m_fSonarZ; frame_msg.m_fHeading; frame_msg.m_fPitch; frame_msg.m_fRoll]')
        %             disp('Sonar attitude')
        %             disp([frame_msg.m_fSonarPan, frame_msg.m_fSonarTilt, frame_msg.m_fSonarRoll]);
        %             disp('Sonar attitude - offsets')
        %             disp([frame_msg.m_fSonarPanOffset, frame_msg.m_fSonarTiltOffset, frame_msg.m_fSonarRollOffset]);
        
        % vehicle/platform to global (from NAV)
        gTv = getTransform( sonar_origin, deg2rad([frame_msg.m_fHeading, frame_msg.m_fPitch, frame_msg.m_fRoll]));
        
        % DVL/basket to vehicle - basket pitch is variable, but not
        % reported in the didson frame!!!!
        vTd = getTransform( [0 0 0]', deg2rad([0 frame_msg.m_fSonarRoll + frame_msg.m_fSonarRollOffset 0]));
        
        % didson cage to DVL/basket - cage pitch/pan is variable
        dTc = getTransform( [0, 0.30, 0]', deg2rad([frame_msg.m_fSonarPan+frame_msg.m_fSonarPanOffset frame_msg.m_fSonarTilt + frame_msg.m_fSonarTiltOffset 0]));
        
        % focus point to didson cage - focus point position is variable
        % (assume fixed for now)
        cTf = getTransform( [-0.115, 0, -0.07]', deg2rad([0 0 0]));
        
        % image to focus point - (should be) fixed
        fTi = getTransform( [0 0 0]', deg2rad([0 0 0]));

        gTi = gTv * vTd * dTc * cTf * fTi;
        
        [~, attitude] = getPose(gTi);
        
        scan_msg = hauv.sonar_scan_t();
        scan_msg.num_beams = 96;
        %scan_msg.beams = hauv.sonar_range_t();
        beam_msgs(96,1) = hauv.sonar_range_t;
        for beam = 1:96
            beam_msgs(beam) = hauv.sonar_range_t();

            beam_msgs(beam).origin = sonar_origin;
            beam_msgs(beam).orientation = [attitude; 0];
            
            beam_msgs(beam).range = ranges(beam);
            beam_msgs(beam).max_range = max_range;
            
            beam_msgs(beam).endpoint = gTv * returns_didson_frame(:,beam);

            beam_msgs(beam).hfov = rad2deg(0.3);
            beam_msgs(beam).vfov = rad2deg(1.0);
        end
        scan_msg.beams(beam) = beam_msgs;
        lc.publish('SONAR_POINTS', scan_msg);     
    end
end
