#!/usr/bin/env python3
"""
🧠 Servicio de IA para Análisis de Mensajes de WhatsApp - Media Quality Net
Analiza conversaciones, extrae productos, materiales y crea flujos de trabajo
"""

import os
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime
import json

from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import openai
import redis.asyncio as redis
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

# Configuración de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuración de la aplicación
app = FastAPI(
    title="MQN AI Analysis Service",
    description="Servicio de IA para análisis de mensajes de WhatsApp",
    version="1.0.0"
)

# Configuración de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuración de variables de entorno
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://mqn_user:mqn_password_2024@postgres_mqn:5432/mqn_ecosistema")
REDIS_URL = os.getenv("REDIS_URL", "redis://:mqn_redis_2024@redis_mqn:6379")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

# Configuración de OpenAI
if OPENAI_API_KEY:
    openai.api_key = OPENAI_API_KEY

# Configuración de base de datos con timeouts
engine = create_async_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600,
    connect_args={
        "connect_timeout": 30,
        "command_timeout": 60,
    }
)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

# Configuración de Redis con pool de conexiones y timeouts
redis_client = redis.from_url(
    REDIS_URL,
    encoding="utf-8",
    decode_responses=True,
    socket_connect_timeout=10,
    socket_timeout=10,
    retry_on_timeout=True,
    health_check_interval=30
)

# Modelos de datos
class WhatsAppMessage(BaseModel):
    """Modelo para mensajes de WhatsApp"""
    message_id: str = Field(..., description="ID único del mensaje")
    chat_id: str = Field(..., description="ID del chat")
    sender_id: str = Field(..., description="ID del remitente")
    message_type: str = Field(..., description="Tipo de mensaje (text, audio, image)")
    content: str = Field(..., description="Contenido del mensaje")
    timestamp: datetime = Field(..., description="Timestamp del mensaje")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Metadatos adicionales")

class AnalysisResult(BaseModel):
    """Modelo para resultados del análisis"""
    message_id: str
    analysis_type: str
    extracted_products: List[Dict[str, Any]]
    extracted_materials: List[Dict[str, Any]]
    client_intent: str
    urgency_level: str
    suggested_actions: List[str]
    confidence_score: float
    analysis_timestamp: datetime
    raw_analysis: Dict[str, Any]

class ProductExtraction(BaseModel):
    """Modelo para productos extraídos"""
    product_name: str
    product_type: str
    dimensions: Optional[str]
    quantity: Optional[int]
    materials: List[str]
    techniques: List[str]
    special_requirements: Optional[str]
    estimated_price: Optional[float]

# Funciones de análisis de IA
async def analyze_message_with_ai(message: WhatsAppMessage) -> Dict[str, Any]:
    """
    Analiza un mensaje usando OpenAI GPT para extraer información relevante
    """
    try:
        if not OPENAI_API_KEY:
            raise HTTPException(status_code=500, detail="OpenAI API key no configurada")
        
        # Prompt para análisis de mensajes de WhatsApp
        system_prompt = """
        Eres un asistente especializado en análisis de mensajes de WhatsApp para una empresa de publicidad impresa.
        Tu tarea es analizar mensajes y extraer información sobre:
        
        1. PRODUCTOS SOLICITADOS: letreros, impresiones, sublimación, DTF, serigrafía, etc.
        2. MATERIALES: acrílico, PVC, aluminio, vinil, etc.
        3. TÉCNICAS: laser, CNC, serigrafía, hot stamping, etc.
        4. DIMENSIONES: medidas, cantidades, especificaciones
        5. INTENCIÓN DEL CLIENTE: consulta, cotización, pedido, urgencia
        
        Responde en formato JSON con la siguiente estructura:
        {
            "products": [
                {
                    "name": "nombre del producto",
                    "type": "tipo de producto",
                    "dimensions": "dimensiones si se mencionan",
                    "quantity": "cantidad si se menciona",
                    "materials": ["material1", "material2"],
                    "techniques": ["técnica1", "técnica2"],
                    "special_requirements": "requisitos especiales si los hay"
                }
            ],
            "client_intent": "consulta|cotización|pedido|urgencia",
            "urgency_level": "baja|media|alta|crítica",
            "suggested_actions": ["acción1", "acción2"],
            "confidence_score": 0.95
        }
        """
        
        user_prompt = f"""
        Analiza este mensaje de WhatsApp:
        
        CONTENIDO: {message.content}
        TIPO: {message.message_type}
        REMITENTE: {message.sender_id}
        TIMESTAMP: {message.timestamp}
        
        Extrae toda la información relevante sobre productos, materiales y intenciones del cliente.
        """
        
        # Configurar timeout para OpenAI
        import asyncio
        
        try:
            response = await asyncio.wait_for(
                openai.ChatCompletion.acreate(
                    model="gpt-4",
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt}
                    ],
                    temperature=0.1,
                    max_tokens=1000,
                    timeout=30  # 30 segundos timeout
                ),
                timeout=45  # 45 segundos timeout total
            )
        except asyncio.TimeoutError:
            raise HTTPException(status_code=504, detail="Timeout en análisis de IA - servicio demoró demasiado")
        
        # Parsear respuesta JSON
        analysis_text = response.choices[0].message.content
        analysis_data = json.loads(analysis_text)
        
        return analysis_data
        
    except Exception as e:
        logger.error(f"Error en análisis de IA: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis de IA: {str(e)}")

