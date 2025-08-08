#!/bin/bash
echo "🔎 Validando módulo model_runner..."

# Validar puertos comunes
case "model_runner" in
  "n8n") PORT=5678 ;;
  "postgres_api") PORT=3001 ;;
  "model_runner") PORT=8501 ;;
esac
echo "✅ Puerto previsto: $PORT"

# Variables de entorno (simplificadas)
echo "📦 Variables de entorno:"
grep "ENV" "model_runner/Dockerfile" || echo "(ninguna definida)"

# Validación de volumen / rutas clave
case "model_runner" in
  "model_runner")
    [ -d "model_runner/model" ] && echo "📁 Modelo presente" || echo "⚠️ Faltante: /model"
    ;;
esac
