function Tin_new = dynamicThermalModel(Tout, heaterPower, Tin_prev, timeStep)
    % Constants
    r2d = 180/pi;
    lenHouse = 30; % House length in meters
    widHouse = 10; % House width in meters
    htHouse = 4; % House height in meters
    pitRoof = 40/r2d; % Roof pitch in radians
    numWindows = 6; % Number of windows
    htWindows = 1; % Height of windows in meters
    widWindows = 1; % Width of windows in meters
    windowArea = numWindows * htWindows * widWindows; % Total window area
    wallArea = 2 * lenHouse * htHouse + 2 * widHouse * htHouse + ...
               2 * (1/cos(pitRoof/2)) * widHouse * lenHouse + ...
               tan(pitRoof) * widHouse - windowArea; % Total wall area

    % Thermal properties
    kWall = 0.01; % Thermal conductivity of walls (J/sec/m/C)
    LWall = 0.2; % Thickness of walls (m)
    RWall = LWall / (kWall * wallArea); % Thermal resistance of walls
    kWindow = 0.3; % Thermal conductivity of windows (J/sec/m/C)
    LWindow = 0.02; % Thickness of windows (m)
    RWindow = LWindow / (kWindow * windowArea); % Thermal resistance of windows
    Req = RWall * RWindow / (RWall + RWindow); % Equivalent thermal resistance

    % Air properties
    c = 1005.4; % Specific heat capacity of air (J/kg-K)
    densAir = 1.2250; % Density of air at sea level (kg/m^3)
    M = (lenHouse * widHouse * htHouse + tan(pitRoof) * widHouse * lenHouse) * densAir; % Total air mass

    % Heat loss through walls and windows
    Qloss = (Tin_prev - Tout) / Req;

    % Heat added by the heater
    Qheater = heaterPower; % Heater power in Watts (J/sec)

    % Net heat change
    Qnet = Qheater - Qloss;

    % Update indoor temperature using energy balance
    Tin_new = Tin_prev + (Qnet * timeStep) / (M * c);
end