# 🚀 Dockerfile para Frontend de Media Quality Net
# Multi-stage build para optimización

# Stage 1: Dependencias
FROM node:18-alpine AS deps
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY yarn.lock* ./

# Instalar dependencias
RUN yarn install --frozen-lockfile --production=false

# Stage 2: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copiar dependencias del stage anterior
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Variables de entorno para build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Construir la aplicación
RUN yarn build

# Stage 3: Producción
FROM node:18-alpine AS runner
WORKDIR /app

# Usuario no-root para seguridad
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copiar archivos necesarios
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Cambiar propietario de archivos
RUN chown -R nextjs:nodejs /app

# Usuario no-root
USER nextjs

# Exponer puerto
EXPOSE 3000

# Variables de entorno
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# Comando de inicio
CMD ["node", "server.js"]
