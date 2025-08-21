-- 🗄️ INICIALIZACIÓN COMPLETA DEL ECOSISTEMA MEDIA QUALITY NET
-- Base de datos para análisis inteligente de WhatsApp, gestión de productos, clientes y producción
-- Basado en el contexto completo del proyecto MQN

-- ========================================
-- 🗃️ CREACIÓN DE BASES DE DATOS
-- ========================================

-- Base de datos para WhatsApp Evolution API
CREATE DATABASE IF NOT EXISTS whatsapp_evolution;

-- Base de datos para n8n
CREATE DATABASE IF NOT EXISTS n8n_mqn;

-- Conectar a la base de datos principal
\c mqn_ecosistema;

-- ========================================
-- 🏢 TABLAS PRINCIPALES DEL NEGOCIO MQN
-- ========================================

-- Tabla de categorías de productos (según catálogo MQN)
CREATE TABLE IF NOT EXISTS product_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INTEGER REFERENCES product_categories(id),
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos principales (según técnicas de impresión MQN)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INTEGER REFERENCES product_categories(id),
    product_type VARCHAR(100) NOT NULL, -- letrero, impresión, sublimación, DTF, serigrafía, etc.
    description TEXT,
    base_price DECIMAL(10,2),
    min_price DECIMAL(10,2),
    max_price DECIMAL(10,2),
    pricing_model VARCHAR(50), -- por metro, por pieza, por hora
    is_active BOOLEAN DEFAULT true,
    requires_design BOOLEAN DEFAULT true,
    estimated_production_time INTEGER, -- en horas
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de materiales disponibles (según inventario MQN)
CREATE TABLE IF NOT EXISTS materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    material_type VARCHAR(100) NOT NULL, -- acrílico, PVC, aluminio, vinil, etc.
    thickness VARCHAR(50), -- 3mm, 6mm, 10mm, etc.
    color VARCHAR(100),
    finish VARCHAR(100), -- transparente, blanco, negro, espejo, cepillado
    supplier_id INTEGER, -- referencia a proveedores
    current_stock DECIMAL(10,2),
    unit VARCHAR(20), -- m2, piezas, rollos
    cost_per_unit DECIMAL(10,2),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de técnicas de producción (según equipamiento MQN)
