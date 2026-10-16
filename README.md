
# Day 15 — Traffic Light Controller

<p align="center">
  <b>Digital VLSI • Verilog RTL • FSM Design • Functional Verification • Cadence Genus</b>
</p>

<p align="center">
  <code>Specification → FSM Architecture → RTL → Testbench → Simulation → Synthesis → Area → Power → Timing → PPA Review</code>
</p>

<p align="center">
  <img alt="Project" src="https://img.shields.io/badge/Project-Day%2015-blue">
  <img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">
  <img alt="Synthesis" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">
  <img alt="Timing" src="https://img.shields.io/badge/Timing-Setup%20Path%20MET-success">
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Day 15 — Traffic Light Controller |
| **Author** | Omkar Kalmesh Hadapad |
| **Domain** | Digital VLSI / RTL Design / Functional Verification |
| **Design Type** | Finite-state machine (FSM) and timer-controlled digital controller |
| **HDL** | Verilog HDL |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Target Library** | `tsmc18` |
| **Top Module** | `traffic_light_controller_top` |
| **Reported Operating Condition** | `slow (balanced_tree)` |
| **Reported Wireload Mode** | `enclosed` |
| **Analysis** | Hierarchy, standard-cell area, power, and setup timing |
| **Simulation Summary** | Not supplied in the reviewed reports |
| **Physical-Design Status** | Post-route implementation and extracted-parasitic closure are not established by the available reports |

> **Measurement note:** The area report gives `665.280`, but the supplied excerpt does not explicitly confirm the physical area unit. This README therefore uses *reported area units* rather than assuming µm².

---

## 2. Project Overview

A traffic light controller is a synchronous digital control system that sequences traffic-light outputs according to a defined state machine and timing conditions. This project uses a state-register block, next-state logic, timer-counter logic, timer-done logic, and output-decoding logic.

The design was synthesized using Cadence Genus. The available reports provide mapped standard-cell area, power estimates, hierarchy, and one setup timing path. These are synthesis-stage results; they must not be described as final post-layout PPA without physical-design and extracted-parasitic reports.

### Conceptual control flow

```text
                 ┌─────────────────────┐
                 │ Timer Counter       │
                 └──────────┬──────────┘
                            │ timer status
                            ▼
                 ┌─────────────────────┐
                 │ Timer-Done Logic    │
                 └──────────┬──────────┘
                            │
                            ▼
┌──────────────┐  ┌─────────────────────┐
│ State        │─►│ Next-State Logic    │
│ Registers    │  └──────────┬──────────┘
└──────▲───────┘             │
       └─────────────────────┘
                            │ current state
                            ▼
                 ┌─────────────────────┐
                 │ Output Decoder      │
                 └──────────┬──────────┘
                            ▼
                    Traffic-light outputs
```

This is a conceptual view based on the reported hierarchy names. The exact signal-level connectivity and traffic phases should be confirmed from the RTL and mapped netlist.

---

## 3. Objectives

1. Understand FSM-based traffic-light control.
2. Separate state storage, next-state logic, timer logic, and output decoding.
3. Review the synthesized module hierarchy.
4. Interpret mapped standard-cell counts and area.
5. Analyze register, logic, and clock power categories.
6. Read a register-to-register setup timing path.
7. Calculate setup slack from required and arrival times.
8. Distinguish a passing timing path from complete timing closure.
9. Identify the limits of synthesis-stage PPA reports.
10. Prepare the design for further timing, verification, and physical-design analysis.

---

## 4. Hierarchy Report Analysis

The supplied hierarchy report identifies these blocks:

```text
traffic_light_controller_top
└── STRUCTURAL (traffic_light_controller_structural)
    ├── DONE (timer_done_logic)
    │   ├── A0 (and_gate)
    │   └── A1 (and_gate_15)
    ├── NEXT (traffic_next_state)
    ├── OUTPUT (traffic_output_decoder)
    ├── STATE (traffic_state_register)
    │   ├── FF0 (dff_sync_reset_18)
    │   ├── FF1 (dff_sync_reset_17)
    │   └── FF2 (dff_sync_reset_16)
    └── TIMER (timer_counter_3bit)
        ├── FF0 (dff_sync_reset)
        ├── FF1 (dff_sync_reset_20)
        └── FF2 (dff_sync_reset_19)
```

### Hierarchy interpretation

| Block | Role indicated by the report |
|---|---|
| `traffic_light_controller_top` | Top-level design |
| `traffic_light_controller_structural` | Structural implementation hierarchy |
| `timer_done_logic` | Generates the timer-completion condition |
| `traffic_next_state` | Computes the next FSM state |
| `traffic_output_decoder` | Decodes state into traffic-light outputs |
| `traffic_state_register` | Stores FSM state |
| `timer_counter_3bit` | Stores the timer count |

