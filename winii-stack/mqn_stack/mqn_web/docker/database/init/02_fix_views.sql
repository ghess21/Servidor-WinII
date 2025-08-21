-- 🔧 CORRECCIÓN DE VISTAS CON ERRORES - ECOSISTEMA MQN
-- Conectar a la base de datos principal
\c mqn_ecosistema;

-- ========================================
-- 🚫 ELIMINAR VISTAS CON ERRORES
-- ========================================

DROP VIEW IF EXISTS team_response_metrics;
DROP VIEW IF EXISTS orders_summary;

-- ========================================
-- ✅ RECREAR VISTAS CORREGIDAS
-- ========================================

-- Vista corregida para métricas de respuesta del equipo
CREATE OR REPLACE VIEW team_response_metrics AS
SELECT 
    wc.assigned_to,
    COUNT(wc.id) as total_conversations,
    COUNT(CASE WHEN wc.status = 'activo' THEN 1 END) as active_conversations,
    COUNT(CASE WHEN wc.status = 'archivado' THEN 1 END) as archived_conversations,
    COUNT(CASE WHEN wc.priority = 'crítica' THEN 1 END) as critical_priority,
    COUNT(CASE WHEN wc.priority = 'alta' THEN 1 END) as high_priority
FROM whatsapp_conversations wc
WHERE wc.assigned_to IS NOT NULL
GROUP BY wc.assigned_to
ORDER BY total_conversations DESC;

-- Vista corregida para resumen de pedidos
CREATE OR REPLACE VIEW orders_summary AS
SELECT 
    o.order_number,
    o.created_at as order_date,
    c.contact_name,
    c.business_name,
    o.total_amount,
    o.order_status,
    o.payment_status,
    o.delivery_date,
    COALESCE(wi.current_stage, 'No iniciado') as current_stage,
    COALESCE(wi.overall_progress, 0) as overall_progress
FROM orders o
JOIN whatsapp_clients c ON o.client_id = c.id
LEFT JOIN workflow_instances wi ON wi.client_id = o.client_id
ORDER BY o.created_at DESC;

-- ========================================
-- 🆕 VISTAS ADICIONALES ÚTILES
-- ========================================

-- Vista para resumen de conversaciones por prioridad
CREATE OR REPLACE VIEW conversations_by_priority AS
SELECT 
    priority,
    COUNT(*) as total_conversations,
    COUNT(CASE WHEN status = 'activo' THEN 1 END) as active_conversations,
    COUNT(CASE WHEN status = 'archivado' THEN 1 END) as archived_conversations,
    ROUND(AVG(total_messages), 2) as avg_messages_per_conversation
FROM whatsapp_conversations
GROUP BY priority
ORDER BY 
    CASE priority 
        WHEN 'crítica' THEN 1 
        WHEN 'alta' THEN 2 
        WHEN 'normal' THEN 3 
        WHEN 'baja' THEN 4 
    END;

-- Vista para análisis de productos por categoría
CREATE OR REPLACE VIEW products_by_category AS
SELECT 
    pc.name as category_name,
    COUNT(p.id) as total_products,
    AVG(p.base_price) as avg_price,
    MIN(p.base_price) as min_price,
    MAX(p.base_price) as max_price,
    COUNT(CASE WHEN p.is_active = true THEN 1 END) as active_products
FROM product_categories pc
LEFT JOIN products p ON pc.id = p.category_id
GROUP BY pc.id, pc.name
ORDER BY pc.sort_order;

-- Vista para resumen de inventario por material
CREATE OR REPLACE VIEW inventory_by_material AS
SELECT 
    m.material_type,
    m.name as material_name,
    m.thickness,
    m.color,
    SUM(i.quantity) as total_stock,
    i.unit,
    AVG(i.cost_per_unit) as avg_cost,
    COUNT(DISTINCT i.supplier_id) as supplier_count
FROM inventory i
JOIN materials m ON i.material_id = m.id
WHERE i.status = 'disponible'
GROUP BY m.material_type, m.name, m.thickness, m.color, i.unit
ORDER BY m.material_type, m.name;

-- Vista para flujos de trabajo por estado
CREATE OR REPLACE VIEW workflows_by_status AS
SELECT 
    status,
    COUNT(*) as total_workflows,
    COUNT(CASE WHEN priority = 'crítica' THEN 1 END) as critical_priority,
    COUNT(CASE WHEN priority = 'alta' THEN 1 END) as high_priority,
    AVG(overall_progress) as avg_progress,
    COUNT(CASE WHEN overall_progress = 100 THEN 1 END) as completed_workflows
FROM workflow_instances
GROUP BY status
ORDER BY 
    CASE status 
        WHEN 'iniciado' THEN 1 
        WHEN 'en_progreso' THEN 2 
        WHEN 'pausado' THEN 3 
        WHEN 'completado' THEN 4 
        WHEN 'cancelado' THEN 5 
    END;

-- ========================================
-- 📊 VERIFICACIÓN DE VISTAS CORREGIDAS
-- ========================================

-- Mostrar todas las vistas disponibles
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;

-- Verificar que las vistas corregidas funcionen
SELECT 'Vista team_response_metrics' as view_name, COUNT(*) as record_count FROM team_response_metrics
UNION ALL
SELECT 'Vista orders_summary', COUNT(*) FROM orders_summary
UNION ALL
SELECT 'Vista conversations_by_priority', COUNT(*) FROM conversations_by_priority
UNION ALL
SELECT 'Vista products_by_category', COUNT(*) FROM products_by_category
UNION ALL
SELECT 'Vista inventory_by_material', COUNT(*) FROM inventory_by_material
UNION ALL
SELECT 'Vista workflows_by_status', COUNT(*) FROM workflows_by_status;

-- ========================================
-- ✅ FINALIZACIÓN DE CORRECCIONES
-- ========================================

SELECT 'Vistas corregidas exitosamente' as status;
