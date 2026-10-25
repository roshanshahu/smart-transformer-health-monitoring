# Smart Transformer Health Monitoring System

MATLAB/Simulink-based simulation of a three-phase distribution transformer condition-monitoring system.

## Project Overview

This academic project monitors transformer operating conditions using RMS voltage and current measurements. It estimates loading and apparent power, produces a health score, and shows Normal, Warning, or Fault status.

## Key Features

- Three-phase transformer model with source, breaker, load, and V-I measurement.
- RMS voltage and current monitoring.
- Loading and apparent-power estimation.
- Rule-based alarms for overload, overcurrent, overvoltage, undervoltage, open-phase condition, overtemperature, and high vibration.
- Normal operation, short-circuit, and unbalanced-load test scenarios.
- Named fault-status displays for clear results.

## My Contribution

**Primary Simulation Developer**

I built the complete MATLAB/Simulink simulation, connected the electrical and measurement blocks, integrated the health-monitoring logic, created and tested fault cases, and prepared the simulation result screenshots.

## Tools Used

- MATLAB R2025b
- Simulink
- Simscape Electrical
- Specialized Power Systems

## Repository Structure

```text
docs/     Project summary and technical documentation
images/   Model diagrams and setup screenshots
results/  Normal and fault-test results
src/      Simulink model and MATLAB Function code
reports/  Project report and presentation files
```

## Important Limitation

Temperature and vibration are simplified demonstration signals. This is an academic simulation prototype, not a hardware-validated industrial protection system.

## Author

Roshan Shahu  
Electrical Engineering Student | Mumbai, India
