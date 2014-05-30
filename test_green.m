close all



%imshow(G);  

close all

frame = imread('data/frame.bmp');

frame_d = deconvreg(frame, G);

subplot(1,2,1);
imshow(frame);
title('Original')

subplot(1,2,2);
imshow(frame_d);
title('Deconvolved');