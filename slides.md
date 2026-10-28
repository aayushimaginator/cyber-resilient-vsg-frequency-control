---
title: "A Cyber-Resilient Secondary Frequency Control Framework"
subtitle: "Independent Analysis & Stress-Test\nJamali et al. (IEEE TIE 2026)\nPresented by: Aayush"
---

## The Modern Grid Problem

- **2015 Ukraine Blackout:** Malware opened circuit breakers, leaving 230,000 in the dark.
- Shift from heavy Synchronous Generators (SGs) to Inverter-Based Resources (IBRs).
- IBRs (solar, batteries) have **ZERO** physical inertia.
- **Result:** Cyberattacks cause frequency crashes in milliseconds, not minutes.

## The Attack Surface

- Secondary Control requires network communication to fix frequency errors.
- This network is the primary attack surface.
- **Threat:** False Data Injection (FDI).
- Hackers inject bounded, stealthy signals ($\delta_u, \delta_\xi$) to mislead controllers.
- **Goal:** Force inverters to destroy the grid from the inside without tripping alarms.

## The Physical Plant (VSG Control)

- Virtual Synchronous Generator (VSG) fakes physical inertia via software.
- Governing Equation: Swing Equation
- $M \dot{\omega} = -D\omega + P_{net} - P_e + u$
- $\omega$ = frequency deviation, $u$ = secondary control 'nudge'.
- The hacker's goal is to corrupt the control input $u$.

## The Core Innovation

- **Standard Control:** Pure Integrator ($H=0$). Accumulates error until $\omega=0$.
- **Vulnerability:** Constant FDI attack causes integrator 'wind-up' -> Blackout.
- **Proposed Control:** Ancillary state $\xi$ with 'leak' matrix $H > 0$.
- **Equation:** $\dot{\xi} = -H\xi - \beta K^T \omega$
- **Result:** Turns integrator into a low-pass filter. Prevents wind-up, guarantees survival.

## The Theoretical Guarantee

- **Lur'e System Representation:** Isolates nonlinear sine waves into bounded feedback.
- **Lyapunov Stability:** Proves the linear core is asymptotically stable.
- **Small-Gain Theorem:** Ensures the nonlinear feedback loop doesn't amplify attacks to infinity.
- **Convex Optimization:** Computes the exact maximum attack bound the grid can survive.

## My Independent Implementation

- **Tool:** GNU Octave / MATLAB (ODE45 Solver).
- **Topology:** 4-IBR Ring Network.
- **Approach:** Swing-level mathematical abstraction.
- **Why?** Isolates the exact mathematical claims of the secondary control layer without confounding hardware noise (PWM, inner PI loops).

## Result 1: The Baseline Fault

![Baseline Fault Comparison](Fig1_Controller_Comparison.png)

- Comparing Pure Integrator ($H=0$) vs Proposed ($H=150$).
- **Observation:** Pure integrator 'winds up'. Frequency deviation explodes.
- **Conclusion:** Conventional secondary control is defenseless against computational attacks.

## Result 2: The Proposed Survival

![Proposed Survival](Fig2_Money_Slide.png)

- Proposed Controller ($H=150$) under FDI Attack.
- Red shaded region indicates active cyberattack.
- **Observation:** Frequency wobbles but remains STRICTLY BOUNDED.
- **Conclusion:** The controller takes the punch and survives.

## Result 3: Active Power Sharing

![Power Sharing](Fig3_Power_Sharing.png)

- Inverters must share electrical load proportionally.
- During the attack window, active power sharing remains stable.
- The proposed controller prevents inverters from overloading each other.

## Result 4: The Resilience vs Accuracy Trade-off

![Trade-off Curve](Fig4_Tradeoff_Curve.png)

- **Resilience is not free.**
- **H-Sweep:** Varying the leak parameter $H$.
- As $H$ increases, steady-state error after load step increases.
- Paper's choice ($H=150$) is a deliberate compromise on this curve.

## Critical Analysis & Limitations

1. **No Exact Restoration:** The 0.2% offset is caused by the leak matrix $H$, not a physical governor.
2. **Bounded Attacks Only:** Math only holds for bounded FDI. Brute-force unbounded attacks break the guarantee.
3. **Baseline Asymmetry:** Baselines in paper only face actuation attacks ($\delta_u$), not computational attacks ($\delta_\xi$).

## Conclusion

- Provides a rigorous, quantifiable way to make microgrids survive cyberattacks.
- Does not rely on slow, fallible detection algorithms.
- Converts cyber-resilience from a buzzword into a computable engineering metric.
- **The ultimate trade-off:** A tiny fraction of steady-state accuracy to ensure the grid never goes dark.
