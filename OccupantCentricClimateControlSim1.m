% Define simulation parameters
simulationTime = 24 * 3600; % 24 hours in seconds
timeStep = 60; % 1 minute time step
time = 0:timeStep:simulationTime;

% Define varying outside temperature (e.g., sinusoidal variation)
Tout_avg = 10; % Average outside temperature (deg C)
Tout_amp = 5; % Amplitude of temperature variation (deg C)
Tout = Tout_avg + Tout_amp * sin(2 * pi * time / (24 * 3600)); % Sinusoidal variation

% Define activity level profile (e.g., changes throughout the day)
activity_level = ones(size(time)); % Initialize with sedentary activity
activity_level(time >= 6 * 3600 & time < 12 * 3600) = 2; % Light activity from 6 AM to 12 PM
activity_level(time >= 12 * 3600 & time < 18 * 3600) = 4; % Moderate activity from 12 PM to 6 PM
activity_level(time >= 18 * 3600 & time < 21 * 3600) = 3; % Vigorous activity from 6 PM to 9 PM
activity_level(time >= 21 * 3600) = 2; % Sedentary activity from 9 PM to 12 AM

% Initialize variables for fixed setpoint simulation
Tin_fixed = zeros(size(time)); % Indoor temperature array
heaterPower_fixed = zeros(size(time)); % Heater power array
setpointProfile_fixed = 20 * ones(size(time)); % Fixed setpoint profile
integralError_fixed = 0; % Integral of the error

% Initialize variables for varying setpoint simulation
Tin_varying = zeros(size(time)); % Indoor temperature array
heaterPower_varying = zeros(size(time)); % Heater power array
setpointProfile_varying = 20 * ones(size(time)); % Varying setpoint profile
integralError_varying = 0; % Integral of the error

% Initial conditions
Tin_fixed(1) = 20; % Initial indoor temperature (deg C)
Tin_varying(1) = 20; % Initial indoor temperature (deg C)

% Define minimum and maximum setpoints for varying setpoint
minSetpoint = 18;
maxSetpoint = 22;

% Simulation loop for fixed setpoint
for i = 2:length(time)
    % Calculate the error
    error_fixed = setpointProfile_fixed(i) - Tin_fixed(i-1);

    % Update the integral of the error
    integralError_fixed = integralError_fixed + error_fixed * timeStep;

    % Calculate the heater power using the PI controller
    Kp = 1000; % Proportional gain
    Ki = 0.4; % Integral gain
    heaterPower_fixed(i) = Kp * error_fixed + Ki * integralError_fixed;

    % Ensure the heater power is non-negative
    heaterPower_fixed(i) = max(0, heaterPower_fixed(i));

    % Update the indoor temperature using the thermal model
    Tin_fixed(i) = dynamicThermalModel(Tout(i), heaterPower_fixed(i), Tin_fixed(i-1), timeStep);
end

% Simulation loop for varying setpoint
for i = 2:length(time)
    % Update the setpoint based on thermal sensation every 10 time steps
    setpointProfile_varying(i) = updateSetpointBasedOnThermalSensation(activity_level(i), Tin_varying(i-1), timeStep, time(i), setpointProfile_varying(i-1), minSetpoint, maxSetpoint);

    % Calculate the error
    error_varying = setpointProfile_varying(i) - Tin_varying(i-1);

    % Update the integral of the error
    integralError_varying = integralError_varying + error_varying * timeStep;

    % Calculate the heater power using the PI controller
    Kp = 1000; % Proportional gain
    Ki = 0.5; % Integral gain
    heaterPower_varying(i) = Kp * error_varying + Ki * integralError_varying;

    % Ensure the heater power is non-negative
    heaterPower_varying(i) = max(0, heaterPower_varying(i));

    % Update the indoor temperature using the thermal model
    Tin_varying(i) = dynamicThermalModel(Tout(i), heaterPower_varying(i), Tin_varying(i-1), timeStep);
end

% Calculate energy consumption
% Energy (Joules) = Power (Watts) * Time (seconds)
energy_fixed = sum(heaterPower_fixed) * timeStep; % Total energy for fixed setpoint
energy_varying = sum(heaterPower_varying) * timeStep; % Total energy for varying setpoint

% Convert energy to kWh (1 kWh = 3.6e6 J)
energy_fixed_kWh = energy_fixed / 3.6e6;
energy_varying_kWh = energy_varying / 3.6e6;

% Define cost of electricity (e.g., $0.09 per kWh)
cost_per_kWh = 0.09;
cost_fixed = energy_fixed_kWh * cost_per_kWh;
cost_varying = energy_varying_kWh * cost_per_kWh;

