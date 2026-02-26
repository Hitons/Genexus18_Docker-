# Script para crear un firmware.elf mínimo
# Este firmware ejecuta un loop infinito simple

cat > create_firmware.ps1 << 'EOF'
# Cortex-M3 mínimo: Reset Handler que entra en loop infinito
# Offset 0x00000000: Stack pointer (0x20010000 = fin de RAM de 64KB)
# Offset 0x00000004: Reset handler (0x08000009 = dirección del código + Thumb)

$firmware = @(
    0x00, 0x00, 0x01, 0x20,  # Stack: 0x20010000
    0x09, 0x00, 0x00, 0x08,  # Reset: 0x08000009
    0x00, 0x00, 0x00, 0x00,  # NMI
    0x00, 0x00, 0x00, 0x00,  # HardFault
    # Resto de tabla (padding)
) + @(0x00) * 240

# Código mínimo (Thumb) @ 0x08000100
# Loop: b loop (branch siempre a sí mismo)
$code = @(
    0x00, 0xBF,  # NOP (2 bytes)
    0xFE, 0xE7,  # b . (branch a sí mismo)
) + @(0x00) * 65280

$bytes = $firmware + $code
[System.IO.File]::WriteAllBytes("$PSScriptRoot/firmware.bin", $bytes)
Write-Host "✓ firmware.bin creado ($(` $bytes.Length) bytes)"
EOF

PowerShell -File create_firmware.ps1
