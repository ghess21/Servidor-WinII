# Validación de permisos de ejecución en scripts esenciales
echo "🔍 Verificando permisos en scripts críticos..."

for script in assistant.sh setup_services.sh validate.sh render_compose.sh setup_interactivo.sh install_stack.sh create_env.sh; do
  if [[ -f "scripts/$script" ]]; then
    if [[ -x "scripts/$script" ]]; then
      echo "✅ $script tiene permisos de ejecución"
    else
      echo "❌ $script NO tiene permisos de ejecución"
    fi
  else
    echo "⚠️ $script no está presente en la carpeta scripts"
  fi
done
