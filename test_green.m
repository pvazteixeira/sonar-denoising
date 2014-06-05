%TEST_GREEN.M Test case for deconvolution of SONAR imagery using Green's
%function.
%
% Pedro Vaz Teixeira, June 2014
% pvt@mit.edu

clear
close all
clc

%% Open & process image
% open original
polar_frame = im2double(imread('data/frame.bmp'));

% convert to Cartesian
[cart_frame, rx, ry] = polarToCart(polar_frame, 4*0.375, 4*1.125, 300);

% generate kernel
G = green_cart(95, 1/rx, 1/ry);

% deconvolve
cart_frame_d = deconvreg(cart_frame, G);

%% Display results
figure(1)
imshow(G);

figure(2);
subplot(1,2,1);
imshow(cart_frame);
title('Original')

subplot(1,2,2);
imshow(cart_frame_d);
title('Deconvolved');

%% Test PSF
autoframe = deconvreg(G, G);
figure(3)
imshow(autoframe);