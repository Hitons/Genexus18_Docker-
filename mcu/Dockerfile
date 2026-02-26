# Simple: Solo ejecutar firmware precompilado en QEMU
FROM ubuntu:20.04

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends qemu-system-arm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY firmware/firmware.elf /firmware.elf

CMD ["qemu-system-arm", \
     "-M", "lm3s6965evb", \
     "-nographic", \
     "-serial", "mon:stdio", \
     "-kernel", "/firmware.elf"]