% Display the results
fprintf('Energy Consumption (Fixed Setpoint): %.2f kWh, Cost: $%.2f\n', energy_fixed_kWh, cost_fixed);
fprintf('Energy Consumption (Varying Setpoint): %.2f kWh, Cost: $%.2f\n', energy_varying_kWh, cost_varying);

% Plot the results
figure;

% Plot indoor temperature
subplot(3, 1, 1);
plot(time / 3600, Tin_fixed, 'b', 'LineWidth', 1.5); % Fixed setpoint
hold on;
plot(time / 3600, Tin_varying, 'r', 'LineWidth', 1.5); % Varying setpoint
plot(time / 3600, setpointProfile_fixed, 'k--', 'LineWidth', 1.5); % Fixed setpoint reference
plot(time / 3600, setpointProfile_varying, 'g--', 'LineWidth', 1.5); % Varying setpoint reference
xlabel('Time (hours)');
ylabel('Temperature (deg C)');
title('Indoor Temperature Comparison');
legend('Fixed Setpoint', 'Varying Setpoint', 'Fixed Setpoint Reference', 'Varying Setpoint Reference');
grid on;

% Plot heater power
subplot(3, 1, 2);
plot(time / 3600, heaterPower_fixed, 'b', 'LineWidth', 1.5); % Fixed setpoint
hold on;
plot(time / 3600, heaterPower_varying, 'r', 'LineWidth', 1.5); % Varying setpoint
xlabel('Time (hours)');
ylabel('Heater Power (Watts)');
title('Heater Power Comparison');
legend('Fixed Setpoint', 'Varying Setpoint');
grid on;

% Plot energy consumption
subplot(3, 1, 3);
bar([energy_fixed_kWh, energy_varying_kWh]);
set(gca, 'XTickLabel', {'Fixed Setpoint', 'Varying Setpoint'});
ylabel('Energy Consumption (kWh)');
title('Energy Consumption Comparison');
grid on;
%%
figure
% Plot indoor temperature
LW = 3;
FZ = 18;
subplot(4, 1, 1);
plot(time / 3600, Tin_fixed, 'b', 'LineWidth', LW); % Fixed setpoint
hold on;

plot(time / 3600, setpointProfile_fixed, 'k--', 'LineWidth', LW); % Fixed setpoint reference
ylim([16 24])
ylabel('Temperature (deg C)');

legend('Indoor temperature', 'Fixed Setpoint');
title('Indoor Temperature: Fixed Setpoit');
grid on;
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)

% Plot energy consumption
subplot(4, 1, 2);
plot(time / 3600, Tin_varying, 'r', 'LineWidth', LW); % Varying setpoint
hold on 
plot(time / 3600, setpointProfile_varying, 'k--', 'LineWidth', LW); % Varying setpoint reference
ylim([16 24])
ylabel('Temperature (deg C)');
legend('Indoor temperature',  'Occupent-driven setpoints');
title('Indoor Temperature: Occupant-driven Setpoint');
grid on;
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)

% Plot heater power
subplot(4, 1, 3);
plot(time / 3600, heaterPower_fixed/10, 'b', 'LineWidth', LW); % Fixed setpoint
hold on;
plot(time / 3600, heaterPower_varying/10, 'r', 'LineWidth', LW); % Varying setpoint
xlabel('Time (hours)');
ylabel('Heater Power (Watts)');
title('Heater Power Comparison');
legend('Fixed Setpoint', 'Varying Setpoint');
grid on;
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)
% Plot outside temp
subplot(4, 1, 4);
plot(time / 3600, Tout, 'm', 'LineWidth', LW); % Fixed setpoint
xlabel('Time (hours)');
ylabel('Temperature (deg C)');
title('Outside Temperature');
grid on;
% Increase font size for all text elements in the current figure
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)
%%

figure
% Plot indoor temperature
LW = 3;
FZ = 18;
subplot(2, 1, 1);
plot(time / 3600, activity_level, 'b', 'LineWidth', LW); % Fixed setpoint

ylabel('Activity level');

title('Varying activity level');
grid on;
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)

% Plot outside temp
subplot(2, 1, 2);
plot(time / 3600, Tout, 'm', 'LineWidth', LW); % Fixed setpoint
xlabel('Time (hours)');
ylabel('Temperature (deg C)');
title('Varying Outside Temperature');
grid on;
% Increase font size for all text elements in the current figure
set(gca, 'FontSize', FZ); % Set font size for axes (labels, ticks, etc.)
set(findobj(gcf, 'Type', 'Text'), 'FontSize', 16); % Set font size for text objects (e.g., titles, legends)