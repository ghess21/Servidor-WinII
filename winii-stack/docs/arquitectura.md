# 🧩 Servidor WinII v2 — Arquitectura Adaptativa
init.sh ─┬─► audit.log (permisos ejecutables)
         └─► preflight_inventory.sh
             └─► validate.sh ─► auditoría de stack
                           └─► render_compose.sh ─► docker-compose.yml
                           └─► install_stack.sh ─► ejecución final de servicios
                           └─► setup_services.sh ─► generación base
assistant.sh ←── llamado desde init.sh vía comando interactivo (opcional)

Este stack permite activar o desactivar servicios como Redis, PostgreSQL y n8n de forma dinámica mediante scripts shell y plantillas YAML.

## 🌐 Servicios disponibles

| Servicio   | Flag           | Puerto Default |
|------------|----------------|----------------|
| Redis      | ENABLE_REDIS   | 6379           |
| PostgreSQL | ENABLE_POSTGRES| 5432           |
| n8n        | ENABLE_N8N     | 5678           |

## 🛠️ Componentes clave

- `env.sh`: Variables dinámicas
- `template.yml.tpl`: Plantilla condicional
- `render_compose.sh`: Generador de Compose
- `validate.sh`: Chequeos de entorno
- `assistant.sh`: Interfaz CLI
- `install_stack.sh`: Instalación completa

## 📈 Diagrama de flujo

```mermaid
flowchart LR
    A[env.sh] --> B[assistant.sh]
    B --> C[render_compose.sh]
    C --> D[validate.sh]
    D --> E[install_stack.sh]
    E --> F[docker-compose.yml]
