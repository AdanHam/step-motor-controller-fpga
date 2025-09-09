# Step Motor Controller (FPGA, SystemVerilog)

Digital controller for stepper motors (Unipolar/Bipolar) implemented on Intel DE10 board.  
Project done as part of the Digital Electronics Lab, Hebrew University of Jerusalem.

## Features
- **Direction control**: CW/CCW (SW1)
- **Speed control**: 10–60 RPM, incremented by 10 on button press (KEY3)
- **Quarter-turn function**: exact 90° rotation per press (KEY1)
- **Step size**: full-step / half-step (SW3)
- **Mode**: continuous (SW2 ON) or stop
- **7-segment display**: shows motor speed (HEX1, HEX0)

---

## Repository Structure
src/ # SystemVerilog modules
tb/ # Testbenches
constraints/ # Pin assignments
sim/ # ModelSim scripts


---

## Modules Overview

| File                   | Function                                                                 |
|------------------------|---------------------------------------------------------------------------|
| `direction_control.sv` | Sets motor rotation direction (CW/CCW).                                  |
| `enable_controller.sv` | Manages ON/OFF enable signals.                                           |
| `pulse_generator.sv`   | Generates clock pulses at selected speed (10–60 RPM).                    |
| `quarter_rotation.sv`  | Implements accurate quarter-turn functionality (90° per button press).   |
| `seven_segment.sv`     | Drives 7-segment displays to show speed value.                           |
| `speed_control.sv`     | Maps button presses to speed levels and passes values to pulse generator.|
| `step_motor_top.sv`    | Top-level module integrating all submodules.                             |
| `step_motor_top_tb.sv` | Testbench verifying functionality in simulation.                         |
| `step_motor_top.csv`   | Pin assignment file for FPGA board.                                      |
| `wave.do`              | ModelSim waveform script for functional simulation.                      |

---

## How to Run
1. Open project in **Intel Quartus Prime**.  
2. Add `src/` and `constraints/` files.  
3. Run functional simulation in **ModelSim** (`sim/wave.do`).  
4. Compile and program the FPGA (DE10-Standard).  
5. Verify motor control via switches and 7-segment display.

---

## Notes
- No multiply/divide operators used (as required by lab).  
- Idle state drives coils to 0 to avoid overheating.  

---

## License
MIT
