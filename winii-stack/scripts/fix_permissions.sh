#!/bin/bash

echo "🔐 Activando permisos de ejecución en scripts esenciales..."

for script in assistant.sh setup_services.sh validate.sh render_compose.sh setup_interactivo.sh install_stack.sh create_env.sh; do
  if [[ -f "scripts/$script" ]]; then
    chmod +x "scripts/$script" && echo "✅ $script habilitado"
  else
    echo "⚠️ $script no encontrado"
  fi
done
