# Simulation Test Results

## Normal Operation

| Parameter | Observed Result |
|---|---:|
| Phase RMS voltage | Approximately 129.6 V |
| Phase RMS current | Approximately 12.24 A |
| Current loading | Approximately 97.5% |
| Estimated apparent power | Approximately 4.76 kVA |
| System status | 0 - Normal |
| Fault indicators | All 0 |

## High-Vibration Test

The high-vibration case is activated through the monitoring input. After the configured time delay, the High_Vibration indicator becomes 1 and the overall system status changes to Fault.

## Overload Test

The load is increased above the normal setting. The RMS current rises above its overload threshold, causing the Overload indicator to activate.

## Short-Circuit Test

A temporary electrical fault is introduced at the transformer secondary. The Current Scope shows a fault-current rise and the Voltage Scope shows a disturbance during the fault interval.

## Unbalanced-Load Test

Different phase-load values are applied. The three phase currents become unequal, demonstrating an unbalanced load condition.

## Note

Results are simulation outputs. Temperature and vibration channels are demonstration models and are not physical sensor measurements.
