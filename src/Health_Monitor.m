function [loading,S_est,T,Vib,HI,status,flags] = ...
    Health_Monitor(Vrms,Irms,t,sensor_case,Ts)
%#codegen

% INPUTS
% Vrms        : Three phase-to-neutral RMS voltages, V
% Irms        : Three phase RMS currents, A
% t           : Simulation time, s
% sensor_case : 0 = normal sensor models
%               1 = extra heating demonstration
%               2 = high vibration demonstration
% Ts          : Function execution interval, s
%
% OUTPUTS
% loading : Maximum phase current loading, %
% S_est   : Balanced-system apparent-power estimate, VA
% T       : Accelerated modeled temperature, deg C
% Vib     : Synthetic vibration RMS channel, m/s^2
% HI      : Project-specific condition score, 0 to 100
% status  : 0 = normal, 1 = warning, 2 = fault
% flags   : Seven fault indicators, listed below

persistent temperature fault_timer

if isempty(temperature)
    temperature = 30.0;
    fault_timer = zeros(7,1);
end

%% Rated quantities

S_rated = 5000.0;
Vll_rated = 230.0;

Vph_rated = Vll_rated/sqrt(3.0);
I_rated = S_rated/(sqrt(3.0)*Vll_rated);

%% Phase measurements

Ia = Irms(1);
Ib = Irms(2);
Ic = Irms(3);

Va = Vrms(1);
Vb = Vrms(2);
Vc = Vrms(3);

Imax = max([Ia, Ib, Ic]);
Imin = min([Ia, Ib, Ic]);

Vmax = max([Va, Vb, Vc]);
Vmin = min([Va, Vb, Vc]);

Iavg = (Ia + Ib + Ic)/3.0;
Vavg = (Va + Vb + Vc)/3.0;

%% Electrical monitoring

loading = 100.0*Imax/I_rated;

% Use this estimate only for approximately balanced operation.
S_est = 3.0*Vavg*Iavg;

%% Accelerated temperature model

Tamb = 30.0;
rated_temperature_rise = 45.0;

Ttarget = Tamb + rated_temperature_rise*(Imax/I_rated)^2;

% Extra heating starts after 0.8 seconds.
if sensor_case == 1 && t >= 0.8
    Ttarget = Ttarget + 70.0;
end

% Artificially short time constant for demonstration.
% This is not a realistic transformer heating time constant.
tau_demo = 0.4;

alpha = exp(-Ts/tau_demo);

temperature = alpha*temperature + (1.0-alpha)*Ttarget;

T = temperature;

%% Synthetic vibration RMS channel

Vib = 0.30 + 0.08*(Imax/I_rated)^2 ...
      + 0.02*sin(2.0*pi*3.0*t);

% Increased vibration starts after 0.8 seconds.
if sensor_case == 2 && t >= 0.8
    Vib = Vib + 1.0;
end

%% Raw fault conditions
% These are configurable demonstration thresholds.

raw = false(7,1);

% 1: Overload
raw(1) = Imax > 1.10*I_rated;

% 2: Overcurrent
raw(2) = Imax > 1.60*I_rated;

% 3: Overvoltage
raw(3) = Vmax > 1.05*Vph_rated;

% 4: Undervoltage
raw(4) = Vmin < 0.92*Vph_rated;

% 5: Open-phase signature
% Intended for measurement upstream of the load-side breaker.
raw(5) = Imin < 0.10*I_rated && ...
         Imax > 0.30*I_rated && ...
         Vmin > 0.80*Vph_rated;

% 6: Overtemperature
raw(6) = T > 90.0;

% 7: High vibration
raw(7) = Vib > 0.80;

%% Startup inhibition and persistence delay

startup_delay = 0.10;
detection_delay = 0.05;

for k = 1:7
    if t >= startup_delay && raw(k)
        fault_timer(k) = fault_timer(k) + Ts;
    else
        fault_timer(k) = 0.0;
    end
end

flags = false(7,1);

for k = 1:7
    flags(k) = fault_timer(k) >= detection_delay;
