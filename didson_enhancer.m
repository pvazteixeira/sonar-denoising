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
    millis_to_wait = 1000;
    msg = aggregator.getNextMessage(millis_to_wait);
    
    if ~isempty(msg)
        tic
        frame_msg = hauv.didson_t(msg.data);   % got a new message
        serialized_image_data = typecast(frame_msg.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
        
        %{
        if( min(frame(:)) < 0)
            disp(['warning: frame has negative values! (min=',num2str(min(enhanced_frame(:))),')'])
        end
        %}
        
        %% Image enhancement
        enhanced_frame = enhance(frame, 0, 0);
        if( min(enhanced_frame(:)) < 0)
            disp(['warning: enhanced frame has negative values! (min=',num2str(min(enhanced_frame(:))),')'])
        end

        % adding median filter (pvt, 2015.11.23)
        enhanced_frame = medfilt2(enhanced_frame);
                
        %% re-transmit improved image
        %
        frame_msg.m_cData = typecast(reshape(im2uint8(enhanced_frame),512*96,1),'int8');
        lc.publish('HAUV_DIDSON_FRAME_ENHANCED', frame_msg);     
        %}
        
        %% show original and enhanced
        %{
        window_start =  0.375 * frame_msg.m_nWindowStart;
        window_length = 1.125*(power(2,(frame_msg.m_nWindowLength)));
        max_range = window_start + window_length;
        max_range_e = max_range + 1; % used to generate endpoints beyond max range for empty beam measurements
        subplot(1,2,1)
        imshow(polarToCart(frame,window_start,window_length,500)')
        title('original')
        subplot(1,2,2)
        imshow(polarToCart(enhanced_frame,window_start,window_length,500)')
        title('enhanced')
        %hold on
        drawnow
        %}
        
        %% Transforms
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
        %{
        sonar_origin = [frame_msg.m_fSonarX; frame_msg.m_fSonarY; frame_msg.m_fSonarZ;];
        
        % vehicle/platform to global (from NAV)
        gTv = getTransform( sonar_origin, deg2rad([frame_msg.m_fHeading, frame_msg.m_fPitch, frame_msg.m_fRoll]));
        
        % DVL/basket to vehicle - basket pitch is variable, but not reported in the didson frame!!!!
        vTd = getTransform( [0 0 0]', deg2rad([0 frame_msg.m_fSonarRoll + frame_msg.m_fSonarRollOffset 0]));
        
        % didson cage to DVL/basket - cage pitch/pan is variable
        dTc = getTransform( [0, 0.30, 0]', deg2rad([frame_msg.m_fSonarPan+frame_msg.m_fSonarPanOffset frame_msg.m_fSonarTilt + frame_msg.m_fSonarTiltOffset 0]));
        
        % focus point to didson cage - focus point position is variable (assume fixed for now)
        cTf = getTransform( [-0.115, 0, -0.07]', deg2rad([0 0 0]));
        
        % image to focus point - (should be) fixed
        fTi = getTransform( [0 0 0]', deg2rad([0 0 0]));

        gTi = gTv * vTd * dTc * cTf * fTi;
        %}
        
        %% extract returns
        %{  
        returns_didson_frame = zeros(4,96);
        ranges = zeros(1,96);
        threshold = max(0.43, mean(enhanced_frame(:)) + 3 * sqrt(var(enhanced_frame(:))));

        scan_msg = hauv.sonar_scan_t();
        scan_msg.num_beams = 96;
        beam_msgs(1:96,1) = hauv.sonar_range_t();

        for beam = 1:96
            theta = beam_width * (48 - beam);
            iTb = getTransform([0 0 0]', [theta 0 0]);  % image to beam
            
            [p, a] = getPose(gTi*iTb);  % beam pose
            beam_msgs(beam).origin = p;
            beam_msgs(beam).orientation = [a; 0] ;
            
            beam_msgs(beam).max_range = max_range;
            beam_msgs(beam).hfov = 0.3*pi/180;  %deg2rad(0.3);
            beam_msgs(beam).vfov = pi/180;      %deg2rad(1.0);
            
            % find max in beam
            [value, index] = max(enhanced_frame(beam, : ));
            if value > threshold;
                % if the return exceeds the threshold, map it in the sonar frame              
                range = window_start + window_length * ((index)/512);
                beam_msgs(beam).endpoint = gTi*[range*cos(theta); range*sin(theta); 0; 1];
                beam_msgs(beam).range = range;
            else
                % else, consider the beam to be "empty/free"
                beam_msgs(beam).endpoint = gTi*[max_range_e*cos(theta); max_range_e*sin(theta); 0; 1];
                beam_msgs(beam).range = -1; 
            end
        end      
        scan_msg.beams = beam_msgs;

        lc.publish('SONAR_SCANS', scan_msg);     
        %}
        toc
    end
end
