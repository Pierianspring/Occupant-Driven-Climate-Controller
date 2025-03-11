function [Tin, heaterPower] = simulatePIController(Tout, setpoint, simulationTime, timeStep, Kp, Ki)
    % Constants
    

    % Initialize variables
    time = 0:timeStep:simulationTime; % Time vector
    Tin = zeros(size(time)); % Indoor temperature array
    heaterPower = zeros(size(time)); % Heater power array
    integralError = 0; % Integral of the error

    % Initial conditions
    Tin(1) = 20; % Initial indoor temperature (deg C)

    % Simulation loop
    for i = 2:length(time)
        % Calculate the error
        error = setpoint(i-1) - Tin(i-1);

        % Update the integral of the error
        integralError = integralError + error * timeStep;

        % Calculate the heater power using the PI controller
        heaterPower(i) = Kp * error + Ki * integralError;

        % Ensure the heater power is non-negative
        heaterPower(i) = max(0, heaterPower(i));

        % Update the indoor temperature using the thermal model
        Tin(i) = dynamicThermalModel(Tout(i), heaterPower(i), Tin(i-1), timeStep);
    end
end