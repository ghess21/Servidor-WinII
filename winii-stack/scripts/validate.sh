#!/bin/bash
source scripts/env.sh

echo "[VALIDATE] Verificando puertos, variables, semántica, dependencias y estructura..."

########################
# 🧪 Variables críticas
########################
echo "🔍 Validando variables obligatorias..."
REQUIRED_VARS=("REDIS_PORT" "POSTGRES_PORT" "N8N_PORT" "ENABLE_REDIS" "ENABLE_POSTGRES" "ENABLE_N8N")
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "❌ Variable no definida: $var"
    exit 1
  fi
done

######################
# 🔐 Validación semántica
######################
echo ""
echo "🧠 Validando semántica..."

# Valores booleanos esperados
BOOL_VARS=("ENABLE_REDIS" "ENABLE_POSTGRES" "ENABLE_N8N")
for var in "${BOOL_VARS[@]}"; do
  value="${!var}"
  if [[ "$value" != "true" && "$value" != "false" ]]; then
    echo "❌ $var debe ser 'true' o 'false'. Valor actual: '$value'"
    exit 1
  fi
done

# Puertos válidos entre 1024 y 65535
PORT_VARS=("REDIS_PORT" "POSTGRES_PORT" "N8N_PORT")
for var in "${PORT_VARS[@]}"; do
  value="${!var}"
  if ! [[ "$value" =~ ^[0-9]{4,5}$ ]] || (( value < 1024 || value > 65535 )); then
    echo "❌ $var fuera de rango válido (1024–65535). Valor: '$value'"
    exit 1
  fi
done

##################
# 🔌 Validación de puertos
##################
check_port() {
  if lsof -i :$1 >/dev/null; then
    echo "⚠️ Puerto $1 en uso"
    return 1
  else
    echo "✅ Puerto $1 disponible"
    return 0
  fi
}

[[ "$ENABLE_REDIS" == "true" ]] && check_port "$REDIS_PORT"
[[ "$ENABLE_POSTGRES" == "true" ]] && check_port "$POSTGRES_PORT"
[[ "$ENABLE_N8N" == "true" ]] && check_port "$N8N_PORT"

##################
# 🔧 Dependencias mínimas
##################
echo ""
echo "🔧 Verificando herramientas requeridas..."
REQUIRED_CMDS=("docker" "gomplate")
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v $cmd >/dev/null; then
    echo "❌ Falta dependencia: $cmd"
    exit 1
  fi
done

###########################################
# 📁 Validación de archivos y estructura
###########################################
echo ""
echo "📁 Validando estructura de carpetas y archivos..."

REQUIRED_FILES=("scripts/env.sh" "scripts/render_compose.sh" "templates/docker-compose.yml.tpl" ".env")
REQUIRED_DIRS=("scripts" "templates" "logs")

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ Archivo faltante: $file"
    exit 1
  else
    echo "✅ Archivo presente: $file"
  fi
done

for dir in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "❌ Carpeta faltante: $dir"
    exit 1
  else
    echo "✅ Carpeta presente: $dir"
  fi
done

####################################
# 🧼 Modo --clean (limpieza y reset)
####################################
if [[ "$1" == "--clean" ]]; then
  echo ""
  echo "[CLEAN] Ejecutando limpieza..."

  CLEAN_PATHS=("logs/*" "*.bak" "*.lock" "docker-compose.yml")
  for path in "${CLEAN_PATHS[@]}"; do
    if ls $path >/dev/null 2>&1; then
      echo "🧹 Eliminando: $path"
      rm -rf $path
    fi
  done

  if [[ -f ".env.tpl" ]]; then
    echo "📦 Regenerando .env desde .env.tpl..."
    cp .env.tpl .env
    echo "✅ .env listo"
  fi

  echo "[CLEAN] Proceso finalizado ✅"
  exit 0
fi

##################
# 🎉 Resultado final
##################
echo ""
echo "[VALIDATE] Todo OK ✅"
