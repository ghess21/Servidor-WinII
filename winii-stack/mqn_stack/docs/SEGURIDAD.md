# 🔒 Guía de Seguridad - Media Quality Net

## 🛡️ **Medidas de Seguridad Implementadas**

### **Autenticación**
- ✅ Usuario: mediaqualitynet@gmail.com
- ✅ Contraseña: Cadena_2000
- ✅ API Key: mqn_api_key_2024

### **Backups Automáticos**
- ✅ Cada 6 horas automáticamente
- ✅ Notificación por WhatsApp
- ✅ Retención de 30 días

### **Monitoreo**
- ✅ Verificación de servicios cada 5 minutos
- ✅ Alertas por WhatsApp en caso de problemas
- ✅ Monitoreo de recursos del sistema

## 📋 **Comandos de Seguridad**

### **Backup Manual:**
```bash
./scripts/backup_manual.sh
```

### **Verificar Integridad:**
```bash
./scripts/verificar_integridad.sh
```

### **Recuperación Rápida:**
```bash
./scripts/recuperacion_rapida.sh
```

### **Monitoreo del Sistema:**
```bash
./scripts/monitor_sistema.sh
```

## 🚨 **Procedimientos de Emergencia**

### **Si n8n se pierde:**
1. Ejecutar: `./scripts/recuperacion_rapida.sh`
2. Si no funciona: `docker-compose down && docker-compose up -d`
3. Restaurar desde backup: `./scripts/restaurar_backup.sh backups/archivo.json`

### **Si se pierden datos:**
1. Verificar backups: `ls -la backups/`
2. Restaurar desde el backup más reciente
3. Verificar integridad: `./scripts/verificar_integridad.sh`

### **Si hay problemas de rendimiento:**
1. Monitorear recursos: `./scripts/monitor_sistema.sh`
2. Reiniciar servicios: `docker-compose restart`
3. Verificar logs: `docker-compose logs -f n8n`

## 📊 **Métricas de Seguridad**

- **Backups automáticos:** Cada 6 horas
- **Retención de backups:** 30 días
- **Verificación de integridad:** Cada 5 minutos
- **Alertas automáticas:** Por WhatsApp
- **Recuperación:** < 5 minutos

## 🔄 **Mantenimiento**

### **Diario:**
- Verificar que los backups se ejecuten correctamente
- Revisar alertas por WhatsApp
- Monitorear uso de recursos

### **Semanal:**
- Verificar integridad completa del sistema
- Revisar logs de seguridad
- Actualizar documentación si es necesario

### **Mensual:**
- Revisar políticas de seguridad
- Actualizar contraseñas si es necesario
- Verificar que todos los scripts funcionen

---

**Última actualización:** 2025-08-08
**Responsable:** Sistema MQN
