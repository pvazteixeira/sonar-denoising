lc = lcm.lcm.LCM.getSingleton();
aggregator = lcm.lcm.MessageAggregator();

lc.subscribe('HAUV_DIDSON_FRAME', aggregator);    % subscribe to didson stuff

close all;

while true
    %disp waiting
    millis_to_wait = 10;
    msg = aggregator.getNextMessage(millis_to_wait);
    if ~isempty(msg) > 0
        % got one!
        disp('received frame!');
        m = hauv.didson_t(msg.data);
        serializedImageData =typecast(m.m_cData, 'uint8');
        % deserialize (duh)
        frame = flip(reshape(serializedImageData, 96, 512)');
               
        beam_intensity = sum(frame,1)/512;
        bin_intensity = sum(frame,2)/96;
        
        subplot(1,6,1)
        plot(beam_intensity,'b');
        hold on
        plot(smooth(beam_intensity),'r','LineWidth',2);
        ylim([0 255])
        xlim([0 95])
        title('Average intensity per beam');
        hold off
       
        subplot(1,6,2);
        imshow(frame);
        title('Raw frame');
         
        subplot(1,6,3)
        plot(flip(bin_intensity),0:511,'b');
        hold on;
        plot(smooth(flip(bin_intensity)),0:511,'r','LineWidth',2);
        xlim([0 255])
        ylim([0 511])
        title('Average intensity per bin');
        hold off
        %
        subplot(1,6,4)
        plot(flip(frame(:,1)),0:511,'b')
        hold on
        plot(flip(frame(:,48)),0:511,'g')
        plot(flip(frame(:,96)),0:511,'r')
        hold off
        xlim([0 255])
        ylim([0 511])
        title('beams 1, 48 and 96')

        subplot(1,6,5)
        plot(diff(smooth(double(flip(frame(:,1))))),0:510,'b');
        hold on
        plot(diff(smooth(double(flip(frame(:,48))))),0:510,'g');
        plot(diff(smooth(double(flip(frame(:,96))))),0:510,'r');
        hold off
        xlim([-20 20])
        ylim([0 510])
        title('derivatives for beams 1, 48 and 96')
        %}
        %{
        % side-detector
        subplot(1,6,6)
        imshow(frame);
        hold on;
        indices = find(bin_intensity>15);
        for i=1:length(indices)
            [val, ind] = max(frame(indices(i),:));
            plot(ind, indices(i), 'g.');
        end
        %}
        
        subframe1 = uint8(zeros(512,96));
        subframe1(:,1:12:end) = frame(:,1:12:end);
        subplot(1,6,6)
        imshow(subframe1)
        
%         subplot(1,6,4)
%         acf = autocorr(bin_intensity,511);
%         plot(acf, 0:511)
        %{
        subplot(1,6,4)
        plot(diff(smooth(bin_intensity)),'b','LineWidth',1);
        hold on
        plot(diff(smooth(bin_intensity),2),'r','LineWidth',1);
        hold off
        %}
        
        % now we should be able to detect rising edges
        %{
        subplot(1,6,5);
        imshow(frame);
        hold on;
        
        frame = im2double(frame);
        
        start_ind = 1;
        for i=1:96
            d = diff(smooth(frame(:,i)));
            [val, ind] = max(abs(d(1:500)));
            if(val > 10/255)
                plot(i, ind, 'g.');
            end
            
        end
        hold off
        %}
        
        % background
%         subplot(1,6,2);
%         background = imopen(imadjust(frame),strel('disk',15));
%         surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
%         set(gca,'ydir','reverse');
%         
%         frame_2 = imadjust(imtophat(frame,strel('disk',15)));
%         subplot(1,6,3)
%         frame_bl = frame - background;
%         imshow(imadjust(frame_bl));
%         
%         % contrast-enhanced
%         subplot(1,6,4);
%         imshow(frame_2);
%         title('Contrast-enhanced');
%         
%         % binary
%         subplot(1,6,5);
%         level = graythresh(frame_2);
%         bw = im2bw(frame_2,level);
%         bw = bwareaopen(bw, 50);
%         imshow(bw)
% 
%         % histogram
%         subplot(1,6,6);
%         [count, x] = imhist(frame);
%         plot(x(128:end), count(128:end));
%         ylim([0,100]);
%         xlim([128,255]);
%         disp(max(max(frame)));
        drawnow;
        
        % intensity vs range
        
        % intensity vs beam
%         break;
    end
end

% frames are 96 beams per 512 bins!

% disp(sprintf('channel of received message: %s', char(msg.channel)))
% disp(sprintf('raw bytes of received message:'))
% disp(sprintf('%d ', msg.data'))
% 
% 
% disp(sprintf('decoded message:\n'))