The hierarchy lists three state-register flip-flop instances and three timer-counter flip-flop instances. The mapped-cell summary also reports six sequential cells in total. Confirm exact logical-to-cell mapping using the RTL and mapped netlist.

---

## 5. Standard-Cell Area Analysis

### Overall synthesis results

| Metric | Reported result |
|---|---:|
| Top module | `traffic_light_controller_top` |
| Mapped standard-cell instances | **33** |
| Total reported cell area | **665.280 area units** |
| Sequential cells | 6 |
| Inverters | 9 |
| Other logic cells | 18 |
| Physical cells | 0 |
| Library | `tsmc18` |

### Sequential versus combinational area

| Category | Instances | Reported area | Share |
|---|---:|---:|---:|
| Sequential cells | 6 | 335.966 | 50.5% |
| Inverters | 9 | 59.875 | 9.0% |
| Other logic | 18 | 269.438 | 40.5% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **33** | **665.280** | **100%** |

### Area distribution

```text
Sequential cells          50.5%  █████████████████████████
Other logic               40.5%  ████████████████████
Inverters                  9.0%  ████
Physical cells             0.0%
```

**Interpretation:** Sequential cells account for approximately half of the reported cell area. This is a mapped standard-cell area distribution, not a floorplan or core-area measurement.

---

## 6. Power Report Analysis

### Overall power summary

| Metric | Reported value |
|---|---:|
| **Total power** | **5.21520e-05 W = 52.1520 µW** |
| Leakage power | 2.01479e-08 W = 20.1479 nW |
| Internal power | 4.29844e-05 W = 42.9844 µW |
| Switching power | 9.14745e-06 W = 9.14745 µW |

### Power by category

| Category | Reported total | Share of total |
|---|---:|---:|
| Register | 40.2711 µW | 77.22% |
| Logic | 7.18323 µW | 13.77% |
| Clock | 4.69768 µW | 9.01% |
| Memory, latch, bbox, pad, pm | 0 | 0% |
| **Subtotal** | **52.1520 µW** | **100%** |

### Power interpretation

- Register power is the largest reported category at **77.22%**.
- The logic category contributes **13.77%**.
- The clock category contributes **9.01%**, reported as switching power.
- Leakage is small in this estimate, at approximately **20.15 nW**.
- The report frame is `/stim#0/frame#0`. The activity source, activity coverage, voltage, and analysis duration are not established by this excerpt.

**Important:** Treat 52.1520 µW as the reported power estimate under the selected analysis conditions, not as confirmed post-route or silicon power. Validate the input activity and clock assumptions before comparing power across design versions.

---

## 7. Timing Report Analysis

### Reported setup path

| Timing item | Reported value |
|---|---:|
| Path status | **MET** |
| Reported setup slack | **+7469 ps = +7.469 ns** |
| Launch point | `STRUCTURAL/TIMER/FF1/Q_reg/CK` |
| Capture point | `STRUCTURAL/STATE/FF1/Q_reg/D` |
| Clock period | **10,000 ps = 10 ns** |
| Constrained clock frequency | **100 MHz** |
| Data-path delay | **1134 ps = 1.134 ns** |
| Setup time | 396 ps |
| Clock uncertainty | 1000 ps |
| Required time | 8604 ps |

### Reported path structure

```text
Timer FF1/Q
    │
    ▼
AND2X2              161 ps
    │
    ▼
AND2X2              159 ps
    │
    ▼
NAND2X1             129 ps
    │
    ▼
AOI2BB2X1            175 ps
    │
    ▼
NOR2X1                61 ps
    │
    ▼
State FF1/D
```

The reported cumulative data arrival time is 1134 ps.

### Slack calculation

The timing report gives a required time of 8604 ps and data arrival of 1134 ps.

\[
\text{Setup slack}=\text{Required time}-\text{Arrival time}
\]

\[
8604\text{ ps}-1134\text{ ps}=7470\text{ ps}
\]

The report prints **7469 ps**, a 1 ps difference from arithmetic on the displayed values. This may be due to internal timing precision or rounding.

**Interpretation:** The shown path passes setup timing with approximately **+7.469 ns** slack under the reported constraints. This is the path shown in the excerpt; full design timing closure is not established by one path alone.

### Frequency interpretation

The applied clock constraint is:

\[
f_{\text{clock}}=\frac{1}{10\text{ ns}}=100\text{ MHz}
\]

This is the constrained clock frequency, not a measured maximum frequency. Do not claim the design's maximum frequency from this path alone. Other paths, clock assumptions, hold checks, and implementation effects may impose tighter limits.

### Timing checks still required

