# ⚙️ Documentación de scripts

## `assistant.sh`
Dispatcher interactivo para selección de tareas: setup, render, validación.

## `setup_services.sh`
Genera estructura de carpetas y archivos base para cada microservicio.

## `validate.sh`
Comprueba existencia de `.env`, puertos libres y carpeta esperadas.

## `render_compose.sh`
Toma plantilla `.tpl` y genera `docker-compose.yml` con variables de entorno.

## `fix_permissions.sh`
Ajusta permisos para ejecución segura, especialmente en `scripts/` y `logs/`.

## `preflight_inventory.sh`
Diagnóstico preliminar del entorno antes de instalar servicios.
