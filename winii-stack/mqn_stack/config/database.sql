-- Esquema de base de datos para MQN
-- Sistema de gestión empresarial con IA

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    telefono VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100),
    email VARCHAR(100),
    direccion TEXT,
    notas TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_interaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo'
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(100),
    material VARCHAR(100),
    tecnica_impresion VARCHAR(100),
    precio_base DECIMAL(10,2),
    precio_venta DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    imagen_path VARCHAR(500),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo'
);

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS ventas (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'pendiente',
    notas TEXT,
    requisitos_especiales TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de items de venta
CREATE TABLE IF NOT EXISTS venta_items (
    id SERIAL PRIMARY KEY,
    venta_id INTEGER REFERENCES ventas(id),
    producto_id INTEGER REFERENCES productos(id),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Tabla de conversaciones WhatsApp
CREATE TABLE IF NOT EXISTS conversaciones (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    mensaje TEXT NOT NULL,
    tipo VARCHAR(20) DEFAULT 'texto', -- texto, imagen, audio, documento
    direccion VARCHAR(10) DEFAULT 'entrada', -- entrada, salida
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procesado BOOLEAN DEFAULT FALSE
);

-- Tabla de tareas
CREATE TABLE IF NOT EXISTS tareas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    asignado_a VARCHAR(100),
    prioridad VARCHAR(20) DEFAULT 'normal', -- baja, normal, alta, urgente
    estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, en_proceso, completada
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_limite TIMESTAMP,
    fecha_completada TIMESTAMP
);

-- Tabla de logs del sistema
CREATE TABLE IF NOT EXISTS logs_sistema (
    id SERIAL PRIMARY KEY,
    modulo VARCHAR(50) NOT NULL,
    accion VARCHAR(100) NOT NULL,
    detalles JSONB,
    nivel VARCHAR(20) DEFAULT 'info', -- debug, info, warning, error
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de configuración del sistema
CREATE TABLE IF NOT EXISTS configuracion (
    clave VARCHAR(100) PRIMARY KEY,
    valor TEXT,
    descripcion TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_clientes_telefono ON clientes(telefono);
CREATE INDEX IF NOT EXISTS idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_conversaciones_cliente ON conversaciones(cliente_id);
CREATE INDEX IF NOT EXISTS idx_logs_modulo ON logs_sistema(modulo);
CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON logs_sistema(timestamp);

-- Datos iniciales de configuración
INSERT INTO configuracion (clave, valor, descripcion) VALUES
('evolution_api_key', 'mqn_evolution_key_2024', 'API Key para Evolution API'),
('n8n_webhook_url', 'http://localhost:5678/webhook', 'URL base para webhooks de n8n'),
('sistema_activo', 'true', 'Estado del sistema MQN'),
('version_sistema', '1.0.0', 'Versión actual del sistema MQN')
ON CONFLICT (clave) DO NOTHING;
