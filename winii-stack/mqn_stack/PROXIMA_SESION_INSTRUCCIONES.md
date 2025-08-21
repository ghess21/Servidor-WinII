# 🎯 INSTRUCCIONES PARA PRÓXIMA SESIÓN

## 📅 **FECHA:** Próxima sesión después de 2025-01-15
## 👤 **USUARIO:** ghess21 (MacBookPro con WSL2)
## 📂 **DIRECTORIO:** /home/ghess21/Servidor-WinII/winii-stack

---

## 🚀 **PRIMER PASO: VERIFICAR SERVICIOS**

```bash
# 1. Navegar al directorio
cd /home/ghess21/Servidor-WinII/winii-stack

# 2. Verificar servicios Docker
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 3. Si servicios están DOWN, reiniciar:
./init.sh

# 4. Verificar n8n específicamente
curl -s -o /dev/null -w "%{http_code}" http://localhost:5678
# Debe retornar: 200
```

---

## 🎯 **TAREA PRINCIPAL: IMPORTAR WORKFLOW BIENVENIDA**

### **Problema identificado en sesión anterior:**
- ❌ **Error:** "propertyValues[itemName] is not iterable"
- ❌ **Resultado:** Workflow no aparece en lista de n8n
- ✅ **Solución preparada:** Archivos simplificados creados

### **Archivos disponibles para importar:**
1. **`mqn_stack/workflows/bienvenida-simple.json`** ⭐ RECOMENDADO
2. **`mqn_stack/workflows/bienvenida-mqn-v2.json`** (backup)

### **Pasos para importar:**

#### **Opción A: Importar archivo simple (RECOMENDADO)**
1. Abrir n8n: http://localhost:5678
2. Clic en "Import from file"
3. Seleccionar: `mqn_stack/workflows/bienvenida-simple.json`
4. Importar y activar

#### **Opción B: Crear manualmente (SI FALLA IMPORTACIÓN)**
1. **Nuevo workflow** en n8n
2. **Agregar Webhook:**
   - Type: Webhook
   - Method: POST
   - Path: `bienvenida-mqn`
3. **Agregar Code node:**
   ```javascript
   const input = $input.first().json;
   const userName = input.name || 'Usuario';
   const phoneNumber = input.phone || 'sistema';
   
   const message = `🎨 ¡Bienvenido a Media Quality Net! 🎨
   
   Hola ${userName}!
   
   Somos especialistas en:
   • Impresión digital
   • Serigrafía  
   • Sublimación
   
   Contacto: ${phoneNumber}
   
   ¿En qué podemos ayudarte?`;
   
   return { message, phoneNumber, userName };
   ```
4. **Conectar:** Webhook → Code
5. **Guardar y activar**

---

## 🧪 **PROBAR WORKFLOW UNA VEZ IMPORTADO**

```bash
# Comando para probar webhook
curl -X POST "http://localhost:5678/webhook/bienvenida-mqn" \
  -H "Content-Type: application/json" \
  -d '{"phone": "9671262441", "message": "hola", "name": "Test Usuario"}'

# Verificar logs de n8n
docker logs winii-stack-n8n-1 --tail 10
```

### **Resultado esperado:**
- ✅ Respuesta JSON con mensaje de bienvenida
- ✅ Logs sin errores en n8n
- ✅ Webhook registrado correctamente

---

## 📋 **CHECKLIST DE VERIFICACIÓN**

### **Servicios:**
- [ ] Docker containers corriendo
- [ ] n8n accesible en puerto 5678
- [ ] PostgreSQL activo en puerto 5432
- [ ] Redis activo en puerto 6379

### **Workflow:**
- [ ] Archivo importado exitosamente
- [ ] Workflow aparece en lista de n8n
- [ ] Workflow marcado como "Active"
- [ ] Webhook URL visible en nodo
- [ ] Prueba con curl exitosa

### **Si todo funciona:**
- [ ] Actualizar `CONTEXTO_TOTAL_COMPLETO.md`
- [ ] Marcar workflow como ✅ COMPLETADO
- [ ] Continuar con próximo workflow o Evolution API

---

## 🆘 **SI HAY PROBLEMAS**

### **Servicios no inician:**
```bash
cd /home/ghess21/Servidor-WinII/winii-stack
./init.sh
# O manualmente:
docker-compose up -d
```

### **n8n no responde:**
```bash
docker logs winii-stack-n8n-1 --tail 20
docker restart winii-stack-n8n-1
```

### **Importación sigue fallando:**
- Usar Opción B (crear manualmente)
- Es más confiable y educativo

---

## 📚 **CONTEXTO DISPONIBLE**

- **Archivo principal:** `mqn_stack/CONTEXTO_TOTAL_COMPLETO.md`
- **Estado del proyecto:** 70% completado
- **Servicios base:** ✅ Funcionando
- **Documentación:** ✅ Completa

---

## 🎯 **OBJETIVO DE LA PRÓXIMA SESIÓN**

**COMPLETAR:** Workflow de bienvenida funcionando
**RESULTADO:** Webhook operativo para recibir mensajes
**SIGUIENTE:** Configurar Evolution API o workflows de ventas

---

**💡 RECORDATORIO:** Leer `CONTEXTO_TOTAL_COMPLETO.md` al inicio de la sesión para contexto completo.
