# Occupant-Driven-Climate-Controller
MATLAB tutorial simulating indoor temperature regulation using fixed vs. occupant-driven setpoints. Compares energy consumption, comfort, and cost. Includes dynamic thermal modeling, PI control, and visualization. Ideal for learning climate control systems!
This MATLAB simulation models a 24-hour climate control system with:

- External Temperature: Sinusoidal variation (10°C avg, 5°C amplitude).

- Occupant Activity Levels: Predefined profile (sedentary, light, moderate, vigorous).

- Thermal Model: dynamicThermalModel simulates indoor temperature changes.

Control Strategies:

- Fixed Setpoint: Constant 20°C.

- Varying Setpoint: Adjusts (18°C–22°C) based on activity and thermal sensation using updateSetpointBasedOnThermalSensation.

- PI Controller: simulatePIController regulates heater power.

- Energy & Cost Analysis: Compares energy use and cost for both strategies.

Key Features
- Dynamic Simulation: 24-hour indoor temp, heater power, and energy use.

- Activity-Based Setpoint: Optimizes comfort and efficiency.

- Visualization: Plots indoor/outdoor temp, heater power, and energy use.

How to Use
- Clone/download the script.

- Run in MATLAB.

- Analyze results via plots and energy/cost outputs.

Results
Lower Energy Use: Varying setpoint reduces consumption.

Improved Comfort: Adjusts for occupant activity.

Cost Savings: Optimizes heater usage.

Dependencies
- MATLAB (R2021a+).

- No additional toolboxes required.
