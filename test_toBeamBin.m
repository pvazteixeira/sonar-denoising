window_length = 1.125 * 4;
window_start = 0.375 * 4;

global n_beams beam_width n_bins bin_width min_range max_range;

n_beams = 96;
beam_width = deg2rad(0.3);

n_bins = 512;
bin_width = window_length/n_bins;

min_range = window_start;
max_range = window_start + window_length;

[beam, bin] = toBeamBin(3,0.5)