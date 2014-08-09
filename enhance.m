function [ enhanced_polar_frame ] = enhance( polar_frame, range_start, range_stop )
%ENHANCE YEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH
%   CSI-style enhancements for sonar imagery
%
%   Assumes 
%   - image is 512x96, where the first row is the nearest range bin
%   (range_start) and the last (512th) is the farthest;
%   - image range is [0 1], which corresponds to [0 90] dB
%   
%
%   Pedro Vaz Teixeira, June 2014
%   pvt@mit.edu


%enhanced_polar_frame = zeros(size(polar_frame));

%% transmission loss (geometric+absroption)
%{
delta_r = (range_stop- range_start) / 512;

alpha = 0.945;  % absorption coefficient [dB(re 1m)/m]

r = range_start:delta_r:(range_stop-delta_r);

H = 2*alpha.*r + 20*log(r.^2);

% subtract transmission loss per each range bin.
for i=1:512;
    enhanced_polar_frame(i,:) = max(((90*polar_frame(i,:) - H(i)*ones(1,96))/90), zeros(1,96));
end
%}

%% beam pattern 'taper'

% experimental coefficients (from SOUNDMETRICS)

k1 =  -0.0089;
k2 = 0.8515;
k3 = -20.0994;

i = 0:95; % beam index
k0 = 0.6; % my own, additional, correction factor
a = (k0)*(k1 * i.^2 + k2 * i + k3*ones(1,96));

s = 1/70; % this is the MuPerDB (image intensity over dB, eg. 255/(70dB) )
a = -s*a;% + 0.5*ones(1,96);

offset = repmat(a, [512, 1]);

enhanced_polar_frame = polar_frame+offset;

%% cross-talk


