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



figure();
for i=1:message_count;
    tic
    % position
    subplot(1,5,1:2);
    plot3(pose(1,1:i), pose(2,1:i), -pose(3,1:i),'-b.');
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Vehicle position');
    
    frame_polar = double(data.frame{i})./255;
    
    % sonar - polar
    subplot(1,5,3);
    imshow(frame_polar);
    xlabel('Azimuth');
    ylabel('Range');   
    title('Sonar (polar)');
    
    % sonar - cartesian
    [frame_cart, rx, ry] = polarToCart(flipud(frame_polar), data.window_start{i}, data.window_length{i}, 300);
    frame_cart = fliplr(rot90(frame_cart));
    subplot(1,5,4);
    imshow(frame_cart);
    xlabel('x');
    ylabel('y');   
    title('Sonar (Cartesian)');
    
    % sonar (deblurred)
    G = green_cart(35, 1/rx, 1/ry);
    frame_cart_d = deconvreg(frame_cart, G);
    subplot(1,5,5);
    imshow(frame_cart_d);
    %title('Sonar (deblurred)');
    
    drawnow;
    toc
end