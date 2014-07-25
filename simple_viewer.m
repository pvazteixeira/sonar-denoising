% SIMPLE_VIEWER.M A simple player for HAUV/DIDSON datasets.
% 
% Pedro Vaz Teixeira (PVT), May 2014
% pvt@mit.edu

clc;
close all;

% Curtiss, March 2014
%data = open('log-2014-03-05.01-short.mat');

%data = open('didson-air.mat'); % somwhat useful to get noise properties

% NO TARGETS
%data = open('didson-tank-wall.mat');
%data = open('didson-tank-wall-angle.mat');
%data = open('didson-tank-corner.mat');
%didson-tank-supposedly-nothing
%didson-tank-supposedly-nothing-rust-pump-off
%didson-tank-supposedly-nothing-rust-pump-off-2
%didson-tank-wall-nothing-3
%didson-tank-wall-2


% Fishing line
%data = open('didson-tank-wall-fishing-line.mat');
data = open('didson-tank-wall-fishing-line-moving.mat');

% Tubes & rods
%data = open('didson-tank-wall-hollow-tube-tilted.mat');
%data = open('didson-tank-wall-aluminum-rod-moving.mat');
%didson-tank-wall-aluminum-rod
%data = open('didson-tank-wall-thin-hollow-al-rod.mat');
%data = open('didson-tank-wall-thin-hollow-al-rod-2.mat');
%data = open('didson-tank-wall-thin-hollow-al-rod-moving.mat');

% TUNA CAN!
%data = open('didson-tank-wall-tuna-can.mat');
%data = open('didson-tank-wall-tuna-can-moving-can.mat');
%data = open('didson-tank-wall-tuna-can-moving-hauv.mat');


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

plot_rows = 1;
plot_columns = 9;

