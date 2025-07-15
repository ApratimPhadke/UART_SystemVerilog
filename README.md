\# UART Transmitter and Receiver in SystemVerilog



A synthesizable and testbench-verified UART module with Tx and Rx paths, built in SystemVerilog and simulated using Vivado XSIM.



\## Features



\- Baudrate Generator

\- 8-bit data support

\- Transmit and Receive modules

\- Configurable testbench

\- Waveform verification



\## Folder Structure



\- `src/`: SystemVerilog RTL

\- `tb/`: Testbenches

\- `scripts/`: TCL scripts for automation

\- `sim/`: Simulation results

\- `docs/`: Diagrams, descriptions



\## How to Simulate



Run `simulate.tcl` using Vivado's Tcl console:



```bash

vivado -mode tcl -source scripts/simulate.tcl