end

%% Overall status

status = 0.0;

if t >= startup_delay
    if any(flags)
        status = 2.0;
    elseif loading > 100.0 || T > 80.0 || Vib > 0.60
        status = 1.0;
    end
end

%% Project-specific condition score

voltage_deviation = max([abs(Va/Vph_rated-1.0), ...
                         abs(Vb/Vph_rated-1.0), ...
                         abs(Vc/Vph_rated-1.0)]);

current_penalty = min(40.0, max(0.0,loading-100.0)*0.5);
voltage_penalty = min(25.0,250.0*voltage_deviation);
temperature_penalty = min(20.0,max(0.0,T-75.0)*0.5);
vibration_penalty = min(15.0,max(0.0,Vib-0.40)*20.0);

HI = max(0.0,100.0-current_penalty-voltage_penalty ...
         -temperature_penalty-vibration_penalty);
end

%{
    SMART TRANSFORMER HEALTH MONITORING SYSTEM
STEP-BY-STEP GUIDE: ACTIVATE EACH OF THE SEVEN FAULT FLAGS
MATLAB/Simulink R2025b - using the supplied Health_Monitor code
=================================================================

PURPOSE
Test each flag in a separate simulation. Do not force the output to 1.
Create the abnormal input, then verify that the code detects it.
This is NOT an instruction to make all seven flags equal 1 simultaneously.
Multiple flags can legitimately activate in one test.
These settings are for simulation only, not physical transformer testing.

FLAG ORDER
1 = Overload
2 = Overcurrent
3 = Overvoltage
4 = Undervoltage
5 = Open-phase signature
6 = Overtemperature
7 = High vibration

0 means not currently detected; 1 means detected.
Status: 0 normal, 1 warning, 2 fault.
The code provides alarms only; it does not automatically trip the breaker.
Flags are not latched: they clear when their triggering condition clears.

IMPORTANT LIMITATIONS
Electrical faults use measured RMS signals. Temperature is an accelerated
model, vibration is synthetic, and HI is a project-specific score, not
remaining transformer life. Thresholds are demonstration assumptions,
not certified protection settings. Keep a backup of the normal model.

=================================================================
STEP A - RESOLVE THE TIMING CHECK BEFORE TESTING
=================================================================
Your temperature stayed near 46.2 C. First establish correct timing.

1. Connect an extra Display to the existing Clock output.
2. Set Stop Time = 2.
3. Confirm the Clock Display reaches approximately 2 at the end.
4. Set Sample_Time_Input Constant value = 1e-5.
5. Set the Health_Monitor MATLAB Function update method to Discrete
   and its sample time to 1e-5.
6. Keep powergui discrete sample time = 1e-5.
7. Keep the model fixed-step size = 1e-5, with the discrete solver
   if all blocks have been configured without continuous states.
8. Disable Fast Restart for these checks and restart each test fresh.

To configure the function programmatically, first single-click the
Health_Monitor block in the model, then run in MATLAB Command Window:

blk = gcb;
cfg = get_param(blk,'MATLABFunctionConfiguration');
cfg.UpdateMethod = 'Discrete';
cfg.SampleTime = '1e-5';
cfg.UpdateMethod
cfg.SampleTime

The selected block must be the MATLAB Function, not a Constant or Display.
With normal loading, correct timing and the supplied code, temperature
should be roughly 72 C after 2 seconds, rather than remaining near 46 C.
Do not alter thresholds to hide a timing problem. Alarm timers also use Ts.

=================================================================
STEP B - NORMAL SETTINGS / RESET BEFORE EVERY TEST
=================================================================
Stop the simulation before changing settings.

Three-Phase Source:
  Phase-to-phase RMS voltage = 400 V
  Frequency = 50 Hz

Three-Phase Parallel RLC Load (the actual LOAD block):
  Configuration = Y (grounded)
  Nominal phase-to-phase voltage = 230 V
  Nominal frequency = 50 Hz
  Active power P = 5000 W TOTAL across the three phases
  Inductive reactive power QL = 0 var
  Capacitive reactive power QC = 0 var
  Leave per-phase PQ specification unchecked if that option appears.

Three-Phase Breaker:
  Initial status = closed
  External control = disabled
  Switching time = [10] (outside our 2-second run)
  Select switching for phases A, B and C for the normal configuration.

Other settings:
  Sensor_Case_Input Constant = 0
  Sample_Time_Input Constant = 1e-5
  Stop Time = 2

Run and verify balanced measurements and all seven flags = 0.
Your recorded electrical baseline is about 129.6 V phase RMS and
12.24 A phase RMS, with current loading about 97.5%.
Save this normal model before applying fault cases.

=================================================================
TEST 1 - FIRST FLAG: OVERLOAD
=================================================================
1. Apply all normal/reset settings above.
2. Open Three-Phase Parallel RLC Load.
3. Change Active power P from 5000 to 7500 W.
4. Do NOT change nominal voltage, QL or QC.
5. Run for 2 seconds.
6. Check maximum phase RMS current exceeds about 13.81 A.
7. Check flags entry 1 becomes 1 and status becomes 2.

Code condition: maximum current > 1.10 x rated current.
Rated current is approximately 12.55 A.
The condition must last 0.05 s after the 0.10 s startup inhibition.
Other flags, especially temperature, may activate as well.
Actual loading can differ from 150% because terminal voltage drops.

RESET: Restore P = 5000 W before the next test.

=================================================================
TEST 2 - SECOND FLAG: OVERCURRENT
=================================================================
1. Apply normal/reset settings.
2. Set load Active power P = 10000 W.
3. Run for 2 seconds.
4. Check maximum phase RMS current exceeds about 20.08 A.
5. Check flags entry 2 = 1.

Code condition: maximum current > 1.60 x rated current.
Entry 1 should also be 1 because the overload threshold is lower.
Temperature or undervoltage may also activate, depending on results.
If entry 2 stays 0, inspect actual current and timing first. The nominal
load setting does not guarantee the threshold is crossed.

RESET: Restore P = 5000 W.

=================================================================
TEST 3 - THIRD FLAG: OVERVOLTAGE
=================================================================
1. Apply normal/reset settings.
2. Open Three-Phase Source.
3. Change phase-to-phase RMS source voltage from 400 to 440 V.
4. Keep transformer ratings 400/230 V unchanged.
5. Keep load nominal voltage 230 V and load P = 5000 W unchanged.
6. Run for 2 seconds.
7. Check maximum phase RMS voltage exceeds about 139.43 V.
8. Check flags entry 3 = 1 and status = 2.

Code condition: maximum phase voltage > 1.05 x (230/sqrt(3)).
Your measured baseline suggests this test should cross the threshold,
but verify the actual voltage instead of assuming the result.

RESET: Restore source voltage = 400 V.

=================================================================
TEST 4 - FOURTH FLAG: UNDERVOLTAGE
=================================================================
1. Apply normal/reset settings.
2. Set source phase-to-phase RMS voltage = 360 V.
3. Keep transformer ratings and load nominal voltage unchanged.
4. Run for 2 seconds.
5. Check minimum phase RMS voltage falls below about 122.17 V.
6. Check flags entry 4 = 1 and status = 2.

Code condition: minimum phase voltage < 0.92 x (230/sqrt(3)).
The normal resistive load current also decreases with reduced voltage.

RESET: Restore source voltage = 400 V.

=================================================================
TEST 5 - FIFTH FLAG: OPEN SECONDARY PHASE
=================================================================
Required layout:
Transformer -> V-I Measurement -> Breaker -> grounded-star load
The voltage measurement is UPSTREAM of the breaker.

1. Apply normal/reset settings.
2. Open the Three-Phase Breaker dialog.
3. Set Initial status = closed.
4. Disable external control.
5. Enable Switching of phase A only.
6. Disable Switching of phases B and C so they remain initially closed.
7. Set switching times = [0.8].
8. Run for 2 seconds.
9. Inspect current RMS readings after the switching event and RMS window.
10. Phase-A load current should fall near zero; B and C remain loaded.
11. Check flags entry 5 becomes 1 and status becomes 2.

The supplied code requires ALL these conditions:
  Minimum current < 0.10 x rated current (about 1.26 A)
  Maximum current > 0.30 x rated current (about 3.77 A)
  Minimum measured phase voltage > 0.80 x nominal (about 106.23 V)

Do not open all three phases: that will not satisfy this open-phase logic.
Transformer-side voltages may stay healthy because the measurement is
upstream of the open breaker. This is expected for this model.
Allow for RMS measurement settling and the extra 0.05 s detection delay.
This is an open-phase signature detector, not a universal fault locator.

RESET:
  Initial status = closed
  Switching times = [10]
  Re-enable phase switching selections A, B and C
  Keep external control disabled

=================================================================
TEST 6 - SIXTH FLAG: OVERTEMPERATURE
=================================================================
1. Apply normal/reset electrical settings.
2. Double-click Sensor_Case_Input Constant.
3. Set Constant value = 1.
4. Run for 2 seconds.
5. The supplied code adds extra modeled heating after 0.8 s.
6. Check modeled temperature rises above 90 C.
7. Check flags entry 6 = 1 and status = 2.

This does not heat a real transformer or modify its electrical winding
resistance. It injects extra heating into our accelerated sensor model.
The 0.4 s thermal time constant is intentionally artificial for a demo.
If temperature never rises as intended, return to the timing check.

RESET: Sensor_Case_Input = 0.

=================================================================
TEST 7 - SEVENTH FLAG: HIGH VIBRATION
=================================================================
1. Apply normal/reset electrical settings.
2. Set Sensor_Case_Input Constant = 2.
3. Run for 2 seconds.
4. At 0.8 s, the supplied code adds 1.0 m/s^2 to the synthetic RMS channel.
5. Vibration should finish near 1.38 m/s^2 under normal electrical load.
6. Check flags entry 7 = 1 and status = 2.

Code condition: vibration RMS > 0.80 m/s^2 for the detection delay.
This channel is synthetic; it is not a mechanical vibration prediction.

Expected flag vector if no other conditions are active:
[0; 0; 0; 0; 0; 0; 1]

RESET: Sensor_Case_Input = 0.

=================================================================
QUICK REFERENCE
=================================================================
Test           Source V    Load P      Sensor case    Breaker
Normal         400         5000        0              Closed
Overload       400         7500        0              Closed
Overcurrent    400         10000       0              Closed
Overvoltage    440         5000        0              Closed
Undervoltage   360         5000        0              Closed
Open phase     400         5000        0              Open A at 0.8 s
Temperature    400         5000        1              Closed
Vibration      400         5000        2              Closed

Source voltage above is LINE-TO-LINE RMS in volts.
Load P above is TOTAL nominal three-phase active power in watts.
These rows are starting test settings; verify measured thresholds.

=================================================================
HOW TO DISPLAY THE SEVEN FLAGS CLEARLY
=================================================================
Option A: Enlarge the existing Fault_Flags Display vertically.
Option B: flags -> Demux (7 outputs) -> seven separate Display blocks.
Label top to bottom with the flag order at the start of this file.
Use a Scope for flags/status if you want the detection times as well.

=================================================================
RESULTS CHECKLIST
=================================================================
For EACH test record:
  Test name:
  Source voltage setting:
  Load power setting:
  Sensor case:
  Final Clock time:
  Phase RMS voltages:
  Phase RMS currents:
  Current loading:
  Modeled temperature:
  Synthetic vibration:
  All seven flags:
  Overall status:

Capture a screenshot and save the settings before resetting for the next
case. A test passes when the intended measured condition crosses its
threshold and the corresponding flag activates after its delay.
Do not overwrite flags in code to manufacture a passing result.

FINAL RESET
Source = 400 V; load P = 5000 W; sensor case = 0; breaker closed;
no switching before 2 s; Ts = 1e-5; Stop Time = 2.
Restart and confirm all seven flags return to 0 under normal conditions.
   %}
