#!/bin/bash
set -e

# Valores por defecto; permitir sobreescritura vía variables de entorno
SQL_SERVER="${SQL_SERVER:-sqlserver,1433}"
SQL_USER="${SQL_USER:-sa}"
SQL_PASS="${SQL_PASS:-GeneXus2024!}"
DB_NAME="${DB_NAME:-GeneXusDB}"
WAIT_FOR_SQL_TIMEOUT="${WAIT_FOR_SQL_TIMEOUT:-180}"

if [ ! -x "/opt/mssql-tools18/bin/sqlcmd" ]; then
  echo "Error: sqlcmd no está instalado en la imagen (/opt/mssql-tools18/bin/sqlcmd)." >&2
  exit 1
fi

echo "Esperando a SQL Server..."

elapsed=0

until /opt/mssql-tools18/bin/sqlcmd \
  -S "$SQL_SERVER" \
  -C \
  -U "$SQL_USER" \
  -P "$SQL_PASS" \
  -Q "SELECT 1" > /dev/null 2>&1
do
  if [ "$elapsed" -ge "$WAIT_FOR_SQL_TIMEOUT" ]; then
    echo "Error: no se pudo conectar a SQL Server en $WAIT_FOR_SQL_TIMEOUT segundos ($SQL_SERVER)." >&2
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

echo "SQL Server disponible"

echo "Creando base de datos si no existe..."
/opt/mssql-tools18/bin/sqlcmd \
  -S "$SQL_SERVER" \
  -C \
  -U "$SQL_USER" \
  -P "$SQL_PASS" \
  -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name='$DB_NAME') CREATE DATABASE [$DB_NAME]"

echo "Verificando si la reorganización ya fue ejecutada..."

# Limpiar retorno de sqlcmd para evitar CR/LF y espacios
REORG_DONE=$(/opt/mssql-tools18/bin/sqlcmd \
  -S "$SQL_SERVER" \
  -C \
  -U "$SQL_USER" \
  -P "$SQL_PASS" \
  -d "$DB_NAME" \
  -Q "SET NOCOUNT ON;
      IF OBJECT_ID('GX_REORG_CONTROL') IS NULL
      BEGIN
        CREATE TABLE GX_REORG_CONTROL (DONE BIT);
        INSERT INTO GX_REORG_CONTROL VALUES (0);
      END;
      SELECT DONE FROM GX_REORG_CONTROL;" \
  -h -1 -W | tr -d '\r' | xargs)

if [ "$REORG_DONE" = "0" ]; then
  echo "Ejecutando reorganización GeneXus..."
  if ! dotnet Reor.dll -nogui -noverifydatabaseschema -force; then
    echo "Error: la reorganización falló." >&2
    exit 1
  fi

  echo "Marcando reorganización como completada..."
  /opt/mssql-tools18/bin/sqlcmd \
    -S "$SQL_SERVER" \
    -C \
    -U "$SQL_USER" \
    -P "$SQL_PASS" \
    -d "$DB_NAME" \
    -Q "UPDATE GX_REORG_CONTROL SET DONE = 1;"
else
  echo "ℹReorganización ya ejecutada previamente"
fi

echo "Iniciando aplicación GeneXus..."
if [ "$#" -eq 0 ]; then
  set -- dotnet bin/GxNetCoreStartup.dll
fi

exec "$@"
