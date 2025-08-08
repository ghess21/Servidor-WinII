#!/bin/bash
echo "🔎 Validando módulo postgres_api..."

# Validar puertos comunes
case "postgres_api" in
  "n8n") PORT=5678 ;;
  "postgres_api") PORT=3001 ;;
  "model_runner") PORT=8501 ;;
esac
echo "✅ Puerto previsto: $PORT"

# Variables de entorno (simplificadas)
echo "📦 Variables de entorno:"
grep "ENV" "postgres_api/Dockerfile" || echo "(ninguna definida)"

# Validación de volumen / rutas clave
case "postgres_api" in
  "model_runner")
    [ -d "postgres_api/model" ] && echo "📁 Modelo presente" || echo "⚠️ Faltante: /model"
    ;;
esac
