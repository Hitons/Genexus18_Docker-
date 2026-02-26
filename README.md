# Genexus18_Docker-
Genexus 18 con despliegue integrado: App Web (AMD64), Servicio ARM64 y Microcontrolador Bare-Metal (Cortex-M3 en QEMU).

## Arquitectura

- `gxapp_amd64`: Aplicación web principal (AMD64, puerto `8081`).
- `microcontrolador_arm64`: Aplicación ARM64 Linux (puerto `8082`).
- `mcu_cortexm3`: Microcontrolador STM32F103 bare-metal emulado en QEMU (salida serial en logs).
- `sqlserver`: Base de datos SQL Server (puerto `1433`).

## Ejecutar

```bash
# Levantar todos los servicios
docker compose up -d --build

# Ver estado
docker compose ps

# Logs del MCU (firmware bare-metal)
docker compose logs -f mcu_cortexm3

# Logs de la app web AMD64
docker compose logs -f gxapp_amd64
```

## Acceso web

- App AMD64:
	- `http://localhost:8081/wwtra_ciudad`
	- `http://localhost:8081/Wep_login.aspx`
- App ARM64:
	- `http://localhost:8082/wwtra_ciudad`
	- `http://localhost:8082/Wep_login.aspx`

## Estructura

```
.
├── app/                    # Aplicación web GeneXus
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── publish-amd64/
│   └── publish-arm64/
├── mcu/                    # Microcontrolador STM32F103
│   ├── Dockerfile          # Multi-stage: compila + ejecuta en QEMU
│   ├── build.sh            # Script de compilación
│   └── firmware/
│       ├── main.c          # Firmware Cortex-M3
│       └── stm32f103.ld    # Linker script
├── docker-compose.yml      # Orquestación de servicios
└── README.md
```

## Detalles Técnicos

### mcu_cortexm3
- **Procesador**: ARM Cortex-M3 (STM32F103)
- **Emulador**: QEMU (`qemu-system-arm` + placa Versatile PB)
- **Periféricos**: GPIO, SysTick Timer, UART serial
- **Firmware**: Parpadeo de LED (PA5) cada 500ms
- **Compilación**: `arm-none-eabi-gcc` (multi-stage Docker)

## Solución de errores comunes

- Si aparece `Cannot connect to SQL Server Browser`, verifica que el servicio apunte a `sqlserver:1433` y reinicia con:

```bash
docker compose down
docker compose up -d --build
```

- Si aparece `Error unprotecting the session cookie`, borra cookies del navegador para `localhost:8081`/`localhost:8082` y vuelve a cargar.

