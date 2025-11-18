#!/bin/bash
echo "=== Compilando Sistema RISC-V (Versión Final) ==="

# Compilar con soporte mínimo de SystemVerilog
iverilog -g2012 -o sim \
  testbench/testbench.sv \
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

if [ $? -eq 0 ]; then
    echo "=== Compilación Exitosa ==="
    echo "=== Ejecutando Simulación ==="
    vvp sim
else
    echo "=== Error en Compilación ==="
    exit 1
fi