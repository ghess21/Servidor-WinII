# 📚 Guía de Uso - Base de Conocimiento MQN

## 🎯 **Propósito**

Esta base de conocimiento es el cerebro del sistema **go_to_future_MQN**. Aquí se almacena toda la información que el sistema de IA necesita para:
- ✅ Responder preguntas de clientes
- ✅ Generar cotizaciones automáticas
- ✅ Crear catálogos dinámicos
- ✅ Tomar decisiones basadas en datos
- ✅ Procesar imágenes y documentos

## 📁 **Estructura de Carpetas**

### 🏢 **empresa/**
```
empresa/
├── perfil/           # Información de la empresa
├── servicios/        # Catálogo de servicios
├── contacto/         # Información de contacto
└── historial/        # Historia y logros
```

### 🛍️ **productos/**
```
productos/
├── catalogo/         # Catálogo completo
├── precios/          # Lista de precios
├── tecnicas/         # Técnicas de impresión
└── especificaciones/ # Especificaciones técnicas
```

### 👥 **clientes/**
```
clientes/
├── base_datos/       # Base de datos de clientes
├── historial/        # Historial de pedidos
├── preferencias/     # Gustos y preferencias
└── proyectos/        # Proyectos por cliente
```

### 🎨 **disenos/**
```
disenos/
├── plantillas/       # Plantillas reutilizables
├── inspiracion/      # Ideas y referencias
└── estilos/          # Guías de estilo
```

### ⚙️ **procesos/**
```
procesos/
├── ventas/           # Proceso de ventas
├── produccion/       # Proceso de producción
├── calidad/          # Control de calidad
└── entrega/          # Proceso de entrega
```

### 📋 **reglas/**
```
reglas/
├── politicas/        # Políticas de la empresa
├── procedimientos/   # Procedimientos operativos
├── normas/           # Normas de calidad
└── decisiones/       # Criterios de decisión
```

### 📸 **archivos_fotograficos/**
```
archivos_fotograficos/
├── productos/        # Fotos de productos terminados
├── trabajos/         # Fotos de trabajos realizados
├── disenos/          # Fotos de diseños y mockups
├── logos/            # Logotipos y marcas
├── fondos/           # Fondos y texturas
└── clientes/         # Trabajos para clientes específicos
```

## 🔄 **Cómo Usar**

### **Para el Sistema de IA:**
1. Los workflows de n8n leen esta información
2. Se usa para generar respuestas automáticas
3. Sirve para tomar decisiones basadas en datos

### **Para el Catálogo Automático:**
1. Las fotos se procesan automáticamente
2. Se generan descripciones basadas en el contenido
3. Se calculan precios según las especificaciones

### **Para el Sistema de Ventas:**
1. Se usan las reglas de cotización
2. Se accede al historial de clientes
3. Se aplican las políticas de descuento

## 📝 **Cómo Agregar Información**

### **Información de Empresa:**
```bash
# Editar archivos en empresa/
nano knowledge_base/empresa/perfil/informacion_empresa.md
```

### **Precios y Tarifas:**
```bash
# Editar archivos en productos/precios/
nano knowledge_base/productos/precios/tarifas_actuales.md
```

### **Políticas y Reglas:**
```bash
# Editar archivos en reglas/
nano knowledge_base/reglas/politicas/politicas_ventas.md
```

### **Fotos y Documentos:**
```bash
# Usar el script de organización
./scripts/organizar_fotos.sh
```

## 🤖 **Integración con el Sistema**

### **Workflows de n8n:**
- **catalogador-visual.json** - Procesa fotos automáticamente
- **whatsapp-handler.json** - Usa información para responder
- **bienvenida-mqn.json** - Accede a datos de la empresa

### **Base de Datos:**
- Los datos se sincronizan con PostgreSQL
- Se mantienen logs de todas las interacciones
- Se generan reportes automáticos

### **IA del Sistema:**
- Lee archivos markdown para obtener información
- Procesa imágenes para clasificar productos
- Usa reglas para tomar decisiones

## 🔧 **Mantenimiento**

### **Actualización Automática:**
- Los workflows procesan nuevas fotos automáticamente
- Se actualiza la base de datos con nuevos clientes
- Se registran nuevos productos y precios

### **Actualización Manual:**
- Documentos de empresa
- Reglas y políticas
- Información de contacto

## 📊 **Monitoreo**

### **Verificar Estado:**
```bash
# Ver estructura de carpetas
find knowledge_base -type d | sort

# Ver archivos por categoría
ls -la knowledge_base/archivos_fotograficos/

# Ver estadísticas
./scripts/organizar_fotos.sh
```

### **Backup:**
```bash
# Hacer backup de la base de conocimiento
tar -czf knowledge_base_backup_$(date +%Y%m%d).tar.gz knowledge_base/
```

## 🎯 **Próximos Pasos**

1. **Organizar fotos existentes:** `./scripts/organizar_fotos.sh`
2. **Completar información de empresa:** Editar archivos en `empresa/`
3. **Definir reglas específicas:** Crear archivos en `reglas/`
4. **Actualizar precios:** Modificar archivos en `productos/precios/`
5. **Probar integración:** Verificar que los workflows usen esta información

---

**Creado:** 2025-08-08
**Versión:** v1.0.0
**Responsable:** Sistema MQN
