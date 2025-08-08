# 🚀 MQN - Sistema de Gestión Empresarial con IA

## 📋 Descripción

MQN es un sistema integral de gestión empresarial asistido por IA que permite automatizar ventas, atención a clientes, logística, administración y reportes de forma completamente automatizada, verbalizable, trazable y replicable.

## 🎯 Características Principales

- **🤖 IA como clon operativo**: Sistema que actúa como extensión del usuario
- **📱 Integración WhatsApp**: Usando Evolution API para comunicación multicanal
- **🖼️ Catalogador Visual**: Análisis automático de imágenes para crear catálogos
- **💰 Gestión de Ventas**: Creación automática de notas de venta
- **👥 Atención a Clientes**: Chatbot inteligente para WhatsApp
- **📊 Reportes Automáticos**: Generación de informes en tiempo real
- **🔄 Mejora Continua**: Sistema de actualización automática

## 🏗️ Arquitectura

### Servicios Incluidos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **n8n** | 5678 | Automatización de workflows |
| **Evolution API** | 8080 | Integración WhatsApp |
| **PostgreSQL** | 5433 | Base de datos principal |
| **Redis** | 6380 | Cache y broker |
| **Whisper** | 9000 | Reconocimiento de voz |
| **Tesseract** | 8081 | OCR para imágenes |

### Módulos Principales

1. **Catalogador Visual** (`catalogador-visual.json`)
   - Procesa imágenes de productos
   - Extrae información con OCR
   - Clasifica materiales y técnicas
   - Calcula precios automáticamente

2. **WhatsApp Handler** (`whatsapp-handler.json`)
   - Maneja mensajes entrantes
   - Detecta comandos automáticamente
   - Responde con información relevante
   - Registra conversaciones

## 🚀 Instalación

### Requisitos Previos

- Docker
- Docker Compose
- 4GB RAM mínimo
- 10GB espacio libre

### Instalación Rápida

```bash
# Clonar o navegar al directorio
cd mqn_stack

# Ejecutar inicialización
./init_mqn.sh
```

### Instalación Manual

```bash
# 1. Iniciar servicios
docker-compose up -d

# 2. Esperar que los servicios estén listos (30 segundos)
sleep 30

# 3. Crear instancia de Evolution API
curl -X POST "http://localhost:8080/instance/create" \
  -H "apikey: mqn_evolution_key_2024" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "mqn-instance",
    "token": "mqn_token_2024",
    "qrcode": true,
    "number": ""
  }'
```

## 🔧 Configuración

### Acceso a Servicios

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **n8n** | http://localhost:5679 | mediaqualitynet@gmail.com / Cadena |
| **Evolution API** | http://localhost:8080 | API Key: mqn_evolution_key_2024 |

### Configuración de WhatsApp

1. Acceder a Evolution API: http://localhost:8080
2. Escanear QR code con WhatsApp
3. Verificar conexión en logs

### Configuración de n8n

1. Acceder a n8n: http://localhost:5678
2. Importar workflows desde `workflows/`
3. Activar workflows necesarios

## 📱 Uso

### Comandos de WhatsApp

- `venta`: Crear nueva venta
- `catalogo`: Ver productos disponibles
- `cliente`: Información de cliente
- `ayuda`: Ver todos los comandos

### Catalogador Visual

1. Colocar imágenes en carpeta `fotos/`
2. El sistema procesará automáticamente
3. Los productos se crearán en la base de datos

### Workflows de n8n

Los workflows principales están en `workflows/`:

- `whatsapp-handler.json`: Manejo de mensajes WhatsApp
- `catalogador-visual.json`: Procesamiento de imágenes

## 🗄️ Base de Datos

### Tablas Principales

- **clientes**: Información de clientes
- **productos**: Catálogo de productos
- **ventas**: Registro de ventas
- **conversaciones**: Historial de WhatsApp
- **tareas**: Gestión de tareas
- **logs_sistema**: Auditoría del sistema

### Consultas Útiles

```sql
-- Ver productos recientes
SELECT * FROM productos ORDER BY fecha_creacion DESC LIMIT 10;

-- Ver conversaciones de un cliente
SELECT * FROM conversaciones WHERE cliente_id = 1 ORDER BY timestamp DESC;

-- Estadísticas de ventas
SELECT COUNT(*) as total_ventas, SUM(total) as monto_total 
FROM ventas WHERE fecha_creacion >= CURRENT_DATE;
```

## 🔍 Monitoreo

### Logs

- **n8n**: `docker-compose logs n8n`
- **Evolution API**: `docker-compose logs evolution-api`
- **PostgreSQL**: `docker-compose logs postgres`

### Estado de Servicios

```bash
# Ver estado de todos los contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f
```

## 🛠️ Desarrollo

### Estructura del Proyecto

```
mqn_stack/
├── docker-compose.yml      # Configuración de servicios
├── config/
│   └── database.sql       # Esquema de base de datos
├── workflows/             # Workflows de n8n
│   ├── whatsapp-handler.json
│   └── catalogador-visual.json
├── fotos/                 # Imágenes para procesar
├── logs/                  # Logs del sistema
├── scripts/               # Scripts adicionales
└── docs/                  # Documentación
```

### Agregar Nuevos Workflows

1. Crear archivo JSON en `workflows/`
2. Importar en n8n
3. Activar el workflow
4. Documentar en `docs/`

### Personalización

- **Variables de entorno**: Modificar en `docker-compose.yml`
- **Base de datos**: Editar `config/database.sql`
- **Workflows**: Modificar archivos en `workflows/`

## 🚨 Troubleshooting

### Problemas Comunes

**Evolution API no conecta**
```bash
# Reiniciar servicio
docker-compose restart evolution-api

# Ver logs
docker-compose logs evolution-api
```

**n8n no carga workflows**
```bash
# Verificar permisos
chmod -R 755 workflows/

# Reiniciar n8n
docker-compose restart n8n
```

**Base de datos no inicia**
```bash
# Verificar archivo SQL
cat config/database.sql

# Reiniciar PostgreSQL
docker-compose restart postgres
```

### Logs de Error

```bash
# Ver todos los logs
docker-compose logs

# Ver logs específicos
docker-compose logs [servicio]

# Seguir logs en tiempo real
docker-compose logs -f [servicio]
```

## 📈 Mejoras Futuras

- [ ] Integración con IA más avanzada (GPT, Claude)
- [ ] Sistema de reconocimiento de voz
- [ ] Dashboard web para monitoreo
- [ ] Integración con más plataformas
- [ ] Sistema de backup automático
- [ ] Análisis predictivo de ventas

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama para feature
3. Commit cambios
4. Push a la rama
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver `LICENSE` para más detalles.

---

**MQN - Tu asistente empresarial inteligente** 🚀
