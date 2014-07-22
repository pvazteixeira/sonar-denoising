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

% geometric loss coefficient
N = 1; % cyclindrical
%N = 2; % spherical
                
r = 2.5:0.1:9;      %    
h_a = 2*alpha.*r;   % absorption losses
h_g = 20*log(r.^N); % geometric losses

plot(r, h_a, 'r')
hold on
plot(r, h_g, 'b')
plot(r, h_a + h_g, 'k')
legend('absorption', 'geometric', 'total', 'Location', 'Southeast')
ylabel('Transmission loss [dB re 1m]')
xlabel('Range [m]')
title(['Transmission losses (\alpha=',num2str(alpha),'dB(re 1m)/m, N=',num2str(N),')']);

grid on

%% application to didson data
polar_frame = flipud(im2double(imread('./data/frame.bmp')));
figure();

subplot(1,4,1);
imshow(polar_frame);
xlabel('Azimuth');
ylabel('Range');
title('Original/polar');

[cart_frame, ~, ~] = polarToCart(polar_frame, 2.5, 9, 500);
subplot(1,4,2)
imshow(fliplr(cart_frame'))
xlabel('y')
ylabel('x')
title('Original/cart.')

polar_frame2 = polar_frame;

for i=1:512
    r = 2.5 + (6.5/512)*i;  % not sure these are the values for the test frame
    % unsure about formula - not sure about the intensity scale/value
    polar_frame2(i,:) = (255*polar_frame2(i,:) - (2*alpha*r)*ones(1,96) - N*20*log(r))./255;
end
subplot(1,4,3)
imshow(polar_frame2)
xlabel('Azimuth');
ylabel('Range');
title('Enhanced/polar');

[cart_frame, ~, ~] = polarToCart(polar_frame2, 2.5, 9, 500);
subplot(1,4,4)
imshow(fliplr(cart_frame'))
xlabel('y')
ylabel('x')
title('Enhanced/cart');

suptitle('Transmission loss compensation');


%% stand-alone enhancement function test

figure()
eframe = enhance(polar_frame, 2.5,  9);
imshow(eframe)
title('Transmission loss compensation - stand-alone function');


%% blind deconvolution
PSF = ones(96,96);
[edframe, PSF] = deconvblind(eframe, PSF, 20);
figure();

subplot(1,4,1)
imshow(polar_frame)
title('Original');

subplot(1,4,2)
imshow(eframe)
title('Enhanced');

subplot(1,4,3)
imshow(edframe)
title('Deconvolved');

subplot(1,4,4)
imshow(250*PSF)
title('PSF estimate (x250)');

suptitle('Blind deconvolution (polar)');


%% deconvolution on enhanced image
[cart_frame, rx, ry] = polarToCart(eframe, 2.5, 9, 500);
G = green_cart(95, 1/rx, 1/ry);
cart_frame_d = deconvreg(cart_frame, G);
figure()

subplot(1,2,1)
imshow(cart_frame)
title('Enhanced/cart');

subplot(1,2,2)
imshow(cart_frame_d)
title('Enhanced+deconv./cart');

suptitle('Reg. deconvolution (cart.)');


%% range bin energy content comparison (original vs enhanced)
figure()
subplot(1,5,1);
imshow(polar_frame);    % original
eo = zeros(512,1);
for i = 1:512
    eo(i) = mean(polar_frame(i,:));
end
subplot(1,5,2)
plot(eo, 512:-1:1)
xlim([0 1])
ylim([1 512])

subplot(1,5,3);
imshow(eframe);
ee = zeros(512,1);
for i = 1:512
    ee(i) = mean(eframe(i,:));
end
subplot(1,5,4)
plot(ee, 512:-1:1)
hold on;
k = 1/max(max(eframe));
plot(k*ee, 512:-1:1,'r')
xlim([0 1])
ylim([1 512])

subplot(1,5,5);
imshow(k*eframe);
title('amplified')

suptitle('Average bin intensity')
