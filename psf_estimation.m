close all

step = 2;
kernel_size_h = 96;
kernel_size_v = 96;

for i=step:step:10*step
    figure(1)
    [J,PSF] = deconvblind(frame, ones(kernel_size_v, kernel_size_h), i, uint8(10));
    subplot(1,10,i/step)
    imshow(255*PSF)
    title(['PSF (',num2str(i),')'])
    
    figure(2)
    subplot(1,10,i/step)
    imshow(J)
    title(['frame (',num2str(i),')'])
    
end
    