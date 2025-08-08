#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       INIT - MQN Bootstrap CLI        ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG="$WORKDIR/logs/init_mqn.log"
STATE="$WORKDIR/logs/mqn.state.json"

mkdir -p "$(dirname "$LOG")"
echo "[MQN INIT] Inicio - $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG"

##############################
# 🧪 Verificación de requisitos
##############################
echo "[MQN INIT] Verificando requisitos..." | tee -a "$LOG"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "[MQN INIT] ❌ Docker no está instalado" | tee -a "$LOG"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "[MQN INIT] ❌ Docker Compose no está instalado" | tee -a "$LOG"
    exit 1
fi

echo "[MQN INIT] ✅ Requisitos verificados" | tee -a "$LOG"

##############################
# 🗄️ Preparar base de datos
##############################
echo "[MQN INIT] Preparando base de datos..." | tee -a "$LOG"

# Crear directorio de config si no existe
mkdir -p "$WORKDIR/config"

# Verificar que existe el archivo de base de datos
if [ ! -f "$WORKDIR/config/database.sql" ]; then
    echo "[MQN INIT] ❌ Archivo database.sql no encontrado" | tee -a "$LOG"
    exit 1
fi

echo "[MQN INIT] ✅ Base de datos preparada" | tee -a "$LOG"

##############################
# 🐳 Iniciar servicios
##############################
echo "[MQN INIT] Iniciando servicios..." | tee -a "$LOG"

# Parar servicios existentes si los hay
docker-compose down 2>/dev/null | tee -a "$LOG"

# Iniciar servicios
docker-compose up -d | tee -a "$LOG"

# Esperar a que los servicios estén listos
echo "[MQN INIT] Esperando que los servicios estén listos..." | tee -a "$LOG"
sleep 30

##############################
# 🔍 Verificar servicios
##############################
echo "[MQN INIT] Verificando servicios..." | tee -a "$LOG"

# Verificar PostgreSQL
if docker-compose ps postgres | grep -q "Up"; then
    echo "[MQN INIT] ✅ PostgreSQL funcionando" | tee -a "$LOG"
else
    echo "[MQN INIT] ❌ PostgreSQL no está funcionando" | tee -a "$LOG"
fi

# Verificar Redis
if docker-compose ps redis | grep -q "Up"; then
    echo "[MQN INIT] ✅ Redis funcionando" | tee -a "$LOG"
else
    echo "[MQN INIT] ❌ Redis no está funcionando" | tee -a "$LOG"
fi

# Verificar Evolution API
if docker-compose ps evolution-api | grep -q "Up"; then
    echo "[MQN INIT] ✅ Evolution API funcionando" | tee -a "$LOG"
else
    echo "[MQN INIT] ❌ Evolution API no está funcionando" | tee -a "$LOG"
fi

# Verificar n8n
if docker-compose ps n8n | grep -q "Up"; then
    echo "[MQN INIT] ✅ n8n funcionando" | tee -a "$LOG"
else
    echo "[MQN INIT] ❌ n8n no está funcionando" | tee -a "$LOG"
fi

##############################
# 📊 Estado final
##############################
echo "[MQN INIT] Estado de contenedores:" | tee -a "$LOG"
docker-compose ps | tee -a "$LOG"

echo "[MQN INIT] URLs de acceso:" | tee -a "$LOG"
echo "  - n8n: http://localhost:5678 (admin/mqn_admin_2024)" | tee -a "$LOG"
echo "  - Evolution API: http://localhost:8080" | tee -a "$LOG"
echo "  - PostgreSQL: localhost:5432" | tee -a "$LOG"
echo "  - Redis: localhost:6379" | tee -a "$LOG"

##############################
# 🧠 Configuración inicial
##############################
echo "[MQN INIT] Configurando Evolution API..." | tee -a "$LOG"

# Crear instancia de Evolution API
sleep 10
curl -X POST "http://localhost:8080/instance/create" \
  -H "apikey: mqn_evolution_key_2024" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "mqn-instance",
    "token": "mqn_token_2024",
    "qrcode": true,
    "number": ""
  }' | tee -a "$LOG"

echo "[MQN INIT] ✅ Instancia de Evolution API creada" | tee -a "$LOG"

##############################
# 📝 Registro de estado
##############################
echo "{ \"fecha\": \"$(date '+%Y-%m-%d %H:%M:%S')\", \"fase\": \"init_mqn.sh\", \"resultado\": \"completo\" }" > "$STATE"

echo "[MQN INIT] ✅ Inicialización completada exitosamente" | tee -a "$LOG"
echo "[MQN INIT] 🎯 MQN está listo para usar!" | tee -a "$LOG"
