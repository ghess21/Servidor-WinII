#!/bin/bash
echo "📁 Importando workflows de Media Quality Net..."

if ! curl -s http://localhost:5679 > /dev/null; then
    echo "❌ Error: n8n no está funcionando"
    exit 1
fi

echo "✅ n8n funcionando"

importados=0
errores=0

for archivo in workflows/*.json; do
    if [ -f "$archivo" ]; then
        nombre=$(basename "$archivo" .json)
        echo "📁 Importando: $nombre"
        
        response=$(curl -s -X POST "http://localhost:5679/api/v1/workflows" \
            -H "Content-Type: application/json" \
            -H "X-N8N-API-KEY: mqn_api_key_2024" \
            -d @"$archivo")
        
        if echo "$response" | grep -q "id"; then
            echo "✅ Workflow importado: $nombre"
            ((importados++))
        else
            echo "❌ Error importando: $nombre"
            ((errores++))
        fi
    fi
done

echo ""
echo "📊 Resumen: $importados importados, $errores errores"
echo "🎉 ¡Workflows importados!"
