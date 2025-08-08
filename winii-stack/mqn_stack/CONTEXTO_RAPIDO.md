# 🚀 Contexto Rápido - MQN

## 🎯 **PROYECTO ACTUAL:**
**go_to_future_MQN** - Sistema de gestión empresarial para Media Quality Net

## 📍 **ESTADO:**
- ✅ **n8n funcionando:** http://172.18.1.158:5679
- ✅ **Credenciales:** mediaqualitynet@gmail.com / Cadena_2000
- ✅ **3 workflows activos:** bienvenida, whatsapp, catalogador
- ✅ **Git actualizado:** Todo respaldado en GitHub

## 🎨 **CONTEXTO NEGOCIO:**
**Media Quality Net** - Impresión digital, serigrafía, sublimación
- Productos: Playeras, tazas, posters, tarjetas
- Técnicas: Digital, serigrafía, sublimación, bordado

## ⏭️ **PRÓXIMO PASO:**
**Entrevista sobre flujo de trabajo real de MQN** para implementar workflows específicos

## 🔄 **COMANDOS ÚTILES:**
```bash
# Reiniciar
cd mqn_stack && docker-compose restart

# Probar
curl -X POST "http://172.18.1.158:5679/webhook/bienvenida-mqn" \
  -H "Content-Type: application/json" \
  -d '{"phone": "9671262441", "message": "hola", "name": "Test"}'

# Git
git add . && git commit -m "cambios" && git push origin main
```

---
**Última actualización:** 2025-08-08 07:37
