% FLS_LISTENER.M A simple script to view 3DFLS data from lcm logs
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu

lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();

lc.subscribe('RAW_PING', aggregator);    % subscribe to 3DFLS

close all;
clc;

while true
    millis_to_wait = 10;
    msg = aggregator.getNextMessage(millis_to_wait);
    if ~isempty(msg) > 0
        m = hauv.raw_ping_t(msg.data);
                
        serializedImageData = typecast(m.depth_image, 'uint16');
        serializedImageData = double(serializedImageData)./double(intmax('uint16'));

        frame = im2double(flip(reshape(serializedImageData, m.width, m.height)'));
        
%         delta_r = (m.range_stop - m.range_start )/ m.height;
%         delta_a = 28/135; % confirm fov
        
        % hackish: assumes beams are sent in order (they are, but this is ugly)
        beam_number = 1 + mod(m.ping_number,3);
        
        subplot(1, 3, beam_number);
        imshow(255*frame);

        ylabel('Range [m]');
        xlabel('Angle');
        title(['Beam ',num2str(1+mod(m.ping_number,3))]);

        drawnow;        
    end
end
