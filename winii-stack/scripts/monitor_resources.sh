#!/bin/bash
# Script de monitoreo de recursos para mini PC

echo "🖥️ Monitoreo de Recursos - WinII Stack"
echo "========================================"

# CPU Usage
echo "📊 CPU:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | awk '{print "   Uso: " $1 "%"}'

# Memory Usage
echo "💾 RAM:"
free -h | grep Mem | awk '{print "   Total: " $2 " | Usado: " $3 " | Libre: " $4}'
free | grep Mem | awk '{printf "   Uso: %.1f%%\n", $3/$2 * 100.0}'

# Disk Usage
echo "💿 Disco:"
df -h / | tail -1 | awk '{print "   Total: " $2 " | Usado: " $3 " | Libre: " $4 " | Uso: " $5}'

# Docker Containers
echo "🐳 Contenedores Docker:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   Docker no está ejecutándose"

# Network (compatible con WSL)
echo "🌐 Red:"
ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print "   IP: " $2}' | head -1

# Temperature (si está disponible)
if command -v sensors &> /dev/null; then
    echo "🌡️ Temperatura:"
    sensors | grep "Core" | head -1 | awk '{print "   " $1 " " $2 " " $3}'
else
    echo "🌡️ Temperatura: No disponible en WSL"
fi

echo "========================================"
