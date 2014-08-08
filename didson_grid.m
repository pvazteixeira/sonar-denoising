%%
close all;
figure(1);
hold on;

axis equal

n_bins = 512;
window_start = 2.25;
window_length = 9;
beam_width = 0.3;
bin_length = window_length / n_bins;

% DIDSON - constant range arcs
i = -48:1:47;

for j = 0:1:n_bins
    r = window_start + j * bin_length;
    plot([r*cos(deg2rad(beam_width.*i))', r*cos(deg2rad(beam_width.*(i+1)))'], [r*sin(deg2rad(beam_width.*i))', r*sin(deg2rad(beam_width.*(i+1)))'], '-b');
end

for i =-48:1:48
    plot([(window_start)*cos(deg2rad(beam_width.*i))', (window_start+window_length)*cos(deg2rad(beam_width.*i))'],[(window_start)*sin(deg2rad(beam_width.*i))', (window_start+window_length)*sin(deg2rad(beam_width.*i))'], '-b');
end

% 
for j = 0:1:511
    r = window_start + (j+0.5) * bin_length;
    for i = -48:1:47
        plot(r*cos(deg2rad(0.15+0.3*i)), r*sin(deg2rad(0.15+0.3*i)),'b.');
    end
end
% 
% % % Occ. grid
res = 0.02;
for x=(2.25*cos(deg2rad(14))):res:(9+2.25)
    plot([x, x], [-3,3], '-r');
end

for y = -3:res:3
    plot([2.25*cos(deg2rad(14)), 9+2.25], [y,y], '-r');
end

%%
title(['Overlap between DIDSON frame and ', num2str(res), ' occupancy grid'])
xlabel('x [m]')
ylabel('y [m]')

