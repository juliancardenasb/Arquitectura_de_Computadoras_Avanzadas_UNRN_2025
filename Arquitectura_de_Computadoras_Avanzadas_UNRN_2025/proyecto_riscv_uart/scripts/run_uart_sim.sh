#!/bin/bash
echo "=== Compilando Sistema RISC-V con UART (Versión Final) ==="

# Compilar con soporte mínimo de SystemVerilog
iverilog -g2012 -o uart_sim \
  testbench/tb_uart_system.sv \
  rtl/top.sv \
  rtl/riscv_single.sv \
  rtl/datapath.sv \
  rtl/controller.sv \
  rtl/alu.sv \
  rtl/regfile.sv \
  rtl/imem.sv \
  rtl/dmem.sv \
  rtl/io.sv \
  rtl/mux2.sv \
  rtl/mux3.sv \
  rtl/flopr.sv \
  rtl/extend.sv \
  rtl/aludec.sv \
  rtl/maindecoder.sv \
  rtl/adder.sv \
  rtl/clock_divider.sv \
  rtl/debounce.sv \
  rtl/uart/band_rate_generator.sv \
  rtl/uart/fifo.sv \
  rtl/uart/receiver.sv \
  rtl/uart/transmitter.sv \
  rtl/uart/uart_top.sv \
  rtl/uart/riscv_uart.sv

if [ $? -eq 0 ]; then
    echo "=== Compilación Exitosa ==="
    echo "=== Ejecutando Simulación ==="
    vvp uart_sim
else
    echo "=== Error en Compilación ==="
    exit 1
fi