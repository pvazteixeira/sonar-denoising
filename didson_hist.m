% DIDSON_HIST.M A live histogram viewer for the DIDSON sonar
%
% The purpose of this script is to listen for DIDSON frames and compute the
% respective histograms, to help determining the best sonar gain.
%
% Pedro Vaz Teixeira (PVT), June 2015
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

%% Initialization
message_count = 0;
frame_reduction_factor = 4; % increase if playing logs faster than real time
edges = linspace(0,1,25);
h = figure();
xlim([0 1])
ylim([0 512*96])

%% Main processing loop
while true
  millis_to_wait = 1;
  msg = aggregator.getNextMessage(millis_to_wait);

  if ~isempty(msg)
    message_count = message_count + 1;      % increase message counter;
    if ( rem(message_count, frame_reduction_factor) == 0 )
      tic
      
      message_in = hauv.didson_t(msg.data);   % got a new message
      serialized_image_data = typecast(message_in.m_cData, 'uint8');  % frame data
      frame = im2double((reshape(serialized_image_data, 96, 512)));   % deserialize & store
      enhanced_frame = enhance(frame, 0, 0);    
  
      set(0, 'CurrentFigure', h);
      clf;
      histogram(frame(:),edges);
      hold on
      histogram(enhanced_frame(:),edges);
      grid on
      set(gca,'YScale','log')
      
      % the following lines are commented out as they significantly slow
      % everything down
%     legend('raw','enhanced')
%     xlabel('intensity')
%     ylabel('count')
      drawnow;       

      toc
    end
  end
end
