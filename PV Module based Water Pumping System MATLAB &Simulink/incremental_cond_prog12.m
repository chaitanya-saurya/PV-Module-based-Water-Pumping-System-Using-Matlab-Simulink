clc
close all
clear all
% Define constants
TaC = 25; % Cell temperature (deg C)
C = 0.5; % Step size for ref voltage change (V)
E = 0.002; % Maximum dI/dV error
% Define variables with initial conditions
G = 0.045; % Irradiance (1G = 1000W/m^2)
Va = 27.2; % PV voltage
Ia = bp_sx150s(Va,G,TaC); % PV current
Pa = Va * Ia;
Vref_new = Va + C; % New reference voltage
% Set up arrays storing data for plots
irrad7d = [1 0.2;2 0.4;3 0.6;4 0.8; 5 1; 6 0.8;7 0.6;8 0.4;9 0.2];
Va_array = [];
Pa_array = [];
Pmax_array =[];
% Load irradiance data
% load irrad7d; % Irradiance data of a cloudy day
x = irrad7d(:,1)'; % Read time data (second)
y = irrad7d(:,2)'; % Read irradiance data
xi = 332.8e+3: 376e+3; % Set points for interpolation
yi = interp1(x,y,xi,'cubic'); % Do cubic interpolation
% Take 43200 samples (12 hours)
for Sample = 1:43.2e+3
% Read irrad value
G = yi(Sample);
% Take new measurements
Va_new = Vref_new;
Ia_new = bp_sx150s(Vref_new,G,TaC);
% Calculate incremental voltage and current
deltaVa = Va_new - Va;
deltaIa = Ia_new - Ia;
% incCond Algorithm starts here
if deltaVa == 0
if deltaIa == 0
Vref_new = Va_new; % No change
elseif deltaIa > 0
Vref_new = Va_new + C; % Increase Vref
else
Vref_new = Va_new - C; % Decrease Vref
end
else
if abs(deltaIa/deltaVa + Ia_new/Va_new) <= E
Vref_new = Va_new; % No change
else
if deltaIa/deltaVa > -Ia_new/Va_new + E
Vref_new = Va_new + C; % Increase Vref
else
Vref_new = Va_new - C; % Decrease Vref
end
end
 end
% Calculate theoretical max
%  [Pa_max, Imp, Vmp] = find_mpp(G, TaC);
% Update history
Va = Va_new;
Ia = Ia_new;
Pa = Va_new * Ia_new;
% Store data in arrays for plot
Va_array = [Va_array Va];
Pa_array = [Pa_array Pa];
% Pmax_array = [Pmax_array Pa_max];
end
% Pth = sum(Pmax_array)/3600;
Pact = sum(Pa_array)/3600;
% Plot result
figure
plot (Va_array, Pa_array, 'g')
% Overlay with P-V curves and MPP
Va = linspace (0, 45, 200);
hold on
for G=.2:.2:1
Ia = bp_sx150s(Va, G, TaC);
Pa = Ia.*Va;
plot(Va, Pa)
[Pa_max, Imp, Vmp] = find_mpp(G, TaC);
plot(Vmp, Pa_max, 'r*')
end
title('Incremental Conductance Method')
xlabel('Module Voltage (V)')
ylabel('Module Output Power (W)')
axis([0 50 0 160])
gtext('1000W/m^2')
gtext('800W/m^2')
gtext('600W/m^2')
gtext('400W/m^2')
gtext('200W/m^2')
hold off
