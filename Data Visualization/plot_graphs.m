clc;
clear;
close all;


% Suppress figure size warnings
warning("off", "all");
%% Sweeping Source Voltage
filename = "JS129A_sweep_source.hdf5";
sweepSource = hdf5plot(filename, 1, 10^-3, ...
    "\bf JS129A Voltage Bias Measurement ($\bf V_{G}=0.2$V)", ...
    "Source-Drain Voltage ($V_{SD}$) (V)", ...
    "Source Current ($I_{S}$) (mA)", "source_sweep");


%% Contact Resistance
filename = "JS129A_contactR.hdf5";
contactResistance = hdf5plot(filename, 1, 1, ...
    "\bf Instrumentation Resistance IV Curve", ...
    "Voltage (V)", "Current (A)", "contact_resistance_iv");


h = figure;
Rc = (diff(contactResistance(1, :))./diff(contactResistance(2, :)));
plot(contactResistance(1, 2:end), Rc);
title("\bf Instrumentation Resistance with Respect to Voltage", ...
    "Interpreter", "LaTeX");
xlim([min(contactResistance(1, 2:end)) max(contactResistance(1, 2:end))]);
xlabel("Voltage (V)", "Interpreter", "LaTeX");
ylabel("Differential Resistance ($\Omega$)", "Interpreter", "LaTeX");

set(h, "Units", "Inches");
pos = get(h, "Position");
set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
    "PaperSize", [pos(3), pos(4)]);
print(h, "contact_resistance", "-dpdf", "-r300");


hold on;
plot(contactResistance(1, 2:end), Rc, "r.");
title("\bf Zoomed Instrumentation Resistance with Respect to Voltage", ...
    "Interpreter", "LaTeX");
ylim([-20 20]);

set(h, "Units", "Inches");
pos = get(h, "Position");
set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
    "PaperSize", [pos(3), pos(4)]);
print(h, "zoomed_contact_resistance", "-dpdf", "-r300");


%% Sweeping Gate and Source Voltage
filename = "JS129A_sweep_gate_source.hdf5";
lambda = @(X, Y, Z) X ./ Z; 
[sweepGateSource, X, Y, Z] = hdf5surf(filename, 1, 1, 1, 1, ...
    "\bf JS129A Total Resistance", ...
    "Source-Drain Voltage ($V_{SD}$) (V)", ...
    "Gate Voltage ($V_{G}$) (V)", ...
    "Differential Resistance ($R$) ($\Omega$)", ...
    "double_sweep", lambda, "all");

lambda = @(X, Y, Z) X ./ Z - median(Rc); 
[sweepGateSourceDevice, X, Y, Z] = hdf5surf(filename, 1, 1, 1, 1, ...
    "\bf JS129A Upper Bound Device Resistance", ...
    "Source-Drain Voltage ($V_{SD}$) (V)", ...
    "Gate Voltage ($V_{G}$) (V)", ...
    "Differential Resistance ($R$) ($\Omega$)", ...
    "device_resistance", lambda, "all");


h = figure;
surf(X([1:6,8:end], :), Y([1:6,8:end], :), Z([1:6,8:end], :));
title("\bf JS129A Upper Bound Device Resistance (Without $\bf V_{G}=0.1$V)\\", ...
    "Interpreter", "LaTeX");
xlim([min(X, [], "all") max(X, [], "all")]);
xlabel("Source-Drain Voltage ($V_{SD}$) (V)", "Interpreter", "LaTeX");
ylabel("Gate Voltage ($V_{G}$) (V)", "Interpreter", "LaTeX");

shading interp;
colormap hot;
c = colorbar;
c.Label.String = "Differential Resistance ($R$) ($\Omega$)";
c.Label.Interpreter = "LaTeX";
c.Label.FontSize = 11;
view(2);

set(h, "Units", "Inches");
pos = get(h, "Position");
set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
    "PaperSize", [pos(3), pos(4)]);
print(h, "remove_dirty_resistance", "-dpdf", "-r300");


Vg = unique(Y, "sorted");
Rn = mean(Z, 2);

h = figure;
plot(Vg, Rn, "DisplayName", "All $V_{G}$ Values");
hold on;
plot(Vg([1:6, 8:end]), Rn([1:6, 8:end]), ...
    "DisplayName", "Without $V_{G}=0.1$V");
title("\bf JS129A Resistance with Respect to Gate Voltage", ...
    "Interpreter", "LaTeX");
l = legend("Location", "northwest");
set(l, "Interpreter", "LaTeX");
xlim([min(Y, [], "all") max(Y, [], "all")]);
xlabel("Gate Voltage ($V_{G}$) (V)", "Interpreter", "LaTeX");
ylabel("Mean Resistance ($R$) ($\Omega$)", "Interpreter", "LaTeX");

set(h, "Units", "Inches");
pos = get(h, "Position");
set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
    "PaperSize", [pos(3), pos(4)]);
print(h, "vg_vs_rn", "-dpdf", "-r300");


h = figure;
vsd = sweepGateSource(:, 1, :);
is = sweepGateSource(:, 3, :);
for vg = unique(sweepGateSource(:, 2, :)).'
    plot(vsd(sweepGateSource(:, 2, :) == vg), ...
        is(sweepGateSource(:, 2, :) == vg)*10^3, ...
        "DisplayName", sprintf("$V_{G}=%dmV$", round(vg*10^3)));
    hold on;
end
title("\bf JS129A Total Resistance IV Curves", "Interpreter", "LaTeX");
l = legend("Location", "northwest");
set(l, "Interpreter", "LaTeX");
xlim([min(sweepGateSource(:, 1, :), [], "all") ...
    max(sweepGateSource(:, 1, :), [], "all")]);
xlabel("Source-Drain Voltage ($V_{SD}$) (V)", "Interpreter", "LaTeX");
ylabel("Source Current ($I_{S}$) (mA)", "Interpreter", "LaTeX");

set(h, "Units", "Inches");
pos = get(h, "Position");
set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
    "PaperSize", [pos(3), pos(4)]);
print(h, "device_iv_curves", "-dpdf", "-r300");


%% Sweeping Gate and Source Voltage Crygenic Temperatures
filename = "JS127A_cryogenic.hdf5";
% lambda function incorrect, needs verification
lambda = @(X, Y, Z) Z;
[cryogenicData, X, Y, Z] = hdf5surf(filename, 1, 1e9, 1, 1, ...
    "\bf JS127A Cryogenic Resistance", ...
    "Source Current ($I_{S}$) ($\mu$A)", ...
    "Gate Voltage ($V_{G}$) (V)", ...
    "Differential Resistance ($R_{N}$) ($\Omega$)", ...
    "cryogenic_resistance_1", lambda, [1 2 3]);