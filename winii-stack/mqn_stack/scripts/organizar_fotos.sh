#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       ORGANIZAR FOTOS MQN            ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "📸 Organizando archivos fotográficos de Media Quality Net..."
echo "=========================================================="

# Verificar si existe la carpeta fotos
if [ ! -d "fotos" ]; then
    echo "❌ No se encontró la carpeta 'fotos'"
    echo "📁 Creando estructura de carpetas..."
    mkdir -p fotos/{productos,trabajos,disenos,logos,fondos,clientes}
    echo "✅ Estructura creada"
    exit 0
fi

echo ""
echo "🔍 Analizando archivos en carpeta 'fotos'..."

# Contar archivos por tipo
echo ""
echo "📊 Estadísticas de archivos:"
echo "• Imágenes (jpg, png, gif): $(find fotos -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | wc -l)"
echo "• Documentos (pdf, doc): $(find fotos -type f \( -iname "*.pdf" -o -iname "*.doc" -o -iname "*.docx" \) | wc -l)"
echo "• Diseños (ai, eps, psd): $(find fotos -type f \( -iname "*.ai" -o -iname "*.eps" -o -iname "*.psd" \) | wc -l)"

# Función para mover archivos basándose en el nombre
mover_archivo() {
    local archivo="$1"
    local nombre=$(basename "$archivo" | tr '[:upper:]' '[:lower:]')
    
    # Detectar tipo de archivo por nombre
    if [[ $nombre == *"logo"* ]] || [[ $nombre == *"brand"* ]] || [[ $nombre == *"marca"* ]]; then
        echo "📁 Moviendo $archivo → logos/"
        mv "$archivo" knowledge_base/archivos_fotograficos/logos/
    elif [[ $nombre == *"fondo"* ]] || [[ $nombre == *"background"* ]] || [[ $nombre == *"textura"* ]]; then
        echo "📁 Moviendo $archivo → fondos/"
        mv "$archivo" knowledge_base/archivos_fotograficos/fondos/
    elif [[ $nombre == *"diseno"* ]] || [[ $nombre == *"design"* ]] || [[ $nombre == *"mockup"* ]]; then
        echo "📁 Moviendo $archivo → disenos/"
        mv "$archivo" knowledge_base/archivos_fotograficos/disenos/
    elif [[ $nombre == *"trabajo"* ]] || [[ $nombre == *"work"* ]] || [[ $nombre == *"proyecto"* ]]; then
        echo "📁 Moviendo $archivo → trabajos/"
        mv "$archivo" knowledge_base/archivos_fotograficos/trabajos/
    elif [[ $nombre == *"producto"* ]] || [[ $nombre == *"item"* ]]; then
        echo "📁 Moviendo $archivo → productos/"
        mv "$archivo" knowledge_base/archivos_fotograficos/productos/
    else
        # Por defecto, mover a trabajos
        echo "📁 Moviendo $archivo → trabajos/ (por defecto)"
        mv "$archivo" knowledge_base/archivos_fotograficos/trabajos/
    fi
}

# Procesar archivos de imagen
echo ""
echo "🔄 Procesando archivos de imagen..."

find fotos -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | while read archivo; do
    mover_archivo "$archivo"
done

# Procesar documentos
echo ""
echo "📄 Procesando documentos..."

find fotos -type f \( -iname "*.pdf" -o -iname "*.doc" -o -iname "*.docx" \) | while read archivo; do
    echo "📁 Moviendo $archivo → disenos/"
    mv "$archivo" knowledge_base/archivos_fotograficos/disenos/
done

# Procesar archivos de diseño
echo ""
echo "🎨 Procesando archivos de diseño..."

find fotos -type f \( -iname "*.ai" -o -iname "*.eps" -o -iname "*.psd" -o -iname "*.svg" \) | while read archivo; do
    echo "📁 Moviendo $archivo → disenos/"
    mv "$archivo" knowledge_base/archivos_fotograficos/disenos/
done

# Crear archivo de índice
echo ""
echo "📋 Creando índice de archivos..."

cat > knowledge_base/archivos_fotograficos/INDICE.md << 'EOF'
# 📸 Índice de Archivos Fotográficos - Media Quality Net

## 📊 **Estadísticas Generales**

### **Productos:** $(find productos -type f | wc -l) archivos
### **Trabajos:** $(find trabajos -type f | wc -l) archivos
### **Diseños:** $(find disenos -type f | wc -l) archivos
### **Logos:** $(find logos -type f | wc -l) archivos
### **Fondos:** $(find fondos -type f | wc -l) archivos
### **Clientes:** $(find clientes -type f | wc -l) archivos

## 📁 **Estructura de Carpetas**

### **productos/** - Fotos de productos terminados
### **trabajos/** - Fotos de trabajos realizados
### **disenos/** - Fotos de diseños y mockups
### **logos/** - Logotipos y marcas
### **fondos/** - Fondos y texturas
### **clientes/** - Fotos de trabajos para clientes específicos

## 🔄 **Actualización Automática**

Este índice se actualiza automáticamente cuando:
- Se agregan nuevas fotos
- Se procesan imágenes con el workflow de catalogador
- Se organizan archivos manualmente

---

**Última actualización:** $(date '+%Y-%m-%d %H:%M:%S')
**Total de archivos:** $(find . -type f | wc -l)
EOF

echo "✅ Índice creado en knowledge_base/archivos_fotograficos/INDICE.md"

# Mostrar resumen final
echo ""
echo "🎯 Resumen de organización:"
echo "=========================="
echo "📁 knowledge_base/archivos_fotograficos/"
echo "├── productos/ ($(find knowledge_base/archivos_fotograficos/productos -type f 2>/dev/null | wc -l) archivos)"
echo "├── trabajos/ ($(find knowledge_base/archivos_fotograficos/trabajos -type f 2>/dev/null | wc -l) archivos)"
echo "├── disenos/ ($(find knowledge_base/archivos_fotograficos/disenos -type f 2>/dev/null | wc -l) archivos)"
echo "├── logos/ ($(find knowledge_base/archivos_fotograficos/logos -type f 2>/dev/null | wc -l) archivos)"
echo "├── fondos/ ($(find knowledge_base/archivos_fotograficos/fondos -type f 2>/dev/null | wc -l) archivos)"
echo "└── clientes/ ($(find knowledge_base/archivos_fotograficos/clientes -type f 2>/dev/null | wc -l) archivos)"

echo ""
echo "✅ Organización completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Revisar la organización en knowledge_base/archivos_fotograficos/"
echo "2. Mover manualmente archivos que no se clasificaron correctamente"
echo "3. Actualizar el workflow de catalogador para usar esta estructura"
echo "4. Probar el procesamiento automático de nuevas fotos"
