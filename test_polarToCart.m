clear
close all
clc

polar_frame = im2double(imread('data/frame.bmp'));
cart_frame = polarToCart(polar_frame, 4*0.375, 4*1.125, 300);
figure();
subplot(1,2,1)
imshow(polar_frame)
subplot(1,2,2)
imshow(cart_frame)