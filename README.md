# Smart Transformer Health Monitoring System

MATLAB/Simulink-based simulation of a three-phase distribution transformer condition-monitoring system.

## Overview

This project monitors transformer operating conditions using RMS voltage and current measurements. It calculates loading and estimated apparent power, then uses rule-based logic to indicate Normal, Warning, or Fault status.

## Features

- Three-phase source, transformer, breaker, load, and V-I measurement model.
- RMS voltage and current monitoring.
- Loading and apparent-power estimation.
- Health Index and overall system-status output.
- Named fault indicators:
  - Overload
  - Overcurrent
  - Overvoltage
  - Undervoltage
  - Open-phase condition
  - Overtemperature
  - High vibration
- Normal-operation, overload, short-circuit, unbalanced-load, temperature, and vibration test scenarios.

## My Contribution

**Primary Simulation Developer**

I developed the complete MATLAB/Simulink model, connected the electrical and measurement blocks, integrated the health-monitoring logic, configured test cases, and prepared the simulation results and screenshots.

## Tools Used

- MATLAB R2025b
- Simulink
- Simscape Electrical
- Specialized Power Systems

## Repository Structure

```text
docs/     Project summary and documentation
images/   Model diagrams and setup screenshots
results/  Normal-operation and fault-test screenshots
src/      Simulink model and MATLAB Function code
reports/  Final report and presentation files
```

## Key Result

Under normal balanced operation, the model produced approximately:

| Quantity | Result |
|---|---:|
| Phase RMS voltage | 129.6 V |
| Phase RMS current | 12.24 A |
| Current loading | 97.5% |
| Estimated apparent power | 4.76 kVA |
| System status | Normal |

## Important Limitation

Temperature and vibration are simplified simulation signals for demonstration. This is an academic simulation prototype; it is not a hardware-validated industrial transformer-protection system.

## Author

**Roshan Shahu**  
Electrical Engineering Student | Mumbai, India
