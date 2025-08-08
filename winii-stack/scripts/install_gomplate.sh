#!/bin/bash
echo "[INSTALL] Instalando 'gomplate'..."

TARGET="/usr/local/bin/gomplate"

# Descargar última versión
curl -sSL https://github.com/hairyhenderson/gomplate/releases/latest/download/gomplate_linux-amd64 -o gomplate
chmod +x gomplate
sudo mv gomplate "$TARGET"

# Verificar instalación
if command -v gomplate &> /dev/null; then
  echo "✅ 'gomplate' instalado en $TARGET"
else
  echo "❌ Error al instalar gomplate"
  exit 1
fi
