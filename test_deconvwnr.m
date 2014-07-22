
clear;
close all;

%% 1. Matlab's deconvwnr example

I = im2double(imread('cameraman.tif'));
imshow(I);
title('Original Image (courtesy of MIT)');
  
       % Simulate a motion blur.
       LEN = 21;
       THETA = 11;
       PSF = fspecial('motion', LEN, THETA);
       figure, imshow(10*PSF)
       blurred = imfilter(I, PSF, 'conv', 'circular');
  
       % Simulate additive noise.
       noise_mean = 0;
       noise_var = 0.0001;
       blurred_noisy = imnoise(blurred, 'gaussian', noise_mean, noise_var);
       figure, imshow(blurred_noisy)
       title('Simulate Blur and Noise')
  
       % Try restoration assuming no noise.
       estimated_nsr = 0;
       wnr2 = deconvwnr(blurred_noisy, PSF, estimated_nsr);
       figure, imshow(wnr2)
       title('Restoration of Blurred, Noisy Image Using NSR = 0')
  
       % Try restoration using a better estimate of the noise-to-signal-power 
       % ratio.
       estimated_nsr = noise_var / var(I(:));
       wnr3 = deconvwnr(blurred_noisy, PSF, estimated_nsr);
       figure, imshow(wnr3)
       title('Restoration of Blurred, Noisy Image Using Estimated NSR');
       
       
%% 2. Try deconvwnr with DIDSON

close all
figure();
N_plots = 4;

% 2.0 - open image
frame = im2double(imread('data/frame.bmp'));
subplot(1,N_plots,1); imshow(frame);
title('Original image');

% 2.1 - create PSF
PSF =  zeros(13,96);
PSF(7,:) = 18*ones(1,96);
PSF(7,[1 9 17 25 33 41 49 57 65 73 81 89]) =[ 30 24 24 27 32 40 70 40 32 27 24 24];
PSF = (1/sum(sum(PSF)))*PSF;
disp(sum(sum(PSF)));
subplot(1,N_plots,2); imshow(50*PSF)
title('PSF');

% 2.2 - restore assuming no noise
estimated_nsr = 0;
wnr2 = deconvwnr(frame, PSF, estimated_nsr);
subplot(1,N_plots,3); imshow(wnr2)
title('Restoration using NSR = 0')
       
% 2.3 - restore with noise      
estimated_nsr = var(frame(:)); % INCORRECT; this is total variance
wnr3 = deconvwnr(frame, PSF, estimated_nsr);
subplot(1,N_plots,4);  imshow(wnr3)
title(['Restoration using NSR=',num2str(estimated_nsr)]);