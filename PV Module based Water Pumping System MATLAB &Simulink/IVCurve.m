clc
close all
clear all
% Define constant
G = 1;
% Functions to plot
figure
hold on
for TaC=0:25:75
Va = linspace (0, 48-TaC/8, 200);
Ia = bp_sx150s(Va, G, TaC);

plot(Va, Ia)


end
title('BP SX 150S Photovoltaic Module I-V Curve')
xlabel('Module Voltage (V)')
ylabel('Module Current (A)')
axis([0 50 0 5])
gtext('0C')
gtext('25C')
gtext('50C')
gtext('75C')
hold off
