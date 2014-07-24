%%
close all

lambda = 800e-6;
L = 0.2;

a = sin(deg2rad(14.4));
s = -a:0.00001:a;
B = sinc(L*s./lambda);
M = 10*log10(B.^2);

figure, plot (s, B)
figure, plot(s, M);
