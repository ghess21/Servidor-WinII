# 🗄️ Modelo Base - Media Quality Net
from datetime import datetime
from typing import Optional
from sqlalchemy import Column, DateTime, Integer, String, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Mapped, mapped_column

Base = declarative_base()

class TimestampMixin:
    """Mixin para agregar timestamps automáticos a todos los modelos"""
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

class SoftDeleteMixin:
    """Mixin para soft delete (marcar como eliminado sin borrar)"""
    
    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime, nullable=True, default=None
    )
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)

class AuditMixin:
    """Mixin para auditoría de cambios"""
    
    created_by: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    updated_by: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
