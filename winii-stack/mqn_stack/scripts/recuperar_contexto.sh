#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       RECUPERAR CONTEXTO MQN          ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🎨 Recuperando contexto de Media Quality Net..."
echo "=============================================="

# Verificar estado de servicios
echo ""
echo "🔍 Estado de servicios:"
docker-compose ps 2>/dev/null || echo "❌ Docker no disponible"

# Mostrar URLs de acceso
echo ""
echo "🌐 URLs de acceso:"
echo "• n8n: http://172.18.1.158:5679"
echo "• Usuario: mediaqualitynet@gmail.com"
echo "• Contraseña: Cadena_2000"

# Mostrar workflows disponibles
echo ""
echo "🔧 Workflows disponibles:"
ls -la workflows/ 2>/dev/null || echo "❌ Directorio workflows no encontrado"

# Mostrar estado del repositorio
echo ""
echo "📚 Estado del repositorio:"
git status --porcelain 2>/dev/null || echo "❌ Git no disponible"

# Mostrar comandos útiles
echo ""
echo "🔄 Comandos útiles:"
echo "• Reiniciar: cd mqn_stack && docker-compose restart"
echo "• Probar: curl -X POST http://172.18.1.158:5679/webhook/bienvenida-mqn"
echo "• Logs: docker-compose logs -f n8n"
echo "• Git: git add . && git commit -m 'cambios' && git push origin main"

# Mostrar próximo paso
echo ""
echo "🎯 Próximo paso:"
echo "Entrevista sobre flujo de trabajo real de Media Quality Net"
echo "para implementar workflows específicos del negocio."

echo ""
echo "✅ Contexto recuperado - ¡Listo para continuar!"