figure();
for i=1:message_count;
    tic
    num_plot = 1;
    % position
    %{
    subplot(plot_rows,plot_columns,1:2);
    plot3(pose(1,1:i), pose(2,1:i), -pose(3,1:i),'-b.');
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    title('Vehicle position');
    %}
    
    frame_polar = flipud(double(data.frame{i})./255);
    
    %% display raw data
    
    % sonar - polar, raw
    %{
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(frame_polar);
    xlabel('Azimuth');
    ylabel('Range');   
    title('Sonar (polar, raw)');
    %}
    
    % sonar - polar, raw, normalized
    %{
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow((1/max(max(frame_polar)))*frame_polar);
    xlabel('Azimuth');
    ylabel('Range');   
    title('Sonar (polar, raw)*');
    %}
    
    %% enhance.m tests (mostly transmission loss)
    
    % sonar - polar, enhanced
    %{
    frame_polar_enhanced = enhance(frame_polar, data.window_start{i}, data.window_start{i} + data.window_length{i});
    subplot(plot_rows,plot_columns,3);
    imshow(frame_polar_enhanced);
    title('Sonar (polar, enhanced)');
    %}
    
    % sonar - polar, enhanced, normalized
    %{
    subplot(plot_rows,plot_columns,4);
    imshow((1/max(max(frame_polar_enhanced)))*frame_polar_enhanced);
    title('Sonar (polar, enhanced)*');
    %}
    
    
    %% Wiener deconvolution (single lobe)
    %{
    
    PSF =  zeros(1,96);
    PSF(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[ 20 20 20 20 20 20 70 20 20 20 20 20];
    PSF = (1/sum(sum(PSF)))*PSF;
    
    % subplot(1,N_plots,2); imshow(50*PSF)
    % title('PSF');

    % restore assuming no noise
    estimated_nsr = 0;
    wnr2 = deconvwnr(frame_polar, PSF, estimated_nsr);
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(wnr2)
    title('Restoration using NSR = 0')
       
    % restore with noise
    estimated_nsr = 0.0018; % replace with experimentally determined value
    wnr3 = deconvwnr(frame_polar, PSF, estimated_nsr);
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(wnr3)
    title(['Restoration using NSR=',num2str(estimated_nsr)]);

    % normalize
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    wnr3 = (1/max(max(wnr3)))*wnr3;
    imshow(wnr3);
    title(['Restoration using NSR=',num2str(estimated_nsr),'*']);
    
    %}
    
    %% Wiener deconvolution (multiple lobes)
    %{
    beam = [18,18,18,18,18,18,18,18,24,18,18,18,...
          18,18,18,18,24,18,18,18,18,18,18,18,...
          27,18,18,18,18,18,18,18,32,18,18,18,...
          18,18,18,18,40,18,18,18,28,18,39,18,...
          70,18,39,18,28,18,18,18,40,18,18,18,...
          18,18,18,18,32,18,18,18,18,18,18,18,...
          27,18,18,18,18,18,18,18,24,18,18,18,...
          18,18,18,18,24,18,18,18,18,18,18,18];
    %}
    beam=zeros(1,96);
    beam(1,[1 9 17 25 33 41 49 57 65 73 81 89]) =[  24 24 24 27 32 40 70 40 32 27 24 24];
    %beam(2,49) = 60;
    %pause
    PSF = (1/sum(sum(beam)))*beam;
  
    % restore assuming no noise
    %{
    estimated_nsr = 0;
    wnr4 = deconvwnr(frame_polar, PSF, estimated_nsr);
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(wnr4)
    title('Restoration using NSR = 0')
    %}
       
    % restore with noise
    %
    estimated_nsr = 0.0018; % replace with experimentally determined value
    wnr5 = deconvwnr(frame_polar, PSF, estimated_nsr);
    %{
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(wnr5)
    title(['Restoration using NSR=',num2str(estimated_nsr)]);
    %}

    % normalize
    wnr5 = (1/max(wnr5(:)))*wnr5;
    wnr5 = max(frame_polar(:))*wnr5; %correct for same max intensity as the original image
    %
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(wnr5);
    title(['Restoration using NSR=',num2str(estimated_nsr),'*']);
    %}
    
    %{
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(abs(wnr5-wnr3));
    %}
    %% thresholded image
    %{
    %wnr5 = max(frame_polar(:))*wnr5;
    thr = max(0.5, mean(wnr5(:)) + 3*sqrt(var(wnr5(:))));
    hits = im2bw(wnr5, thr); % this may fail as we are working with a normalized image!!
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    imshow(hits);
    %}

    
    %% energy content per range
    % sonar - average bin intensity
    %{
    fpbi = zeros(512,1);
    fpbid = zeros(512,1);
    fpebi = zeros(512,1);
    fpebid = zeros(512,1);
    for j = 1:512
        fpbi(j) = mean(frame_polar(j,:));
        fpbid(j) = sqrt(var(frame_polar(j,:)));
        fpebi(j) = mean(wnr5(j,:));
        fpebid(j) = sqrt(var(wnr5(j,:)));
    end
    s = mean(fpebi);
    dev = sqrt(var(fpebi));
        
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    %plot(fpbi, 512:-1:1, 'b');
    plot(fpbid, 512:-1:1, 'b');
    hold on

    %
    %plot(fpebi+fpebid, 512:-1:1, 'r--');
    %plot(fpebi, 512:-1:1, 'r');
    plot(fpebid, 512:-1:1, 'r');
    plot(wnr5(:,48), 512:-1:1, 'k');
    %plot(fpebi-fpebid, 512:-1:1, 'r--');
    %plot(fpebid, 512:-1:1, 'b');
    %plot([s s], [1 512], 'k');
    %plot([s+dev s+dev], [1 512], 'k--');
    %plot(max([s-dev s-dev], [0,0]), [1 512], 'k--');
    %
    hold off
    
    xlim([0 1])
    ylim([1 512])
    %}
    
    %% energy content per beam
    %{
    abi = zeros(1,96);
    for j=1:96
       abi(j) = mean(frame_polar(:,j)); 
    end
    
    subplot(plot_rows,plot_columns,num_plot);
    num_plot = num_plot+1;
    plot(1:96, abi);
    xlim([1 96])
    ylim([0 1])
    %}
    
    %% blind deconvolution
    % sonar - blind deconvolution
    %{
    [frame_polar_enhanced_deconv, PSF] = deconvblind(frame_polar_enhanced, ones(96), 20);
    subplot(plot_rows,plot_columns,6)
    imshow(frame_polar_enhanced_deconv);
    
    subplot(plot_rows,plot_columns,7)
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
    
    %%
    
    suptitle( '(images marked with * are normalized)');
    
    plot_columns = num_plot -1 ;
    
    drawnow;
    toc
end

% compute mean PSF
MPSF = mean(PSF,3);
figure()
imshow(MPSF);
