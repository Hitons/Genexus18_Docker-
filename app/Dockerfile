FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app
EXPOSE 80

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    libgdiplus \
    libc6-dev \
    tzdata \
    dos2unix \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/microsoft-prod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 \
    && rm -rf /var/lib/apt/lists/*

# Script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Asegurar que el script use finales de línea LF (evita errores por CRLF en Windows)
RUN dos2unix /entrypoint.sh || true

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dotnet", "bin/GxNetCoreStartup.dll"]