CREATE TABLE IF NOT EXISTS production_techniques (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    equipment_required TEXT[], -- CNC, laser, impresora, etc.
    skill_level VARCHAR(50), -- básico, intermedio, avanzado
    setup_time INTEGER, -- tiempo de configuración en minutos
    production_speed VARCHAR(100), -- velocidad de producción
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 📱 TABLAS PARA ANÁLISIS DE WHATSAPP
-- ========================================

-- Tabla de conversaciones de WhatsApp
CREATE TABLE IF NOT EXISTS whatsapp_conversations (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    contact_name VARCHAR(255),
    contact_type VARCHAR(50) DEFAULT 'cliente', -- cliente, proveedor, interno
    business_name VARCHAR(255),
    industry VARCHAR(100),
    location VARCHAR(255),
    first_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_messages INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'activo', -- activo, archivado, bloqueado
    priority VARCHAR(20) DEFAULT 'normal', -- baja, normal, alta, crítica
    assigned_to VARCHAR(100), -- usuario interno asignado
    tags TEXT[], -- etiquetas para categorización
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de mensajes individuales
CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id SERIAL PRIMARY KEY,
    message_id VARCHAR(100) UNIQUE NOT NULL,
    conversation_id INTEGER REFERENCES whatsapp_conversations(id),
    sender_id VARCHAR(100) NOT NULL,
    message_type VARCHAR(20) NOT NULL, -- text, audio, image, document, location
    content TEXT,
    media_url VARCHAR(500),
    media_type VARCHAR(50),
    media_size INTEGER,
    timestamp TIMESTAMP NOT NULL,
    is_from_client BOOLEAN DEFAULT true,
    is_read BOOLEAN DEFAULT false,
    is_forwarded BOOLEAN DEFAULT false,
    reply_to_message_id VARCHAR(100),
    metadata JSONB, -- metadatos adicionales del mensaje
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de análisis de mensajes por IA
CREATE TABLE IF NOT EXISTS message_analysis (
    id SERIAL PRIMARY KEY,
    message_id VARCHAR(100) REFERENCES whatsapp_messages(message_id),
    analysis_type VARCHAR(50) DEFAULT 'whatsapp_message',
    extracted_products JSONB, -- productos identificados
    extracted_materials JSONB, -- materiales mencionados
    client_intent VARCHAR(50), -- consulta, cotización, pedido, urgencia
    urgency_level VARCHAR(20), -- baja, media, alta, crítica
    suggested_actions TEXT[], -- acciones sugeridas
    confidence_score DECIMAL(3,2), -- puntuación de confianza (0.00-1.00)
    raw_analysis JSONB, -- análisis completo de la IA
    analysis_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100), -- usuario o sistema que procesó
    status VARCHAR(50) DEFAULT 'pendiente' -- pendiente, procesado, error
);

-- ========================================
-- 🏷️ TABLAS PARA PRODUCTOS EXTRAÍDOS
-- ========================================

-- Tabla de productos identificados por IA
CREATE TABLE IF NOT EXISTS extracted_products (
    id SERIAL PRIMARY KEY,
    analysis_id INTEGER REFERENCES message_analysis(id),
    product_name VARCHAR(255) NOT NULL,
    product_type VARCHAR(100), -- letrero, impresión, sublimación, DTF, etc.
    dimensions VARCHAR(100), -- medidas mencionadas
    quantity INTEGER,
    materials TEXT[], -- materiales requeridos
    techniques TEXT[], -- técnicas de producción
    special_requirements TEXT,
    estimated_price DECIMAL(10,2),
    confidence_score DECIMAL(3,2),
    is_confirmed BOOLEAN DEFAULT false, -- confirmado por usuario interno
    confirmed_by VARCHAR(100),
    confirmed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de materiales identificados por IA
CREATE TABLE IF NOT EXISTS extracted_materials (
    id SERIAL PRIMARY KEY,
    analysis_id INTEGER REFERENCES message_analysis(id),
    material_name VARCHAR(255) NOT NULL,
    material_type VARCHAR(100), -- acrílico, PVC, aluminio, vinil, etc.
    specifications TEXT, -- especificaciones técnicas
    quantity VARCHAR(100), -- cantidad mencionada
    unit VARCHAR(50), -- unidad de medida
    is_available BOOLEAN DEFAULT true,
    supplier_info TEXT,
    estimated_cost DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 👥 TABLAS PARA CLIENTES Y CONTACTOS
-- ========================================

-- Tabla de clientes identificados
CREATE TABLE IF NOT EXISTS whatsapp_clients (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    contact_name VARCHAR(255),
    business_name VARCHAR(255),
    client_type VARCHAR(50), -- individual, empresa, gobierno
    industry VARCHAR(100),
    location VARCHAR(255),
    fiscal_data JSONB, -- datos fiscales si aplica
    preferences JSONB, -- preferencias del cliente
    first_contact_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_contact_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'activo',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de historial de interacciones
CREATE TABLE IF NOT EXISTS client_interactions (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES whatsapp_clients(id),
    interaction_type VARCHAR(50), -- consulta, cotización, pedido, seguimiento
    message_id VARCHAR(100) REFERENCES whatsapp_messages(message_id),
    analysis_id INTEGER REFERENCES message_analysis(id),
    interaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    summary TEXT,
    outcome VARCHAR(100), -- exitoso, pendiente, cancelado
    assigned_to VARCHAR(100), -- usuario interno asignado
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 🔄 TABLAS PARA FLUJOS DE TRABAJO MQN
-- ========================================

-- Tabla de flujos de trabajo estándar (según workflow MQN)
CREATE TABLE IF NOT EXISTS workflow_templates (
    id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(255) NOT NULL,
    workflow_type VARCHAR(100), -- letrero, impresión, sublimación, etc.
    description TEXT,
    stages JSONB, -- etapas del flujo de trabajo MQN
    estimated_duration INTEGER, -- duración estimada en horas
    required_materials JSONB, -- materiales necesarios
    required_equipment TEXT[], -- equipos necesarios (CNC, laser, impresora, etc.)
    skill_requirements TEXT[], -- habilidades requeridas
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de instancias de flujo de trabajo
CREATE TABLE IF NOT EXISTS workflow_instances (
    id SERIAL PRIMARY KEY,
    template_id INTEGER REFERENCES workflow_templates(id),
    client_id INTEGER REFERENCES whatsapp_clients(id),
    conversation_id INTEGER REFERENCES whatsapp_conversations(id),
    current_stage VARCHAR(100),
    stage_progress INTEGER DEFAULT 0, -- progreso en la etapa actual (0-100)
    overall_progress INTEGER DEFAULT 0, -- progreso general del flujo (0-100)
    assigned_to VARCHAR(100), -- usuario interno asignado
    priority VARCHAR(20) DEFAULT 'normal', -- baja, normal, alta, crítica
    estimated_completion TIMESTAMP,
    actual_completion TIMESTAMP,
    status VARCHAR(50) DEFAULT 'iniciado', -- iniciado, en_progreso, pausado, completado, cancelado
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 🏭 TABLAS PARA PRODUCCIÓN Y EQUIPAMIENTO
-- ========================================

-- Tabla de equipos disponibles (según inventario MQN)
CREATE TABLE IF NOT EXISTS equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    equipment_type VARCHAR(100), -- CNC, laser, impresora, laminadora, etc.
    model VARCHAR(255),
    specifications JSONB,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'disponible', -- disponible, en_uso, mantenimiento, fuera_de_servicio
    maintenance_schedule JSONB,
    last_maintenance TIMESTAMP,
    next_maintenance TIMESTAMP,
    operator_required BOOLEAN DEFAULT true,
    skill_level_required VARCHAR(50), -- básico, intermedio, avanzado
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de tareas de producción
CREATE TABLE IF NOT EXISTS production_tasks (
    id SERIAL PRIMARY KEY,
    workflow_instance_id INTEGER REFERENCES workflow_instances(id),
    task_name VARCHAR(255) NOT NULL,
    task_type VARCHAR(100), -- diseño, corte, impresión, acabado, montaje
    equipment_id INTEGER REFERENCES equipment(id),
    assigned_to VARCHAR(100),
    estimated_duration INTEGER, -- en minutos
    actual_duration INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pendiente', -- pendiente, en_progreso, completado, pausado
    priority VARCHAR(20) DEFAULT 'normal',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 📦 TABLAS PARA INVENTARIO Y PROVEEDORES
-- ========================================

-- Tabla de proveedores
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    fiscal_data JSONB, -- datos fiscales del proveedor
    payment_terms VARCHAR(100),
    credit_limit DECIMAL(12,2),
    current_balance DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'activo',
    rating INTEGER, -- calificación del 1 al 5
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de inventario de materiales
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    material_id INTEGER REFERENCES materials(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    quantity DECIMAL(10,2),
    unit VARCHAR(20),
    cost_per_unit DECIMAL(10,2),
    reorder_point DECIMAL(10,2),
    reorder_quantity DECIMAL(10,2),
    last_restock TIMESTAMP,
    next_restock TIMESTAMP,
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'disponible',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 💰 TABLAS PARA CONTABILIDAD BÁSICA
-- ========================================

-- Tabla de cotizaciones
CREATE TABLE IF NOT EXISTS quotations (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES whatsapp_clients(id),
    conversation_id INTEGER REFERENCES whatsapp_conversations(id),
    quotation_number VARCHAR(50) UNIQUE,
    total_amount DECIMAL(12,2),
    tax_rate DECIMAL(5,2) DEFAULT 16.00, -- IVA mexicano
    tax_amount DECIMAL(12,2),
    grand_total DECIMAL(12,2),
    valid_until TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pendiente', -- pendiente, aprobada, rechazada, expirada
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER REFERENCES quotations(id),
    order_number VARCHAR(50) UNIQUE,
    client_id INTEGER REFERENCES whatsapp_clients(id),
    total_amount DECIMAL(12,2),
    tax_amount DECIMAL(12,2),
    grand_total DECIMAL(12,2),
    payment_status VARCHAR(50) DEFAULT 'pendiente', -- pendiente, parcial, pagado
    order_status VARCHAR(50) DEFAULT 'nuevo', -- nuevo, confirmado, en_producción, completado, entregado
    delivery_date TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pagos
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    payment_method VARCHAR(50), -- efectivo, transferencia, tarjeta, etc.
    amount DECIMAL(12,2),
    payment_date TIMESTAMP,
    reference_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 📊 TABLAS PARA MÉTRICAS Y REPORTES
-- ========================================

-- Tabla de métricas de conversación
CREATE TABLE IF NOT EXISTS conversation_metrics (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES whatsapp_conversations(id),
    metric_date DATE DEFAULT CURRENT_DATE,
    total_messages INTEGER DEFAULT 0,
    response_time_avg INTEGER, -- tiempo promedio de respuesta en segundos
    client_satisfaction_score INTEGER, -- puntuación de satisfacción (1-10)
    conversion_to_order BOOLEAN DEFAULT false,
    order_value DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de análisis de tendencias
CREATE TABLE IF NOT EXISTS trend_analysis (
    id SERIAL PRIMARY KEY,
    analysis_date DATE DEFAULT CURRENT_DATE,
    product_trends JSONB, -- tendencias de productos solicitados
    material_trends JSONB, -- tendencias de materiales
    client_segments JSONB, -- segmentación de clientes
    peak_hours JSONB, -- horas pico de actividad
    seasonal_patterns JSONB, -- patrones estacionales
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 🔐 TABLAS PARA USUARIOS Y PERMISOS
-- ========================================

-- Tabla de usuarios internos del sistema
CREATE TABLE IF NOT EXISTS internal_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL, -- admin, recepcionista, diseñador, producción, ventas
    permissions JSONB, -- permisos específicos del usuario
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de validaciones realizadas por usuarios
CREATE TABLE IF NOT EXISTS user_validations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES internal_users(id),
    analysis_id INTEGER REFERENCES message_analysis(id),
    validation_type VARCHAR(50), -- confirmación, corrección, rechazo
    validation_details TEXT,
    validated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 📍 ÍNDICES PARA OPTIMIZACIÓN
-- ========================================

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_conversation_id ON whatsapp_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_sender_id ON whatsapp_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_message_analysis_message_id ON message_analysis(message_id);
CREATE INDEX IF NOT EXISTS idx_extracted_products_analysis_id ON extracted_products(analysis_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_clients_phone_number ON whatsapp_clients(phone_number);
CREATE INDEX IF NOT EXISTS idx_workflow_instances_status ON workflow_instances(status);
CREATE INDEX IF NOT EXISTS idx_workflow_instances_assigned_to ON workflow_instances(assigned_to);
CREATE INDEX IF NOT EXISTS idx_orders_client_id ON orders(client_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_inventory_material_id ON inventory(material_id);
CREATE INDEX IF NOT EXISTS idx_production_tasks_workflow_instance_id ON production_tasks(workflow_instance_id);

-- Índices para búsquedas de texto completo
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_content_gin ON whatsapp_messages USING gin(to_tsvector('spanish', content));
CREATE INDEX IF NOT EXISTS idx_extracted_products_name_gin ON extracted_products USING gin(to_tsvector('spanish', product_name));
CREATE INDEX IF NOT EXISTS idx_products_name_gin ON products USING gin(to_tsvector('spanish', name));

-- ========================================
-- 🔄 TRIGGERS PARA ACTUALIZACIONES AUTOMÁTICAS
-- ========================================

-- Función para actualizar timestamp de última modificación
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar triggers a tablas relevantes
CREATE TRIGGER update_whatsapp_conversations_updated_at 
    BEFORE UPDATE ON whatsapp_conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_whatsapp_clients_updated_at 
    BEFORE UPDATE ON whatsapp_clients 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_templates_updated_at 
    BEFORE UPDATE ON workflow_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_instances_updated_at 
    BEFORE UPDATE ON workflow_instances 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_materials_updated_at 
    BEFORE UPDATE ON materials 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 📊 VISTAS ÚTILES PARA REPORTES
-- ========================================

-- Vista para resumen de conversaciones activas
CREATE OR REPLACE VIEW active_conversations_summary AS
SELECT 
    wc.id,
    wc.chat_id,
    wc.contact_name,
    wc.phone_number,
    wc.total_messages,
    wc.last_message_at,
    wc.status,
    wc.priority,
    wc.assigned_to,
    COUNT(wm.id) as unread_messages
FROM whatsapp_conversations wc
LEFT JOIN whatsapp_messages wm ON wc.id = wm.conversation_id AND wm.is_read = false
WHERE wc.status = 'activo'
GROUP BY wc.id, wc.chat_id, wc.contact_name, wc.phone_number, wc.total_messages, wc.last_message_at, wc.status, wc.priority, wc.assigned_to;

-- Vista para análisis de productos más solicitados
CREATE OR REPLACE VIEW popular_products_analysis AS
SELECT 
    ep.product_type,
    ep.product_name,
    COUNT(*) as request_count,
    AVG(ep.estimated_price) as avg_estimated_price,
    AVG(ma.confidence_score) as avg_confidence
FROM extracted_products ep
JOIN message_analysis ma ON ep.analysis_id = ma.id
GROUP BY ep.product_type, ep.product_name
ORDER BY request_count DESC;

-- Vista para métricas de respuesta del equipo
CREATE OR REPLACE VIEW team_response_metrics AS
SELECT 
    wc.assigned_to,
    COUNT(wc.id) as total_conversations,
    AVG(wc.response_time_avg) as avg_response_time,
    COUNT(CASE WHEN wc.conversion_to_order = true THEN 1 END) as successful_conversions,
    ROUND(
        (COUNT(CASE WHEN wc.conversion_to_order = true THEN 1 END)::DECIMAL / COUNT(wc.id)::DECIMAL) * 100, 2
    ) as conversion_rate
FROM workflow_instances wc
WHERE wc.status IN ('iniciado', 'en_progreso', 'completado')
GROUP BY wc.assigned_to;

-- Vista para resumen de inventario
CREATE OR REPLACE VIEW inventory_summary AS
SELECT 
    m.name as material_name,
    m.material_type,
    m.thickness,
    m.color,
    i.quantity,
    i.unit,
    i.cost_per_unit,
    i.location,
    i.status,
    s.name as supplier_name
FROM inventory i
JOIN materials m ON i.material_id = m.id
LEFT JOIN suppliers s ON i.supplier_id = s.id
WHERE i.status = 'disponible'
ORDER BY m.material_type, m.name;

-- Vista para resumen de pedidos
CREATE OR REPLACE VIEW orders_summary AS
SELECT 
    o.order_number,
    o.order_date,
    c.contact_name,
    c.business_name,
    o.total_amount,
    o.order_status,
    o.payment_status,
    o.delivery_date,
    wi.current_stage,
    wi.overall_progress
FROM orders o
JOIN whatsapp_clients c ON o.client_id = c.id
LEFT JOIN workflow_instances wi ON o.id = wi.order_id
ORDER BY o.created_at DESC;

-- ========================================
-- 🌱 DATOS INICIALES PARA MQN
-- ========================================

-- Insertar categorías de productos principales
INSERT INTO product_categories (name, description, sort_order) VALUES
('Letreros', 'Letreros y señalización para negocios y eventos', 1),
('Impresiones', 'Impresiones en gran formato y materiales especiales', 2),
('Sublimación', 'Productos personalizados con técnica de sublimación', 3),
('DTF', 'Transferencia directa a tela y otros materiales', 4),
('Serigrafía', 'Impresión serigráfica en diversos materiales', 5),
('Acabados', 'Servicios de acabado y laminación', 6)
ON CONFLICT (name) DO NOTHING;

-- Insertar productos principales
INSERT INTO products (name, category_id, product_type, description, base_price, pricing_model) VALUES
('Letrero Básico PVC', 1, 'letrero', 'Letrero básico en PVC con impresión en vinil', 150.00, 'por_pieza'),
('Letrero Acrílico Iluminado', 1, 'letrero', 'Letrero en acrílico con iluminación LED', 800.00, 'por_pieza'),
('Impresión Gran Formato', 2, 'impresión', 'Impresión en gran formato hasta 3m de ancho', 120.00, 'por_m2'),
('Sublimación en Tazas', 3, 'sublimación', 'Personalización de tazas con sublimación', 45.00, 'por_pieza'),
('DTF Textil', 4, 'DTF', 'Transferencia directa a tela', 35.00, 'por_m2'),
('Serigrafía en Vinil', 5, 'serigrafía', 'Impresión serigráfica en vinil', 200.00, 'por_m2')
ON CONFLICT DO NOTHING;

-- Insertar materiales principales
INSERT INTO materials (name, material_type, thickness, color, finish, cost_per_unit, unit) VALUES
('Acrílico Transparente', 'acrílico', '3mm', 'transparente', 'transparente', 450.00, 'm2'),
('Acrílico Blanco', 'acrílico', '3mm', 'blanco', 'mate', 380.00, 'm2'),
('PVC Espumado', 'PVC', '6mm', 'blanco', 'mate', 280.00, 'm2'),
('Vinil Autoadhesivo', 'vinil', '0.1mm', 'varios', 'mate', 85.00, 'm2'),
('Aluminio Anodizado', 'aluminio', '1mm', 'natural', 'natural', 320.00, 'm2')
ON CONFLICT DO NOTHING;

-- Insertar técnicas de producción
INSERT INTO production_techniques (name, description, equipment_required, skill_level, setup_time) VALUES
('Corte CNC', 'Corte preciso con router CNC', ARRAY['CNC Router'], 'intermedio', 30),
('Corte Laser CO2', 'Corte y grabado con láser CO2', ARRAY['Laser CO2'], 'intermedio', 20),
('Impresión Inkjet', 'Impresión en gran formato', ARRAY['Impresora Inkjet'], 'básico', 15),
('Sublimación', 'Transferencia de tinta por calor', ARRAY['Plancha Sublimación'], 'básico', 10),
('Laminación', 'Aplicación de laminado protector', ARRAY['Laminadora'], 'básico', 20)
ON CONFLICT DO NOTHING;

-- Insertar usuarios internos del sistema
INSERT INTO internal_users (username, full_name, email, role, permissions) VALUES
('admin', 'Administrador MQN', 'admin@mqn.com', 'admin', '{"all": true}'),
('recepcion', 'Recepcionista MQN', 'recepcion@mqn.com', 'recepcionista', '{"conversations": true, "clients": true}'),
('disenador', 'Diseñador MQN', 'disenador@mqn.com', 'diseñador', '{"design": true, "production": true}'),
('produccion', 'Producción MQN', 'produccion@mqn.com', 'producción', '{"production": true, "inventory": true}'),
('ventas', 'Ventas MQN', 'ventas@mqn.com', 'ventas', '{"sales": true, "quotations": true}')
ON CONFLICT (username) DO NOTHING;

-- ========================================
-- ✅ FINALIZACIÓN DEL SCRIPT
-- ========================================

-- Comentario de finalización
COMMENT ON DATABASE mqn_ecosistema IS 'Base de datos completa para el ecosistema Media Quality Net con análisis inteligente de WhatsApp, gestión de productos, clientes y producción';

-- Verificar que las tablas se crearon correctamente
SELECT 'Tablas creadas exitosamente' as status, 
       COUNT(*) as total_tables 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Mostrar resumen de la estructura creada
SELECT 
    table_name,
    COUNT(*) as column_count
FROM information_schema.columns 
WHERE table_schema = 'public'
GROUP BY table_name
ORDER BY table_name;

-- Mostrar estadísticas de datos insertados
SELECT 
    'Categorías de productos' as table_name,
    COUNT(*) as record_count
FROM product_categories
UNION ALL
SELECT 
    'Productos',
    COUNT(*)
FROM products
UNION ALL
SELECT 
    'Materiales',
    COUNT(*)
FROM materials
UNION ALL
SELECT 
    'Técnicas de producción',
    COUNT(*)
FROM production_techniques
UNION ALL
SELECT 
    'Usuarios internos',
    COUNT(*)
FROM internal_users;
