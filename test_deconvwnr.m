
clear;
close all;

%% Try deconvwnr with DIDSON

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