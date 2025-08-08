# 🎨 Verificación - Workflow de Bienvenida MQN

## 🚀 Pasos para Verificar

### 1. **Acceder a n8n**
```
URL: http://localhost:5679
Usuario: mediaqualitynet@gmail.com
Contraseña: Cadena_2000
```

### 2. **Importar el Workflow**
1. Ve a **Workflows** en n8n
2. Haz clic en **Import from file**
3. Selecciona el archivo: `workflows/bienvenida-mqn.json`
4. Haz clic en **Import**

### 3. **Activar el Workflow**
1. Abre el workflow **"MQN Bienvenida - Media Quality Net"**
2. Haz clic en **Activate** (botón de play)
3. Verifica que el webhook esté activo

### 4. **Probar el Sistema**

#### **Opción A: Usando el Script de Prueba**
```bash
cd mqn_stack
chmod +x scripts/test_bienvenida.sh
./scripts/test_bienvenida.sh
```

#### **Opción B: Usando cURL directamente**
```bash
# Probar mensaje de bienvenida
curl -X POST "http://localhost:5679/webhook/bienvenida-mqn" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9671262441",
    "message": "hola",
    "name": "Guillermo Test"
  }'

# Probar catálogo
curl -X POST "http://localhost:5679/webhook/bienvenida-mqn" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9671262441",
    "message": "catalogo",
    "name": "Guillermo Test"
  }'
```

#### **Opción C: Probar con WhatsApp Real**
Envía mensajes al número configurado con:
- `hola` - Mensaje de bienvenida
- `catalogo` - Ver productos disponibles
- `venta` - Información de ventas
- `ayuda` - Comandos disponibles
- `estado` - Estado del sistema

## 📋 Comandos Disponibles

| Comando | Función | Respuesta |
|---------|---------|-----------|
| `hola` | Mensaje de bienvenida | Presentación de MQN y servicios |
| `catalogo` | Ver productos | Lista de productos por categoría |
| `venta` | Información de ventas | Instrucciones para cotizar |
| `ayuda` | Comandos disponibles | Lista de comandos y servicios |
| `estado` | Estado del sistema | Status de servicios y workflows |

## 🎯 Respuestas del Sistema

### **Mensaje de Bienvenida**
```
🎨 ¡Bienvenido a Media Quality Net! 🎨

Hola [Usuario], soy tu asistente virtual de MQN.

Nuestros servicios:
• 🖼️ Impresión digital de alta calidad
• 👕 Serigrafía y sublimación
• 🎯 Productos personalizados
• 📱 Atención multicanal

Comandos disponibles:
• "catalogo" - Ver productos
• "venta" - Crear cotización
• "precios" - Consultar tarifas
• "ayuda" - Más información
• "estado" - Estado del sistema

Contacto:
📞 WhatsApp: [número]
🏢 Horario: Lunes a Viernes 9:00-18:00

¿En qué puedo ayudarte hoy? 😊
```

### **Catálogo de Productos**
```
📋 Catálogo Media Quality Net 📋

Productos disponibles:

👕 Ropa:
• Playeras personalizadas
• Sudaderas con diseño
• Gorras bordadas

🏠 Hogar:
• Tazas sublimadas
• Cojines personalizados
• Manteles impresos

📄 Papelería:
• Posters de alta calidad
• Tarjetas de presentación
• Folletos promocionales

🎨 Técnicas:
• Impresión digital
• Serigrafía
• Sublimación
• Bordado

Para cotizar: Envía "venta" + tu número de teléfono

¿Qué producto te interesa?
```

## 🔍 Verificar Logs

### **En n8n:**
1. Ve al workflow **"MQN Bienvenida"**
2. Haz clic en **Executions**
3. Revisa las ejecuciones recientes
4. Verifica que no haya errores

### **En la Base de Datos:**
```sql
-- Ver conversaciones registradas
SELECT * FROM conversaciones 
ORDER BY timestamp DESC 
LIMIT 10;

-- Ver logs del sistema
SELECT * FROM logs_sistema 
WHERE evento = 'bienvenida_mqn'
ORDER BY timestamp DESC 
LIMIT 10;
```

## 🛠️ Troubleshooting

### **Si el webhook no responde:**
1. Verifica que n8n esté corriendo en puerto 5679
2. Confirma que el workflow esté activado
3. Revisa los logs de n8n

### **Si hay errores de base de datos:**
1. Verifica que PostgreSQL esté corriendo
2. Confirma la conexión en la configuración
3. Revisa las credenciales de la base de datos

### **Si WhatsApp no funciona:**
1. Verifica que Evolution API esté corriendo
2. Confirma la configuración del webhook
3. Revisa los logs de Evolution API

## ✅ Checklist de Verificación

- [ ] n8n accesible en http://localhost:5679
- [ ] Workflow importado correctamente
- [ ] Workflow activado
- [ ] Webhook respondiendo a peticiones
- [ ] Base de datos conectada
- [ ] Logs registrando correctamente
- [ ] WhatsApp configurado (opcional)

## 🎉 ¡Listo!

Una vez que hayas verificado todos los puntos, el sistema de bienvenida de **Media Quality Net** estará funcionando correctamente y podrás ver en tiempo real cómo responde a los diferentes comandos.

**Próximo paso:** Implementar los workflows específicos para tu negocio según tus necesidades de Media Quality Net.
