#!/bin/bash
set -e

echo "Compilando firmware STM32F103 (Cortex-M3)..."

cd /firmware

arm-none-eabi-gcc \
  -mcpu=cortex-m3 \
  -mthumb \
  -Wall -Wextra \
  -nostdlib -nostartfiles \
  -T stm32f103.ld \
  -o firmware.elf \
  main.c

echo "✓ Firmware compilado: firmware.elf"
