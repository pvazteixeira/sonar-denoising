function [ enhanced_polar_frame ] = enhance( polar_frame, range_start, range_stop )
%ENHANCE YEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH
%   CSI-style enhancements for sonar imagery
%
%   Assumes image is 512x96, where the first row is the nearest range bin
%   (range_start) and the last (512th) is the farthest.
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu

delta_r = (range_stop- range_start) / 512;
enhanced_polar_frame=zeros(size(polar_frame));


%% transmission loss (geometric+absroption)
alpha = 0.945;  % absorption coefficient [dB(re 1m)/m]

r = range_start:delta_r:(range_stop-delta_r);

H = 2*alpha.*r + 20*log(r.^2);

% subtract transmission loss per each range bin.
for i=1:512;
    enhanced_polar_frame(i,:) = max(((90*polar_frame(i,:) - H(i)*ones(1,96))/90), zeros(1,96));
end

%% cross-talk


