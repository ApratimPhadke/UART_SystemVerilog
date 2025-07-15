<h1 align="center">🔌 SystemVerilog UART Transmitter & Receiver</h1>

<p align="center">
</p>

<p align="center">
  <b>📡 A fully synthesizable UART core built in SystemVerilog — with clean RTL, testbenches, automation scripts, and waveform verification.</b>
</p>

---

## 📘 Introduction

This project implements a **UART (Universal Asynchronous Receiver/Transmitter)** system in **SystemVerilog**, developed for simulation and integration into FPGA or ASIC designs. It includes both **transmit (Tx)** and **receive (Rx)** modules, a **parameterized baud rate generator**, **testbenches**, and **automated simulation scripts** using Vivado.

This project follows a **professional hardware design structure**, making it a great learning resource or portfolio project for VLSI, RTL, and FPGA engineers.

---

## 🧠 Key Features

- ✅ Modular Transmitter (`uart_tx.sv`)
- ✅ Modular Receiver (`uart_rx.sv`)
- ✅ Parameterized Baud Rate Generator
- ✅ Synthesizable RTL Code
- ✅ Fully Functional Testbench (`tb_uart.sv`)
- ✅ Simulation-ready with Vivado TCL script
- ✅ Professional GitHub Structure

---

## 📁 Folder Structure
UART_SystemVerilog/
├── src/ → RTL Design Files
├── tb/ → Testbenches
├── sim/ → Simulation Outputs (e.g., VCD/WDB files)
│ └── waveforms/
├── scripts/ → TCL Scripts for Vivado
├── images/ → Diagrams & Waveform Screenshots
├── docs/ → Protocol Descriptions
├── .gitignore → Ignore Vivado & sim clutter
├── README.md → This File

## ⚙️ UART Protocol Overview

UART transmits serial data using the following frame format:
[Start Bit] → [8 Data Bits] → [Stop Bit]

- **No parity**, **no flow control** (8N1)
- **LSB-first** data transmission
- Timing managed using custom **baud rate generator**

<p align="center">
  <img src="images/uart_timing_diagram.png" width="600" alt="UART Timing">
</p>

---

## 💡 Simulation Instructions

### ▶ Using Vivado Tcl Console:

```tcl
cd scripts
source simulate.tcl

Simulates the design using XSIM

Dumps waveform data to .wdb

View results in Vivado or export to .vcd for GTKWave

📊 Example Waveform
<p align="center"> <img src="images/waveform.png" width="700" alt="Waveform"> </p>
🧪 Testbench Details
Drives test patterns to UART transmitter

Receiver checks reconstructed data

Verifies serial/parallel conversions and timing

Flexible to extend with edge cases

🛠 Customization
Feature	How to Modify
Baud Rate	Change divisor in baud_gen.sv
Data Width	Extend registers and FSMs
Stop Bits	Modify Tx/Rx FSMs
Parity Bit	Add generator/checker logic

🧭 Roadmap
 UART Tx/Rx RTL Implementation

 Baud Generator

 Simulation with Testbench

 Add parity and configurable stop bits

 GitHub Actions simulation pipeline

 Verilator + GTKWave support

 Vivado IP Packager Integration

🧑‍💻 Author
Apratim Phadke
🎓 B.Tech. Electronics & Telecommunication
📍 Pune, India
🌐 Passionate about VLSI, RTL Design, and Digital Systems

🤝 Contributions Welcome
If you're passionate about hardware design, VLSI, or FPGA systems, feel free to:

Fork this repo

Create PRs with improvements

Raise issues or suggest enhancements

Let’s build clean HDL together. 🧠💻💥

📄 License
Licensed under the MIT License — free to use, modify, and distribute.

<p align="center"><b>⭐ Star this repository to support the project and inspire more hardware design tutorials!</b></p> ```
