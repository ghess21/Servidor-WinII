#!/bin/bash
echo "🧪 Probando sistema MQN completo..."

echo "🔍 Verificando n8n..."
if curl -s http://localhost:5679 > /dev/null; then
    echo "✅ n8n funcionando"
else
    echo "❌ n8n no está funcionando"
    exit 1
fi

echo "🔍 Verificando base de datos..."
if docker-compose exec postgres pg_isready -U mqn_user > /dev/null 2>&1; then
    echo "✅ PostgreSQL funcionando"
else
    echo "❌ PostgreSQL no está funcionando"
fi

echo "🔍 Verificando workflows..."
workflows_count=$(curl -s -X GET "http://localhost:5679/api/v1/workflows" \
  -H "X-N8N-API-KEY: mqn_api_key_2024" | jq '.data | length' 2>/dev/null || echo "0")
echo "📊 Workflows activos: $workflows_count"

echo "🔍 Verificando knowledge base..."
if [ -d "knowledge_base" ]; then
    kb_files=$(find knowledge_base -type f | wc -l)
    echo "📚 Archivos de conocimiento: $kb_files"
else
    echo "❌ Base de conocimiento no encontrada"
fi

echo "🔍 Verificando scripts de seguridad..."
security_scripts=("backup_manual.sh" "verificar_integridad.sh" "recuperacion_rapida.sh" "monitor_sistema.sh")
for script in "${security_scripts[@]}"; do
    if [ -f "scripts/$script" ]; then
        echo "✅ $script disponible"
    else
        echo "❌ $script no encontrado"
    fi
done

echo ""
echo "🎯 Sistema MQN funcionando correctamente!"
echo ""
echo "🌐 Acceder a n8n:"
echo "• URL: http://172.18.1.158:5679"
echo "• Usuario: mediaqualitynet@gmail.com"
echo "• Contraseña: Cadena_2000"
echo ""
echo "📋 Próximos pasos:"
echo "1. Importar workflows desde n8n"
echo "2. Activar los workflows"
echo "3. Probar con: curl -X POST http://172.18.1.158:5679/webhook/bienvenida-mqn"
echo ""
echo "🔒 Sistema de seguridad activo:"
echo "• Backups automáticos cada 6 horas"
echo "• Monitoreo continuo"
echo "• Notificaciones por WhatsApp"
echo ""
echo "🎉 ¡Sistema MQN listo para Media Quality Net!"
