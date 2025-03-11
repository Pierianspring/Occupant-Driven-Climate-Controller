function setpoint = updateSetpointBasedOnThermalSensation(activity_level, indoor_temp, timeStep, currentTime, lastSetpoint,minSetpoint,maxSetpoint)
% Function to update the setpoint based on thermal sensation.
% The setpoint is updated every 10 * timeStep seconds.

% Check if it's time to update the setpoint
if mod(currentTime, 10 * timeStep) == 0
    % Constants for thermal sensation calculation
    resting_heart_rate = 60; % bpm
    heart_rate_increase_per_level = 15; % increase per activity level
    baseline_core_temp = 37; % °C
    core_temp_increase_per_activity = 0.1; % °C increase per activity level
    temp_effect_on_core_temp = 0.05; % °C increase per °C of indoor temp above threshold
    comfort_threshold = 20; % °C

    % Calculate Heart Rate based on activity level
    heart_rate = resting_heart_rate + (activity_level - 1) * heart_rate_increase_per_level;

    % Calculate Core Body Temperature as a function of activity level and indoor temperature
    core_temperature = baseline_core_temp + (activity_level - 1) * core_temp_increase_per_activity;

    % Adjust core body temperature for indoor temperature
    if indoor_temp > comfort_threshold
        core_temperature = core_temperature + (indoor_temp - comfort_threshold) * temp_effect_on_core_temp;
    end

    % Initialize thermal sensation
    thermal_sensation = 0; % Start as neutral

    % Adjust sensation based on core temperature
    if core_temperature < 36.5
        thermal_sensation = thermal_sensation - 2; % Cold
    elseif core_temperature < 36.8
        thermal_sensation = thermal_sensation - 1; % Slightly cool
    elseif core_temperature >= 37.5
        thermal_sensation = thermal_sensation + 1; % Slightly warm
    end

    % Adjust sensation based on heart rate
    if heart_rate > 70 % Threshold for increased sensation
        thermal_sensation = thermal_sensation + 2; % More likely to feel warm
    else
        thermal_sensation = thermal_sensation - 0.5; % Less likely to feel warm
    end

    % Adjust sensation based on activity level (1=sitting, 2=light, 3=moderate, 4=vigorous)
    switch activity_level
        case 1 % Sedentary
            thermal_sensation = thermal_sensation - 2; % More chances of feeling cool
        case 2 % Light Activity
            thermal_sensation = thermal_sensation + 0; % Neutral for light activity
        case 3 % Moderate Activity
            thermal_sensation = thermal_sensation + 1; % Slightly warm
        case 4 % Vigorous Activity
            thermal_sensation = thermal_sensation + 2; % Warm
        otherwise
            error('Invalid activity level. Use 1 to 4');
    end

    % Clamping the thermal sensation within the limits of the 7-point scale
    thermal_sensation = min(max(thermal_sensation, -3), 3)

    % Map thermal sensation to setpoint
    neutralTemp = (minSetpoint + maxSetpoint) / 2;

    % Define the temperature range per unit of thermal sensation
    tempRangePerUnit = (maxSetpoint - minSetpoint) / 6; % 6 units from -3 to +3

    % Calculate the setpoint temperature
    setpoint = neutralTemp - thermal_sensation * tempRangePerUnit;
else
    % Keep the setpoint unchanged
    setpoint = lastSetpoint; % Use the last setpoint if no update is needed
end
end