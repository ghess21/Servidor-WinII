#!/bin/bash
# Script de instalación avanzado del stack con barra de progreso

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOG_FILE="logs/install_advanced.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo -e "${CYAN}🚀 INSTALACIÓN AVANZADA DEL STACK WINII${NC}" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo -e "⏰ Inicio: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Función para mostrar barra de progreso
show_progress() {
    local current=$1
    local total=$2
    local step_name=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %d%% - %s" $percentage "$step_name"
}

# Función para mostrar paso actual
show_step() {
    local step=$1
    local description=$2
    echo -e "\n${BLUE}📋 Paso $step: $description${NC}" | tee -a "$LOG_FILE"
}

# Función para verificar dependencias
check_dependencies() {
    show_step "1" "Verificando dependencias"
    
    local deps=("docker" "docker-compose" "gomplate")
    local total=${#deps[@]}
    local available=0
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            echo -e "  ${GREEN}✅ $dep disponible${NC}" | tee -a "$LOG_FILE"
            ((available++))
        else
            echo -e "  ${RED}❌ $dep no disponible${NC}" | tee -a "$LOG_FILE"
        fi
        show_progress $available $total "Verificando dependencias"
    done
    
    echo ""
    if [[ $available -eq $total ]]; then
        echo -e "${GREEN}✅ Todas las dependencias están disponibles${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ Faltan dependencias. Instalando...${NC}" | tee -a "$LOG_FILE"
        
        # Instalar dependencias faltantes
        if ! command -v docker-compose &> /dev/null; then
            echo "Instalando docker-compose..." | tee -a "$LOG_FILE"
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
        
        if ! command -v gomplate &> /dev/null; then
            echo "Instalando gomplate..." | tee -a "$LOG_FILE"
            bash scripts/install_gomplate.sh
        fi
        
        return 0
    fi
}

# Función para validar entorno
validate_environment() {
    show_step "2" "Validando entorno"
    
    echo -e "  ${YELLOW}🔍 Ejecutando validaciones...${NC}" | tee -a "$LOG_FILE"
    
    if bash scripts/validate.sh >> "$LOG_FILE" 2>&1; then
        echo -e "  ${GREEN}✅ Validación exitosa${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}❌ Error en validación${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Función para renderizar docker-compose
render_compose() {
    show_step "3" "Renderizando docker-compose.yml"
    
    echo -e "  ${YELLOW}🔧 Generando configuración...${NC}" | tee -a "$LOG_FILE"
    
    if bash scripts/render_compose.sh >> "$LOG_FILE" 2>&1; then
        echo -e "  ${GREEN}✅ Docker-compose generado exitosamente${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}❌ Error al generar docker-compose${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Función para descargar imágenes
download_images() {
    show_step "4" "Descargando imágenes Docker"
    
    echo -e "  ${YELLOW}📦 Descargando imágenes...${NC}" | tee -a "$LOG_FILE"
    
    # Lista de imágenes a descargar
    local images=("redis:7" "postgres:16" "n8nio/n8n")
    local total=${#images[@]}
    local downloaded=0
    
    for image in "${images[@]}"; do
        echo -e "  ${YELLOW}📥 Descargando $image...${NC}" | tee -a "$LOG_FILE"
        if docker pull "$image" >> "$LOG_FILE" 2>&1; then
            echo -e "  ${GREEN}✅ $image descargado${NC}" | tee -a "$LOG_FILE"
            ((downloaded++))
        else
            echo -e "  ${RED}❌ Error al descargar $image${NC}" | tee -a "$LOG_FILE"
        fi
        show_progress $downloaded $total "Descargando imágenes"
    done
    
    echo ""
    if [[ $downloaded -eq $total ]]; then
        echo -e "${GREEN}✅ Todas las imágenes descargadas${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ Error al descargar algunas imágenes${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Función para iniciar contenedores
start_containers() {
    show_step "5" "Iniciando contenedores"
    
    echo -e "  ${YELLOW}🚀 Iniciando stack...${NC}" | tee -a "$LOG_FILE"
    
    if docker-compose up -d >> "$LOG_FILE" 2>&1; then
        echo -e "  ${GREEN}✅ Contenedores iniciados${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "  ${RED}❌ Error al iniciar contenedores${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Función para monitorear inicio
monitor_startup() {
    show_step "6" "Monitoreando inicio de servicios"
    
    echo -e "  ${YELLOW}⏳ Esperando que los servicios estén listos...${NC}" | tee -a "$LOG_FILE"
    
    local timeout=300  # 5 minutos
    local elapsed=0
    local interval=10
    local all_ready=false
    
    while [[ $elapsed -lt $timeout ]] && [[ "$all_ready" == "false" ]]; do
        local ready_count=0
        local total_services=3
        
        # Verificar Redis
        if timeout 5 bash -c "</dev/tcp/localhost/6379" 2>/dev/null; then
            echo -e "  ${GREEN}✅ Redis listo${NC}" | tee -a "$LOG_FILE"
            ((ready_count++))
        else
            echo -e "  ${YELLOW}⏳ Redis iniciando...${NC}" | tee -a "$LOG_FILE"
        fi
        
        # Verificar PostgreSQL
        if timeout 5 bash -c "</dev/tcp/localhost/5432" 2>/dev/null; then
            echo -e "  ${GREEN}✅ PostgreSQL listo${NC}" | tee -a "$LOG_FILE"
            ((ready_count++))
        else
            echo -e "  ${YELLOW}⏳ PostgreSQL iniciando...${NC}" | tee -a "$LOG_FILE"
        fi
        
        # Verificar N8N
        if timeout 5 bash -c "</dev/tcp/localhost/5678" 2>/dev/null; then
            echo -e "  ${GREEN}✅ N8N listo${NC}" | tee -a "$LOG_FILE"
            ((ready_count++))
        else
            echo -e "  ${YELLOW}⏳ N8N iniciando...${NC}" | tee -a "$LOG_FILE"
        fi
        
        show_progress $ready_count $total_services "Esperando servicios"
        
        if [[ $ready_count -eq $total_services ]]; then
            all_ready=true
        else
            sleep $interval
            elapsed=$((elapsed + interval))
        fi
    done
    
    echo ""
    if [[ "$all_ready" == "true" ]]; then
        echo -e "${GREEN}✅ Todos los servicios están listos${NC}" | tee -a "$LOG_FILE"
        return 0
    else
        echo -e "${RED}❌ Timeout: Algunos servicios no están listos${NC}" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Función para mostrar estado final
show_final_status() {
    show_step "7" "Estado final del stack"
    
    echo -e "${CYAN}🐳 Contenedores ejecutándose:${NC}" | tee -a "$LOG_FILE"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_FILE"
    
    echo -e "\n${CYAN}🔌 Puertos disponibles:${NC}" | tee -a "$LOG_FILE"
    echo -e "  ${GREEN}Redis: localhost:6379${NC}" | tee -a "$LOG_FILE"
    echo -e "  ${GREEN}PostgreSQL: localhost:5432${NC}" | tee -a "$LOG_FILE"
    echo -e "  ${GREEN}N8N: localhost:5678${NC}" | tee -a "$LOG_FILE"
    
    echo -e "\n${CYAN}📊 Uso de recursos:${NC}" | tee -a "$LOG_FILE"
    echo -e "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%" | tee -a "$LOG_FILE"
    echo -e "  RAM: $(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')%" | tee -a "$LOG_FILE"
    echo -e "  Disco: $(df -h / | tail -1 | awk '{print $5}')" | tee -a "$LOG_FILE"
}

# Función principal
main() {
    local steps=7
    local current_step=0
    
    # Verificar dependencias
    ((current_step++))
    if ! check_dependencies; then
        echo -e "${RED}❌ Error en verificación de dependencias${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Validar entorno
    ((current_step++))
    if ! validate_environment; then
        echo -e "${RED}❌ Error en validación del entorno${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Renderizar docker-compose
    ((current_step++))
    if ! render_compose; then
        echo -e "${RED}❌ Error al renderizar docker-compose${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Descargar imágenes
    ((current_step++))
    if ! download_images; then
        echo -e "${RED}❌ Error al descargar imágenes${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Iniciar contenedores
    ((current_step++))
    if ! start_containers; then
        echo -e "${RED}❌ Error al iniciar contenedores${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Monitorear inicio
    ((current_step++))
    if ! monitor_startup; then
        echo -e "${RED}❌ Error en monitoreo de inicio${NC}" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    # Mostrar estado final
    ((current_step++))
    show_final_status
    
    echo -e "\n${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}⏰ Finalización: $(date '+%Y-%m-%d %H:%M:%S')${NC}" | tee -a "$LOG_FILE"
    
    # Iniciar monitoreo continuo
    echo -e "\n${YELLOW}🔄 Iniciando monitoreo continuo...${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}" | tee -a "$LOG_FILE"
    
    # Ejecutar monitoreo continuo
    bash scripts/monitor_stack.sh continuous 5
}

# Ejecutar función principal
main "$@"
