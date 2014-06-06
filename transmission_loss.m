close all
figure();

alpha = 0.9666; % absorption coefficient

r = 0:0.1:10;

h_a = 2*0.9668.*r; 
h_g = 20*log(r);


plot(r, h_a, 'r')
hold on
plot(r, h_g, 'b')
plot(r, h_a + h_g, 'k')
legend('absorption', 'geometric', 'total', 'Location', 'Southeast')
ylabel('Transmission loss [dB]')
xlabel('Range [m]')
title(['Transmission losses (\alpha=',num2str(alpha),')']);

grid on