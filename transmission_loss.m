%TRANSMISSION_LOSS.M Simple transmission loss model to enhance sonar data.
%
% Note: the sonar image is assumed to contain the output of a matched
% filter. This script modifies the image to take into account transmission
% losses, reducing the intensity of spurious returns.
%
% Pedro Vaz Teixeira, June 2014
% pvt@mit.edu

close all

%% transmission loss model (absorption+geometric)
figure();

% absorption coefficient [dB(re 1m)/ m]
% alpha = 0.9666; % didson/auto
alpha = 0.945;  % 1.8MHz, 10m depth, 15C, ph 8, 35ppt salinity
                % http://resource.npl.co.uk/acoustics/techguides/seaabsorption/

r = 2.5:0.1:9;      %    
h_a = 2*alpha.*r;   % absorption losses
h_g = 20*log(r);    % transmission losses

plot(r, h_a, 'r')
hold on
plot(r, h_g, 'b')
plot(r, h_a + h_g, 'k')
legend('absorption', 'geometric', 'total', 'Location', 'Southeast')
ylabel('Transmission loss [dB re 1m]')
xlabel('Range [m]')
title(['Transmission losses (\alpha=',num2str(alpha),')']);

grid on

%% application to didson data
polar_frame = flipud(im2double(imread('./data/frame.bmp')));
figure();
subplot(1,4,1);
imshow(polar_frame);

[cart_frame, ~, ~] = polarToCart(polar_frame, 2.5, 9, 500);
subplot(1,4,2)
imshow(fliplr(cart_frame'))

for i=1:512
    r = 2.5 + (6.5/512)*i;  % not sure these are the values for the test frame
    % unsure about formula - not sure about the intensity scale/value
    polar_frame(i,:) = (255*polar_frame(i,:) - (2*alpha*r)*ones(1,96) - 20*log(r^2))./255;
end
subplot(1,4,3)
imshow(polar_frame)

[cart_frame, ~, ~] = polarToCart(polar_frame, 2.5, 9, 500);
subplot(1,4,4)
imshow(fliplr(cart_frame'))