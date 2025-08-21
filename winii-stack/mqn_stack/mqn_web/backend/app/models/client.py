# 👥 Modelo de Clientes y Ventas - Media Quality Net
from typing import Optional, List
from sqlalchemy import Column, String, Integer, Float, Text, Boolean, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum

from .base import Base, TimestampMixin, SoftDeleteMixin, AuditMixin

class ClientType(str, enum.Enum):
    """Tipos de clientes"""
    INDIVIDUAL = "individual"
    BUSINESS = "business"
    WHOLESALE = "wholesale"
    REGULAR = "regular"

class PaymentMethod(str, enum.Enum):
    """Métodos de pago"""
    CASH = "cash"
    BANK_TRANSFER = "bank_transfer"
    CREDIT_CARD = "credit_card"
    DEBIT_CARD = "debit_card"
    CHECK = "check"
    DIGITAL_WALLET = "digital_wallet"

class OrderStatus(str, enum.Enum):
    """Estados de las órdenes"""
    PENDING = "pending"
    CONFIRMED = "confirmed"
    IN_DESIGN = "in_design"
    DESIGN_APPROVED = "design_approved"
    IN_PRODUCTION = "in_production"
    PRODUCTION_COMPLETED = "production_completed"
    READY_FOR_DELIVERY = "ready_for_delivery"
    DELIVERED = "delivered"
    INSTALLED = "installed"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class Client(Base, TimestampMixin, SoftDeleteMixin, AuditMixin):
    """Modelo principal de clientes"""
    
    __tablename__ = "clients"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    client_type: Mapped[ClientType] = mapped_column(Enum(ClientType), default=ClientType.INDIVIDUAL)
    
    # Información de contacto
    email: Mapped[Optional[str]] = mapped_column(String(200), nullable=True, unique=True)
    phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    whatsapp: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    
    # Dirección
    address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    city: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    state: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    postal_code: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    
    # Información fiscal (opcional)
    tax_id: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    fiscal_name: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    fiscal_address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    requires_invoice: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Preferencias y notas
    preferences: Mapped[Optional[dict]] = mapped_column(JSONB, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Métricas del cliente
    total_orders: Mapped[int] = mapped_column(Integer, default=0)
    total_spent: Mapped[float] = mapped_column(Float, default=0.0)
    last_order_date: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Relaciones
    orders = relationship("Order", back_populates="client")
    contacts = relationship("ClientContact", back_populates="client")

class ClientContact(Base, TimestampMixin, SoftDeleteMixin):
    """Contactos adicionales del cliente"""
    
    __tablename__ = "client_contacts"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    client_id: Mapped[int] = mapped_column(ForeignKey("clients.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    email: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    is_primary: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Relaciones
    client = relationship("Client", back_populates="contacts")

class Order(Base, TimestampMixin, SoftDeleteMixin, AuditMixin):
    """Órdenes de clientes"""
    
    __tablename__ = "orders"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    order_number: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    client_id: Mapped[int] = mapped_column(ForeignKey("clients.id"), nullable=False)
    
    # Estado y prioridad
    status: Mapped[OrderStatus] = mapped_column(Enum(OrderStatus), default=OrderStatus.PENDING)
    priority: Mapped[str] = mapped_column(String(20), default="normal")  # low, normal, high, urgent
    
    # Fechas importantes
    requested_delivery_date: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    estimated_completion_date: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    actual_completion_date: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Información del proyecto
    project_name: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    project_description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    special_requirements: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Archivos de diseño
    design_files: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    reference_images: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    
    # Precios y pagos
    subtotal: Mapped[float] = mapped_column(Float, default=0.0)
    tax_amount: Mapped[float] = mapped_column(Float, default=0.0)
    discount_amount: Mapped[float] = mapped_column(Float, default=0.0)
    total_amount: Mapped[float] = mapped_column(Float, default=0.0)
    paid_amount: Mapped[float] = mapped_column(Float, default=0.0)
    balance_due: Mapped[float] = mapped_column(Float, default=0.0)
    
    # Método de pago
    payment_method: Mapped[Optional[PaymentMethod]] = mapped_column(Enum(PaymentMethod), nullable=True)
    payment_status: Mapped[str] = mapped_column(String(20), default="pending")  # pending, partial, paid
    
    # Relaciones
    client = relationship("Client", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")
    tasks = relationship("ProductionTask", back_populates="order")
    payments = relationship("Payment", back_populates="order")

class OrderItem(Base, TimestampMixin, SoftDeleteMixin):
    """Items individuales de una orden"""
    
    __tablename__ = "order_items"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), nullable=False)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False)
    product_variant_id: Mapped[Optional[int]] = mapped_column(ForeignKey("product_variants.id"), nullable=True)
    
    # Especificaciones del item
    quantity: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    unit_price: Mapped[float] = mapped_column(Float, nullable=False)
    total_price: Mapped[float] = mapped_column(Float, nullable=False)
    
    # Personalización
    custom_dimensions: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    custom_materials: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    custom_techniques: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    custom_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Archivos específicos del item
    design_file: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    production_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Relaciones
    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="orders")
    variant = relationship("ProductVariant")

class Payment(Base, TimestampMixin, SoftDeleteMixin, AuditMixin):
    """Pagos realizados por los clientes"""
    
    __tablename__ = "payments"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), nullable=False)
    
    # Información del pago
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    payment_method: Mapped[PaymentMethod] = mapped_column(Enum(PaymentMethod), nullable=False)
    payment_date: Mapped[str] = mapped_column(String(50), nullable=False)
    
    # Referencias del pago
    reference_number: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    transaction_id: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    
    # Estado del pago
    status: Mapped[str] = mapped_column(String(20), default="completed")  # pending, completed, failed, refunded
    
    # Notas adicionales
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Relaciones
    order = relationship("Order", back_populates="payments")