- Review the full worst-path report across all constrained register paths.
- Run `check_timing` and investigate unconstrained paths.
- Confirm the active SDC clock period, uncertainty, and I/O delays.
- Check setup and hold timing separately.
- Confirm whether the report is pre-layout or post-layout.
- Do not treat wireload-mode timing as routed, extracted-parasitic timing.

---

## 8. PPA Summary

| Metric | Result | Qualification |
|---|---:|---|
| Mapped standard-cell count | 33 | Genus cell summary |
| Total reported area | 665.280 area units | Physical unit not confirmed |
| Total reported power | 52.1520 µW | Synthesis-stage estimate |
| Displayed setup slack | +7.469 ns | One reported setup path |
| Displayed path status | MET | Applies to the displayed path |
| Constrained clock frequency | 100 MHz | Derived from 10 ns clock period |
| Maximum frequency | Not established | Requires complete constrained timing analysis |
| Post-route PPA | Not established | No extracted-parasitic evidence supplied |

---

## 9. Recommended Verification and Synthesis Checks

Use these checks in the existing Genus session; command options may vary by setup.

```tcl
check_timing
report_timing -max_paths 20
help report_timing
```

Review the full timing output and active SDC. Do not add a second clock constraint without first checking the constraints already loaded.

For a stronger verification result, retain the RTL, testbench, simulation transcript, and any available waveform. Confirm that the reference model samples and updates on the intended simulation phase.

---

## 10. Industry Relevance

Traffic-light controllers are useful FSM exercises because they combine state storage, timer conditions, next-state logic, and output decoding. This project demonstrates how to move from a control-oriented specification to a synthesized implementation and interpret area, power, and timing reports.

The analysis also reinforces an important engineering distinction: a successful simulation, a small mapped area, a power estimate, and one passing setup path are separate pieces of evidence. None alone proves complete ASIC physical-design closure.

---

## 11. Interview Questions

1. Why is a traffic-light controller a natural FSM application?
2. What are the roles of the state register and next-state logic?
3. Why is timer-done logic used in state transitions?
4. What is the difference between combinational and sequential logic?
5. What does technology mapping do?
6. Why can sequential cells account for a large fraction of area and power?
7. What are internal, switching, and leakage power?
8. What does positive setup slack mean?
9. Why does one `MET` timing path not prove full timing closure?
10. Why is a constrained clock frequency different from the maximum achievable frequency?
11. What additional reports are needed for post-route timing and power?
12. How would you test that conflicting traffic directions are never green simultaneously?

---

## 12. Project Status

| Stage | Status |
|---|---|
| Hierarchy report reviewed | Complete for supplied report |
| Standard-cell area reviewed | Complete for supplied report |
| Power report reviewed | Complete for supplied report; activity assumptions need confirmation |
| One setup path reviewed | Complete for supplied report |
| Simulation summary | Not supplied in the reviewed reports |
| Full setup/hold timing closure | Not established |
| Maximum frequency | Not established |
| Post-route PPA closure | Not established |

---

## 13. Final Results

| Parameter | Reported value |
|---|---:|
| Top module | `traffic_light_controller_top` |
| Standard-cell count | 33 |
| Total reported area | 665.280 area units |
| Total reported power | 52.1520 µW |
| Displayed setup slack | +7.469 ns |
| Displayed path status | MET |
| Constrained clock frequency | 100 MHz |
| Maximum frequency | Not established |
| Post-route status | Not established |

**Conclusion:** The supplied reports show a 33-cell synthesized traffic-light controller, a reported power estimate of 52.1520 µW, and one setup path marked MET with +7.469 ns slack under a 10 ns clock constraint. Full timing closure, maximum frequency, and post-route PPA remain unverified.

---

## 14. Next Project — Day 16: Traffic Light Controller with Pedestrian Crossing

The next project will extend the Day 15 FSM with a pedestrian-crossing request.

**Planned focus:**

- Add a pedestrian request input.
- Define request priority and safe state transitions.
- Prevent conflicting vehicle-green outputs.
- Define pedestrian walk and stop outputs.
- Verify reset behavior, request capture, and return to normal traffic sequencing.
- Extend the testbench with normal traffic, pedestrian requests, repeated requests, and reset scenarios.
- Re-run Genus synthesis and compare cell area, power, and timing against Day 15.

**Key learning goal:** extend an existing FSM safely while managing new inputs, state transitions, and verification coverage.

**Status:** Planned — not yet implemented or verified.

---

## 15. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering  
Digital VLSI • Verilog RTL • FSM Design • Cadence Genus

---

<p align="center">
  <b>Day 15 — Traffic Light Controller · Next: Day 16 — VENDING MACHINE CONTROLLER</b>
</p>

