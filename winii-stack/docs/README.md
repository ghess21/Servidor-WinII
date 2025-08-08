# 🧠 Servidor WinII - Asistente de Configuración

Este proyecto integra un asistente modular para la configuración, validación y gestión de stacks Docker con servicios como Redis, PostgreSQL, Samba y n8n. Diseñado para entornos WSL2 optimizados y arquitecturas escalables.

---

## 📐 Estructura del stack

📦 Proyecto Base │ 
                 ├── scripts/ 	│ 
                              	├── assistant.sh # Dispatcher técnico por comandos │ 
                              	├── setup_services.sh # Generación base de servicios │ 
				├── validate.sh # Preflight técnico de entorno │ 
				├── render_compose.sh # Renderizado del docker-compose │ 
				├── install_stack.sh # Instalación integral │ 
				├── setup_interactivo.sh # Flujo guiado alternativo │ 
				├── preflight_inventory.sh # Inventario inicial del entorno │ 
		├── templates/ 
		│ └── *.tpl # Plantillas de servicio │ 
		├── docs/ 	│ 
				├── README.md # Este documento 
				│ └── arquitectura.md # Diagrama del stack y flujos │ 
		├── logs/ │ └── audit.log # Bitácora de acciones │ 
└── init.sh # Asistente visual principal


---

## 🧭 Flujo interactivo (`init.sh`)

```plaintext
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃          Asistente Visual         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

      ┌────────────────────────────────────┐
      │ 🔐 Auditoría de permisos            │
      └────────────────────────────────────┘
                    ↓
      ┌────────────────────────────────────┐
      │ 🧪 Preflight técnico (`preflight`) │
      └────────────────────────────────────┘
                    ↓
      ┌────────────────────────────────────┐
      │ 🎛️ Selección guiada                │
      └────────────────────────────────────┘
             ↓            ↓            ↓
      ┌──────────┐ ┌────────────┐ ┌─────────────┐
      │ Configur │ │ Validación │ │ Instalación │
      └──────────┘ └────────────┘ └─────────────┘

