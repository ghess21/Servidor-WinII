# Configurar y renderizar stack inicial
./assistant.sh config

# Validar integridad del entorno antes de iniciar
./assistant.sh validate

# Ver diagnóstico del estado actual
./assistant.sh status

# Respaldar todo el entorno en un tarball
./assistant.sh backup

# Restaurar desde un backup previo
./assistant.sh restore

# Reinicializar entorno sin trazas anteriores
./assistant.sh reset

#🧭 Comandos disponibles
#Comando	Descripción rápida
#config	Configura servicios y genera docker-compose.yml
#status	Muestra estado actual de contenedores y servicios
#reset	Elimina entorno actual y reconstruye desde cero
#backup	Crea respaldo comprimido del stack (.tar.gz)
#restore	Restaura entorno desde archivo de respaldo
#audit	Registra uso y estado del CLI en archivo de auditoría
#validate	Verifica puertos, variables y dependencias
#render	Regenera archivo docker-compose.yml desde plantilla
