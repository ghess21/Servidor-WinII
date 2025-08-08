#!/bin/bash
echo "🔎 Validando módulo n8n..."

# Validar puertos comunes
case "n8n" in
  "n8n") PORT=5678 ;;
  "postgres_api") PORT=3001 ;;
  "model_runner") PORT=8501 ;;
esac
echo "✅ Puerto previsto: $PORT"

# Variables de entorno (simplificadas)
echo "📦 Variables de entorno:"
grep "ENV" "n8n/Dockerfile" || echo "(ninguna definida)"

# Validación de volumen / rutas clave
case "n8n" in
  "model_runner")
    [ -d "n8n/model" ] && echo "📁 Modelo presente" || echo "⚠️ Faltante: /model"
    ;;
esac
