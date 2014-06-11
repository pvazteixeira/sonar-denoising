% SIMPLE_VIEWER.M A simple player for HAUV/DIDSON datasets.
% 
% Pedro Vaz Teixeira (PVT), May 2014
% pvt@mit.edu

clc;
close all;

%data = open('log-2014-03-05.01.mat');
data = open('log-2014-03-05.01-short.mat');
data = data.data;

% DATA FIELDS
% time: 
% data.time - the current date and time [year month day hours minutes seconds]
% data.u_time - vehicle time (in UNIX time)
% 
% poses: [ x y z yaw pitch roll ]
% data.sonar_pose - the sonar's pose (in the platform frame)
% data.vehicle_pose - % the vehicle's pose (in the global frame)
% 
% sonar data:
% data.frame - the sonar data
% data.gain - the sonar gain used for a particular frame

message_count = size(data.vehicle_pose,2);

pose = cell2mat(data.vehicle_pose); % collapse onto an array.

PSF = zeros(96, 96, message_count);

figure();
for i=1:message_count;
    tic
    % position
    %{
    subplot(1,7,1:2);
    plot3(pose(1,1:i), pose(2,1:i), -pose(3,1:i),'-b.');
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Vehicle position');
    %}
    
    frame_polar = flipud(double(data.frame{i})./255);
    
    % sonar - polar, raw
    subplot(1,7,3);
    imshow((1/max(max(frame_polar)))*frame_polar);
    xlabel('Azimuth');
    ylabel('Range');   
    title('Sonar (polar, raw)*');
    
    % sonar - polar, enhanced
    frame_polar_enhanced = enhance(frame_polar, data.window_start{i}, data.window_start{i} + data.window_length{i});
    subplot(1,7,5);
    imshow((1/max(max(frame_polar_enhanced)))*frame_polar_enhanced);

    % sonar - average bin intensity
    %
    fpbi = zeros(512,1);
    fpbid = zeros(512,1);
    fpebi = zeros(512,1);
    fpebid = zeros(512,1);
    for i = 1:512
        fpbi(i) = mean(frame_polar(i,:));
        fpbid(i) = sqrt(var(frame_polar(i,:)));
        fpebi(i) = mean(frame_polar_enhanced(i,:));
        fpebid(i) = sqrt(var(frame_polar_enhanced(i,:)));
    end
    s = mean(fpebi);
    dev = sqrt(var(fpebi));
        
    subplot(1,7,4);
    %plot(fpbi, 512:-1:1, 'b');
    hold on
    %plot(fpebi+fpebid, 512:-1:1, 'r--');
    plot(fpebi, 512:-1:1, 'r');
    %plot(fpebi-fpebid, 512:-1:1, 'r--');
    plot(fpebid, 512:-1:1, 'b');
    %plot([s s], [1 512], 'k');
    %plot([s+dev s+dev], [1 512], 'k--');
    %plot(max([s-dev s-dev], [0,0]), [1 512], 'k--');
    hold off
    
    %xlim([0 1])
    ylim([1 512])
    %}
    
    % sonar - blind deconvolution
    %{
    [frame_polar_enhanced_deconv, PSF] = deconvblind(frame_polar_enhanced, ones(96), 20);
    subplot(1,7,6)
    imshow(frame_polar_enhanced_deconv);
    
    subplot(1,7,7)
    imshow(100*PSF);
    %}
    
    % sonar - cartesian
    %{
    [frame_cart, rx, ry] = polarToCart(flipud(frame_polar), data.window_start{i}, data.window_length{i}, 300);
    frame_cart = fliplr(rot90(frame_cart));
    subplot(1,6,5);
    imshow(frame_cart);
    xlabel('x');
    ylabel('y');   
    title('Sonar (Cartesian)');
    %}
    
    % sonar (deblurred, known PSF)
    %{
    G = green_cart(35, 1/rx, 1/ry);
    frame_cart_d = deconvreg(frame_cart, G);
    subplot(1,5,5);
    imshow(frame_cart_d);
    %title('Sonar (deblurred)');
    %}
    
    % sonar (deblurred, unknown PSF);
    %{
    %G = ones(96,96);
    %G = 0.5* green_cart(35, 1/rx, 1/ry) + 0.5*ones(36);
    [frame_cart_d, G] = deconvblind(frame_cart,G,5);
    PSF(:,:,i) = G;
    subplot(1,6,5);
    imshow(frame_cart_d);
    subplot(1,6,6);
    m = max(max(G));
    imshow(G./m);
    title(['Normalized PSF (max = ',num2str(m),')']);
    
    %}
    
    suptitle( '(images marked with * are normalized)');
    
    drawnow;
    toc
end

% compute mean PSF
MPSF = mean(PSF,3);
figure()
imshow(MPSF);