async def process_audio_message(audio_url: str) -> str:
    """
    Procesa mensajes de audio usando Whisper para convertirlos a texto
    """
    try:
        # Aquí implementarías la lógica para descargar el audio y procesarlo con Whisper
        # Por ahora retornamos un placeholder
        return "Mensaje de audio procesado (implementar Whisper)"
        
    except Exception as e:
        logger.error(f"Error procesando audio: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error procesando audio: {str(e)}")

# Endpoints de la API
@app.get("/health")
async def health_check():
    """Endpoint de salud del servicio"""
    return {
        "status": "healthy",
        "service": "MQN AI Analysis Service",
        "timestamp": datetime.utcnow(),
        "version": "1.0.0"
    }

@app.post("/analyze/message", response_model=AnalysisResult)
async def analyze_whatsapp_message(
    message: WhatsAppMessage,
    background_tasks: BackgroundTasks
):
    """
    Analiza un mensaje de WhatsApp y extrae información relevante
    """
    try:
        logger.info(f"Analizando mensaje: {message.message_id}")
        
        # Analizar mensaje con IA
        analysis_result = await analyze_message_with_ai(message)
        
        # Crear resultado estructurado
        result = AnalysisResult(
            message_id=message.message_id,
            analysis_type="whatsapp_message",
            extracted_products=analysis_result.get("products", []),
            extracted_materials=analysis_result.get("materials", []),
            client_intent=analysis_result.get("client_intent", "consulta"),
            urgency_level=analysis_result.get("urgency_level", "baja"),
            suggested_actions=analysis_result.get("suggested_actions", []),
            confidence_score=analysis_result.get("confidence_score", 0.0),
            analysis_timestamp=datetime.utcnow(),
            raw_analysis=analysis_result
        )
        
        # Guardar en Redis para cache con timeout
        try:
            await asyncio.wait_for(
                redis_client.setex(
                    f"analysis:{message.message_id}",
                    3600,  # 1 hora
                    json.dumps(result.dict())
                ),
                timeout=10  # 10 segundos timeout para Redis
            )
        except asyncio.TimeoutError:
            logger.warning(f"Timeout guardando en Redis para mensaje {message.message_id}")
            # Continuar sin fallar - el cache no es crítico
        
        # Tarea en background para guardar en base de datos
        background_tasks.add_task(save_analysis_to_db, result)
        
        return result
        
    except Exception as e:
        logger.error(f"Error analizando mensaje: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis: {str(e)}")

@app.post("/analyze/audio")
async def analyze_audio_message(audio_url: str):
    """
    Analiza un mensaje de audio y lo convierte a texto
    """
    try:
        text_content = await process_audio_message(audio_url)
        return {
            "audio_url": audio_url,
            "text_content": text_content,
            "processed_at": datetime.utcnow()
        }
        
    except Exception as e:
        logger.error(f"Error analizando audio: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error en análisis de audio: {str(e)}")

@app.get("/analysis/{message_id}")
async def get_analysis_result(message_id: str):
    """
    Obtiene el resultado de un análisis previo
    """
    try:
        # Buscar en cache primero con timeout
        try:
            cached_result = await asyncio.wait_for(
                redis_client.get(f"analysis:{message_id}"),
                timeout=5  # 5 segundos timeout para búsqueda
            )
            if cached_result:
                return json.loads(cached_result)
        except asyncio.TimeoutError:
            logger.warning(f"Timeout buscando en Redis para mensaje {message_id}")
            # Continuar a buscar en base de datos
        
        # Si no está en cache, buscar en base de datos
        # Implementar búsqueda en DB
        raise HTTPException(status_code=404, detail="Análisis no encontrado")
        
    except Exception as e:
        logger.error(f"Error obteniendo análisis: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error obteniendo análisis: {str(e)}")

# Funciones auxiliares
async def save_analysis_to_db(analysis: AnalysisResult):
    """
    Guarda el resultado del análisis en la base de datos
    """
    try:
        # Implementar guardado en base de datos
        logger.info(f"Guardando análisis en DB: {analysis.message_id}")
        
    except Exception as e:
        logger.error(f"Error guardando en DB: {str(e)}")

# Eventos de la aplicación
@app.on_event("startup")
async def startup_event():
    """Evento de inicio de la aplicación"""
    logger.info("🚀 Iniciando MQN AI Analysis Service")
    
    # Verificar conexión a Redis
    try:
        await redis_client.ping()
        logger.info("✅ Conexión a Redis establecida")
    except Exception as e:
        logger.error(f"❌ Error conectando a Redis: {str(e)}")

@app.on_event("shutdown")
async def shutdown_event():
    """Evento de cierre de la aplicación"""
    logger.info("🛑 Cerrando MQN AI Analysis Service")
    
    # Cerrar conexiones
    await redis_client.close()
    await engine.dispose()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
