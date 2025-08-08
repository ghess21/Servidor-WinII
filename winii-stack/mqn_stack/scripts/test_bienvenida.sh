#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       TEST - MQN Bienvenida          ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🎨 Probando Workflow de Bienvenida MQN 🎨"
echo "=========================================="

# URL del webhook
WEBHOOK_URL="http://localhost:5679/webhook/bienvenida-mqn"

# Función para probar diferentes comandos
test_command() {
    local command=$1
    local description=$2
    
    echo ""
    echo "🧪 Probando: $description"
    echo "Comando: $command"
    
    # Enviar petición al webhook
    response=$(curl -s -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"phone\": \"9671262441\",
            \"message\": \"$command\",
            \"name\": \"Guillermo Test\"
        }")
    
    if [ $? -eq 0 ]; then
        echo "✅ Respuesta recibida"
        echo "📝 Respuesta: $response"
    else
        echo "❌ Error al enviar petición"
    fi
    
    echo "----------------------------------------"
}

# Probar diferentes comandos
echo "🚀 Iniciando pruebas..."

test_command "hola" "Mensaje de bienvenida"
test_command "catalogo" "Solicitud de catálogo"
test_command "venta" "Información de ventas"
test_command "ayuda" "Mensaje de ayuda"
test_command "estado" "Estado del sistema"

echo ""
echo "🎯 Pruebas completadas!"
echo ""
echo "📋 Para verificar en n8n:"
echo "1. Accede a http://localhost:5679"
echo "2. Usuario: mediaqualitynet@gmail.com"
echo "3. Contraseña: Cadena_2000"
echo "4. Ve a Workflows > MQN Bienvenida"
echo "5. Revisa los logs de ejecución"
echo ""
echo "📱 Para probar con WhatsApp real:"
echo "Envía un mensaje al número configurado con:"
echo "• 'hola' - Bienvenida"
echo "• 'catalogo' - Ver productos"
echo "• 'venta' - Información de ventas"
echo "• 'ayuda' - Comandos disponibles"
echo "• 'estado' - Estado del sistema"
