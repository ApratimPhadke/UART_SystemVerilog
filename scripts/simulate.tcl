# simulate.tcl - Run simulation on UART

read_verilog ../src/uart_tx.sv
read_verilog ../src/uart_rx.sv
read_verilog ../tb/tb_uart.sv

# Create and elaborate design
synth_design -top tb_uart -part xc7z010clg400-1
launch_simulation
run 1us
