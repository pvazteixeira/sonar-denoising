clear
close all
clc

polar_frame = im2double(imread('data/frame.bmp'));
tic
[cart_frame, rx, ry] = polarToCart(polar_frame, 4*0.375, 4*1.125, 500);
toc
figure();
subplot(1,2,1)
imshow(polar_frame)
subplot(1,2,2)
imshow(cart_frame)

% width - run time (w/profiler)
% 500px - 11.058s
% 400px - 7.150s
% 300px - 4.202s
% 200px - 1.977s

% width - run time (tic/toc)
% 500px - 40ms
% 400px
% 300px
% 200px - 10ms