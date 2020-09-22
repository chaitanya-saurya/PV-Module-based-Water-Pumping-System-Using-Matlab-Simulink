function Ia = bp_sx150s(Va,G,TaC)
% function bp_sx150s.m models the BP SX 150S PV module
% calculates module current under given voltage, irradiance and temperature
% Ia = bp_sx150s(Va,G,T)
%
% Out: Ia = Module operating current (A), vector or scalar
% In: Va = Module operating voltage (V), vector or scalar
% G = Irradiance (1G = 1000 W/m^2), scalar
% TaC = Module temperature in deg C, scalar
%
% Written by Akihiro Oi 7/01/2005
% Revised 7/18/2005
%/////////////////////////////////////////////////////////////////////////////
% Define constants
k = 1.381e-23; % Boltzmann’s constant
q = 1.602e-19; % Electron charge
% Following constants are taken from the datasheet of PV module and
% curve fitting of I-V character (Use data for 1000W/m^2)
n = 1.62; % Diode ideality factor (n),
% 1 (ideal diode) < n < 2
Eg = 1.12; % Band gap energy; 1.12eV (Si), 1.42 (GaAs),
% 1.5 (CdTe), 1.75 (amorphous Si)
Ns = 72; % # of series connected cells (BP SX150s, 72 cells)
TrK = 298; % Reference temperature (25C) in Kelvin
Voc_TrK = 43.5 /Ns; % Voc (open circuit voltage per cell) @ temp TrK
Isc_TrK = 4.75; % Isc (short circuit current per cell) @ temp TrK
a = 0.65e-3; % Temperature coefficient of Isc (0.065%/C)
% Define variables
TaK = 273 + TaC; % Module temperature in Kelvin
Vc = Va / Ns; % Cell voltage
% Calculate short-circuit current for TaK
Isc = Isc_TrK * (1 + (a * (TaK - TrK)));
Iph = G * Isc;
% Define thermal potential (Vt) at temp TrK
Vt_TrK = n * k * TrK / q;
b = Eg * q /(n * k);
% Calculate reverse saturation current for given temperature
Ir_TrK = Isc_TrK / (exp(Voc_TrK / Vt_TrK) -1);
Ir = Ir_TrK * (TaK / TrK)^(3/n) * exp(-b * (1 / TaK -1 / TrK));
% Calculate series resistance per cell (Rs = 5.1mOhm)
dVdI_Voc = -1.0/Ns; % Take dV/dI @ Voc from I-V curve of datasheet
Xv = Ir_TrK / Vt_TrK * exp(Voc_TrK / Vt_TrK);
Rs = - dVdI_Voc - 1/Xv;
% Define thermal potential (Vt) at temp Ta
Vt_Ta = n * k * TaK / q;
% Ia = Iph - Ir * (exp((Vc + Ia * Rs) / Vt_Ta) -1)
% f(Ia) = Iph - Ia - Ir * ( exp((Vc + Ia * Rs) / Vt_Ta) -1) = 0
% Solve for Ia by Newton's method: Ia2 = Ia1 - f(Ia1)/f'(Ia1)
Ia=zeros(size(Vc)); % Initialize Ia with zeros
% Perform 5 iterations
for j=1:5;
Ia = Ia - (Iph - Ia - Ir .* ( exp((Vc + Ia .* Rs) ./ Vt_Ta) -1))...
./ (-1 - Ir * (Rs ./ Vt_Ta) .* exp((Vc + Ia .* Rs) ./ Vt_Ta));
end