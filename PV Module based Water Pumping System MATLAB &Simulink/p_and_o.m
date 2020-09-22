clear;
irrad = [1 0.2;2 0.4;3 0.6;4 0.8; 5 1; 6 0.8;7 0.6;8 0.4;9 0.2];

% Define constants
TaC = 25; % Cell temperature (deg C)
C = 0.5; % Step size for ref voltage change (V)
% Define variables with initial conditions
G = 0.028; % Irradiance (1G = 1000W/m^2)
Va = 26.0; % PV voltage
Ia = bp_sx150s(Va,G,TaC); % PV current
Pa = Va * Ia; % PV output power
Vref_new = Va + C; % New reference voltage
% Set up arrays storing data for plots
Va_array = [];
Pa_array = [];
% Load irradiance data
% load irrad; % Irradiance data of a sunny day
x = irrad(:,1)'; % Read time data (second)
y = irrad(:,2)'; % Read irradiance data
xi = 147.4e+3:190.6e+3; % Set points for interpolation
yi = interp1(x,y,xi,'cubic'); % Do cubic interpolation
% Take 43200 samples (12 hours)
for Sample = 1:43.2e+3
% Read irradiance value
G = yi(Sample);
% Take new measurements
Va_new = Vref_new;
Ia_new = bp_sx150s(Vref_new,G,TaC);
Pa_new = Va_new * Ia_new;
deltaPa = Pa_new - Pa;
% P&O Algorithm starts here
if deltaPa > 0
if Va_new > Va
Vref_new = Va_new + C; % Increase Vref
else
Vref_new = Va_new - C; % Decrease Vref
end
elseif deltaPa < 0
if Va_new > Va
Vref_new = Va_new - C; % Decrease Vref
else
Vref_new = Va_new + C; %Increase Vref
end
else
Vref_new = Va_new; % No change
end
% Update history
Va = Va_new;
Pa = Pa_new;
Va_array = [Va_array Va];
Pa_array = [Pa_array Pa];
end
% Plot result
figure
plot (Va_array, Pa_array, 'g')
% Overlay with P-I curves and MPP
Va = linspace (0, 45, 200);
hold on
for G=.2:.2:1
Ia = bp_sx150s(Va, G, TaC);
Pa = Ia.*Va;
plot(Va, Pa)
[Pa_max, Imp, Vmp] = find_mpp(G, TaC);
plot(Vmp, Pa_max, 'r*')
end
title('Perturb & Observe Algorithm')
xlabel('Module Voltage (V)')
ylabel('Module Output Power (W)')
axis([0 50 0 160])
gtext('1000W/m^2')
gtext('800W/m^2')
gtext('600W/m^2')
gtext('400W/m^2')
gtext('200W/m^2')
hold off