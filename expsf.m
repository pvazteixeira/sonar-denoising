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

%% ENHANCE.M PSF
beam = zeros(1,96);
%beam = 20*ones(1,96);
beam(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[  24 24 24 27 32 40 70 40 32 27 24 24];
% beam(1,[48 50]) = 0.8633*[70 70];
% beam(1,[47,51]) = 0.6148*[70 70];
% beam(1,[46,52]) = 0.5204*[70 70];
% beam(1,[45,51]) = 0.1801*[70 70];
PSF = (1/sum(sum(beam)))*beam';

PSF = circshift(PSF,1);

PSF_E = ones(1,96);

N = 0;

rwl = 70;
% 06
R = 327;
A = 50;

% 07
% R = 37;
% A = 50;

% 10
R = 163;
A = 54;

rmin = R-10;
rmax = min(512, R+rwl+1);

PSF_R = ones(2*rwl+1,1);

%% Main processing loop
while true
    millis_to_wait = 1000;
    msg = aggregator.getNextMessage(millis_to_wait);
    
    if ~isempty(msg)
        tic
        frame_msg = hauv.didson_t(msg.data);   % got a new message
        serialized_image_data = typecast(frame_msg.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
              
        N = N+1;
        
        %% show original and enhanced
        %{
        window_start =  0.375 * frame_msg.m_nWindowStart;
        window_length = 1.125*(power(2,(frame_msg.m_nWindowLength)));
        max_range = window_start + window_length;
        max_range_e = max_range + 1; % used to generate endpoints beyond max range for empty beam measurements
        subplot(1,2,1)
        imshow(polarToCart(frame,window_start,window_length,300)')
        title('original')
        subplot(1,2,2)
        imshow(polarToCart(enhanced_frame,window_start,window_length,300)')
        title('enhanced')
        %hold on
        drawnow
        %}
        
        
        
        if (1 == N)
            PSF_E = frame(:,R)';
            PSF_R = frame(A,rmin:rmax)';
        else            
            PSF_E =((N-1)/N)*PSF_E + (1/N)*frame(:,R)';
            PSF_R =((N-1)/N)*PSF_R + (1/N)*frame(A,rmin:rmax)';
        end
        
        %PSF_E = min(PSF_E, frame(:,R)');
%         PSF_R = min(PSF_R, frame(A,(R-rwl):(R+rwl))');
        
        %plot(1:96,frame(:,326),'r')
        
        subplot(1,2,1)
        plot(1:96,frame(:,R),'g','LineWidth',2)
        hold on
        plot(1:96,PSF_E,'-b.','LineWidth',2)
        %plot(1:96,frame(:,328),'b')
        plot(1:96,PSF,'k','LineWidth',2)
        hold off
        subplot(1,2,2)
        hold off
        plot(frame(A,rmin:rmax),'g','LineWidth',2)
        hold on
        plot(PSF_R,'-b.','LineWidth',2)
        
        drawnow
        
        toc
    end
end
