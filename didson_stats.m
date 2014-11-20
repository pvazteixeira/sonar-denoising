%% Clean up
close all;  % close any open figures
clc;        % clear the console
clear;

java.lang.System.gc()

addjars;


%% LCM
lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();
lc.subscribe('HAUV_DIDSON_FRAME', aggregator);  % subscribe to didson frames

%% DIDSON parameters
beam_width = deg2rad(28.8/96);    % 0.3 degree HFOV/beam x 96 beams

N = 0;

mu = zeros(100000,1);
median = zeros(100000,1);
sigma = zeros(100000,1);

%% Main processing loop
while true
    millis_to_wait = 100;
    msg = aggregator.getNextMessage(millis_to_wait);
    
    if ~isempty(msg)
        tic
        frame_msg = hauv.didson_t(msg.data);   % got a new message
        serialized_image_data = typecast(frame_msg.m_cData, 'uint8');  % frame data
        frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
              
        N = N+1;
        
        subplot(4,1,1)
        %hist(frame(:),0:0.01:1)
        histfit(frame(:),256);
        pd = fitdist(frame(:), 'Normal');
        mu(N) = pd.mu;
        median(N) = pd.median;
        sigma(N) = pd.sigma;
        
        subplot(4,1,2)
        hold off
        plot(mu(1:N),'b')
        hold on
        plot(median(1:N),'r')
                
        subplot(4,1,3);
        plot(sigma(1:N),'r')

        subplot(4,1,4)
        imshow(frame);
        
        drawnow
        toc
    end
end
