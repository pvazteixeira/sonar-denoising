% SIMPLE_VIEWER.M A simple player for HAUV/DIDSON datasets.
% 
% Pedro Vaz Teixeira (PVT), May 2014
% pvt@mit.edu

clc;
close all;

data = open('log-2014-03-05.01.mat');
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
    subplot(1,3,1:2);
    plot3(pose(1,1:i), pose(2,1:i), -pose(3,1:i),'-b.');
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Vehicle position');
    
    % sonar
    subplot(1,3,3);
    imshow(data.frame{i});
    xlabel('Azimuth');
    ylabel('Range');   
    title('Sonar');
    drawnow;
    toc
end