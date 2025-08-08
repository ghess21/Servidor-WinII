#!/bin/bash

# 📁 Ruta base
BASE_DIR="mcp_stack"

# 🧾 Auditoría
echo "$(date '+%Y-%m-%d %H:%M:%S') [SETUP] Ejecutando setup_services.sh" >> logs/audit.log

# 🧠 Declaración de servicios
declare -A services=(
  ["n8n"]="5678"
  ["model_runner"]="8501"
  ["postgres_api"]="3001"
)

for service in "${!services[@]}"; do
  TARGET="$BASE_DIR/$service"
  PORT="${services[$service]}"

  echo "🔧 Configurando: $service → Carpeta: $TARGET | Puerto: $PORT"

  mkdir -p "$TARGET"

  # 📦 Dockerfile básico
  cat > "$TARGET/Dockerfile" <<EOF
FROM alpine
CMD echo "Servicio $service corriendo en puerto $PORT"
EOF

  # 🔍 Script de validación
  cat > "$TARGET/validate.sh" <<EOF
#!/bin/bash
echo "🔍 Validando módulo: $service"
# Aquí podrías incluir verificación de variables, puertos, etc.
EOF
  chmod +x "$TARGET/validate.sh"

  # 📘 Documentación README
  cat > "$TARGET/README.md" <<EOF
# Servicio: $service

🔧 Puerto por defecto: $PORT  
🧾 Este módulo fue generado automáticamente por setup_services.sh

## Archivos incluidos
- Dockerfile
- validate.sh
- README.md

Puedes personalizar este módulo en: $TARGET/
EOF

  echo "✅ $service generado correctamente"
done
