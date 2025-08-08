#!/bin/bash
# Script de monitoreo avanzado del stack con barra de progreso

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar barra de progreso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %d%%" $percentage
}

# Función para mostrar estado de contenedores
show_container_status() {
    echo -e "\n${CYAN}🐳 Estado de Contenedores:${NC}"
    echo "========================================"
    
    local containers=("redis" "postgres" "n8n")
    local total=${#containers[@]}
    local running=0
    
    for container in "${containers[@]}"; do
        local status=$(docker ps --filter "name=$container" --format "{{.Status}}" 2>/dev/null)
        if [[ -n "$status" ]]; then
            echo -e "${GREEN}✅ $container: $status${NC}"
            ((running++))
        else
            echo -e "${RED}❌ $container: No está ejecutándose${NC}"
        fi
    done
    
    show_progress $running $total
    echo -e "\n"
    
    return $running
}

# Función para mostrar uso de recursos
show_resource_usage() {
    echo -e "${BLUE}📊 Uso de Recursos:${NC}"
    echo "========================================"
    
    # CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "🖥️  CPU: ${YELLOW}${cpu_usage}%${NC}"
    
    # RAM
    local ram_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    echo -e "💾 RAM: ${YELLOW}${ram_usage}%${NC}"
    
    # Disco
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo -e "💿 Disco: ${YELLOW}${disk_usage}%${NC}"
    
    # Docker
    local docker_containers=$(docker ps --format "{{.Names}}" | wc -l)
    echo -e "🐳 Contenedores activos: ${YELLOW}${docker_containers}${NC}"
}

# Función para verificar conectividad de servicios
check_service_connectivity() {
    echo -e "${PURPLE}🔌 Verificación de Conectividad:${NC}"
    echo "========================================"
    
    local services=(
        "redis:6379"
        "postgres:5432"
        "n8n:5678"
    )
    
    for service in "${services[@]}"; do
        local host=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        
        if timeout 5 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
            echo -e "${GREEN}✅ $host:$port - Conectado${NC}"
        else
            echo -e "${RED}❌ $host:$port - No conectado${NC}"
        fi
    done
}

# Función para mostrar logs recientes
show_recent_logs() {
    echo -e "${CYAN}📋 Logs Recientes:${NC}"
    echo "========================================"
    
    local containers=("redis" "postgres" "n8n")
    for container in "${containers[@]}"; do
        local container_name="winii-stack-${container}-1"
        echo -e "${YELLOW}📝 $container:${NC}"
        docker logs --tail 3 "$container_name" 2>/dev/null | sed 's/^/  /'
        echo ""
    done
}

# Función para detectar actividad
detect_activity() {
    echo -e "${BLUE}🔍 Detección de Actividad:${NC}"
    echo "========================================"
    
    # Verificar logs recientes (últimos 30 segundos)
    local recent_activity=false
    
    for container in "redis" "postgres" "n8n"; do
        local container_name="winii-stack-${container}-1"
        local recent_logs=$(docker logs --since 30s "$container_name" 2>/dev/null | wc -l)
        
        if [[ $recent_logs -gt 0 ]]; then
            echo -e "${GREEN}✅ $container: Actividad detectada (${recent_logs} logs)${NC}"
            recent_activity=true
        else
            echo -e "${YELLOW}⚠️  $container: Sin actividad reciente${NC}"
        fi
    done
    
    if [[ "$recent_activity" == "false" ]]; then
        echo -e "${RED}🚨 ADVERTENCIA: No se detecta actividad reciente en ningún servicio${NC}"
        return 1
    fi
    
    return 0
}

# Función principal de monitoreo
main_monitor() {
    clear
    echo -e "${CYAN}🖥️  MONITOR DE STACK WINII${NC}"
    echo "========================================"
    echo -e "⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Mostrar estado de contenedores
    show_container_status
    local containers_running=$?
    
    # Mostrar uso de recursos
    show_resource_usage
    
    # Verificar conectividad
    check_service_connectivity
    
    # Detectar actividad
    detect_activity
    local activity_status=$?
    
    # Mostrar logs recientes
    show_recent_logs
    
    echo "========================================"
    echo -e "${GREEN}✅ Contenedores ejecutándose: $containers_running/3${NC}"
    
    if [[ $activity_status -eq 0 ]]; then
        echo -e "${GREEN}✅ Stack funcionando correctamente${NC}"
    else
        echo -e "${RED}⚠️  Posible problema de actividad${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Presiona Ctrl+C para salir${NC}"
}

# Función de monitoreo continuo
continuous_monitor() {
    local interval=${1:-5}
    echo -e "${CYAN}🔄 Iniciando monitoreo continuo (intervalo: ${interval}s)${NC}"
    
    while true; do
        main_monitor
        sleep $interval
    done
}

# Función de monitoreo con timeout
timeout_monitor() {
    local timeout=${1:-300}  # 5 minutos por defecto
    local interval=${2:-10}  # 10 segundos por defecto
    local elapsed=0
    
    echo -e "${CYAN}⏱️  Monitoreo con timeout (${timeout}s)${NC}"
    
    while [[ $elapsed -lt $timeout ]]; do
        main_monitor
        echo -e "${YELLOW}⏳ Tiempo restante: $((timeout - elapsed))s${NC}"
        
        if [[ $elapsed -gt 60 ]] && ! detect_activity >/dev/null 2>&1; then
            echo -e "${RED}🚨 TIMEOUT: No se detecta actividad después de 60s${NC}"
            return 1
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo -e "${GREEN}✅ Monitoreo completado exitosamente${NC}"
    return 0
}

# Manejo de argumentos
case "${1:-}" in
    "continuous"|"-c")
        continuous_monitor "${2:-5}"
        ;;
    "timeout"|"-t")
        timeout_monitor "${2:-300}" "${3:-10}"
        ;;
    "help"|"-h"|"--help")
        echo "Uso: $0 [opción] [parámetros]"
        echo ""
        echo "Opciones:"
        echo "  (sin argumentos)  - Monitoreo único"
        echo "  continuous, -c    - Monitoreo continuo"
        echo "  timeout, -t       - Monitoreo con timeout"
        echo "  help, -h          - Mostrar esta ayuda"
        echo ""
        echo "Ejemplos:"
        echo "  $0                # Monitoreo único"
        echo "  $0 continuous 10  # Monitoreo cada 10s"
        echo "  $0 timeout 300    # Monitoreo por 5 minutos"
        ;;
    *)
        main_monitor
        ;;
esac
