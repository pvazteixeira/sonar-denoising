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
%         disp('received frame!');
        

        m = hauv.raw_ping_t(msg.data);
                
        serializedImageData = typecast(m.depth_image, 'uint16');
        serializedImageData = double(serializedImageData)./double(intmax('uint16'));
%         disp(['ping number: ', num2str(m.ping_number)]);

        % deserialize (duh)
        frame = im2double(flip(reshape(serializedImageData, m.width, m.height)'));
        
%         delta_r = (m.range_stop - m.range_start )/ m.height;
%         delta_a = 28/135; % confirm fov
        
        % hackish: assumes beams are sent in order (seems to hold, but
        % ugly)
        beam_number =  1+mod(m.ping_number,3);
        
        subplot(1, 3, beam_number);
        
        imshow(255*frame);
%         set(gca, 'XTick', -14:20*delta_a:14, 'YTick', m.range_start:100*delta_r:m.range_stop);
%         set(gca,'XTickLabel','');
%         set(gca,'YTickLabel','');
        ylabel('Range [m]');
        xlabel('Angle');
        title(['Beam ',num2str(1+mod(m.ping_number,3))]);
        drawnow;

        %{       
        beam_intensity = sum(frame,1)/512;
        bin_intensity = sum(frame,2)/96;
        
        % Intensity/beam
        subplot(1,6,1)
        plot(beam_intensity,'b');
        hold on
        plot(smooth(beam_intensity),'r','LineWidth',2);
        ylim([0 255])
        xlim([0 95])
        title('Average intensity per beam');
        hold off
       
        % Raw frame
        subplot(1,6,2);
        imshow(frame);
        title('Raw frame');
         
        % intensity/bin
        subplot(1,6,3)
        plot(flip(bin_intensity),0:511,'b');
        hold on;
        plot(smooth(flip(bin_intensity)),0:511,'r','LineWidth',2);
        plot(mean(bin_intensity)*[1, 1], [0, 511], '-k')
        xlim([0 255])
        ylim([0 511])
        title('Average intensity per bin');
        hold off
        
        % ROI locator
        
        % derivative computation
        %{
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
        
        % side-detector
        %{
        subplot(1,6,6)
        imshow(frame);
        hold on;
        indices = find(bin_intensity>15);
        for i=1:length(indices)
            [val, ind] = max(frame(indices(i),:));
            plot(ind, indices(i), 'g.');
        end
        %}
            
        % DECONVOLUTION & PSF ESTIMATION
        %
%         PSF = fspecial('gaussian',96);
        PSF = ones(96);
        [J,PSF] = deconvblind(frame, PSF, 10);
        subplot(1,6,4)
        imshow(J);
        
        subplot(1,6,5:6);
        imshow(255*PSF);
        %}
        
        % sub frame (1 of 8)
        %{
        subframe1 = uint8(zeros(512,96));
        subframe1(:,1:12:end) = frame(:,1:12:end);
        subplot(1,6,6)
        imshow(subframe1)
        %}
        
        %{
        subplot(1,6,4)
        acf = autocorr(bin_intensity,511);
        plot(acf, 0:511)
        %}
        
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
    end
end

% frames are 96 beams per 512 bins!

% disp(sprintf('channel of received message: %s', char(msg.channel)))
% disp(sprintf('raw bytes of received message:'))
% disp(sprintf('%d ', msg.data'))
% 
% 
% disp(sprintf('decoded message:\n'))
