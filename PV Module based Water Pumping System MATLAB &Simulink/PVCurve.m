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
P = Va .* Ia;
plot(Va,P)


end
title('BP SX 150S Photovoltaic Module P-V Curve')
xlabel('Module Voltage (V)')
ylabel('Module power (W)')
axis([0 60 0 200])
gtext('0C')
gtext('25C')
gtext('50C')
gtext('75C')
hold off
