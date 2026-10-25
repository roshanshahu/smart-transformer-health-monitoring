# Project Summary

## Smart Transformer Health Monitoring System

A MATLAB/Simulink-based academic simulation of a three-phase distribution transformer condition-monitoring system.

## Objective

To measure electrical operating quantities and identify selected abnormal transformer conditions through rule-based monitoring logic.

## System Operation

The model measures three-phase RMS voltage and current at the transformer secondary. These measurements are used to estimate loading and apparent power. A MATLAB Function-based monitor then evaluates operating thresholds and outputs a Health Index, overall system status, and individual fault indicators.

## Conditions Monitored

- Overload
- Overcurrent
- Overvoltage
- Undervoltage
- Open-phase signature
- Overtemperature
- High vibration

## Test Cases

- Normal balanced operation
- Overload condition
- High-vibration condition
- Short-circuit disturbance
- Unbalanced-load condition

## My Contribution

**Primary Simulation Developer**

- Developed the complete MATLAB/Simulink simulation model.
- Configured the three-phase source, transformer, breaker, load, and V-I measurement system.
- Built RMS voltage and current measurement paths.
- Integrated the rule-based Health Monitor, status logic, and named fault displays.
- Set up and tested normal, fault, and unbalanced-load scenarios.
- Captured simulation screenshots and results.

## Tools Used

- MATLAB R2025b
- Simulink
- Simscape Electrical
- Specialized Power Systems

## Limitation

Temperature and vibration channels are simplified demonstration models rather than physical sensor measurements. The system is an academic simulation prototype and is not a hardware-validated industrial protection device.
