# 🛍️ Modelo de Productos - Media Quality Net
from typing import Optional, List
from sqlalchemy import Column, String, Integer, Float, Text, Boolean, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import ARRAY, JSONB
import enum

from .base import Base, TimestampMixin, SoftDeleteMixin, AuditMixin

class ProductType(str, enum.Enum):
    """Tipos de productos según el catálogo de MQN"""
    LETRERO_BASICO = "letrero_basico"
    LETRERO_ARTE = "letrero_arte"
    GLOBO = "globo"
    CAJA_LUZ = "caja_luz"
    LETRAS_CORPOREAS = "letras_corporeas"
    NEON_FLEX = "neon_flex"
    IMPRESION_GRAN_FORMATO = "impresion_gran_formato"
    IMPRESION_LASER = "impresion_laser"
    SUBLIMACION = "sublimacion"
    DTF_TEXTIL = "dtf_textil"
    DTF_UV = "dtf_uv"
    SERIGRAFIA = "serigrafia"
    FOIL_REACTIVO = "foil_reactivo"
    HOT_STAMPING = "hot_stamping"
    OFFSET_TRADICIONAL = "offset_tradicional"
    OFFSET_DIGITAL = "offset_digital"
    INKJET = "inkjet"
    CNC_ROUTER = "cnc_router"
    CNC_LASER = "cnc_laser"
    IMPRESION_3D = "impresion_3d"

class MaterialType(str, enum.Enum):
    """Tipos de materiales disponibles"""
    ACRILICO_3MM = "acrilico_3mm"
    ACRILICO_6MM = "acrilico_6mm"
    PVC_3MM = "pvc_3mm"
    PVC_6MM = "pvc_6mm"
    PVC_10MM = "pvc_10mm"
    ALUMINIO_CAL23 = "aluminio_cal23"
    ALUMINIO_CEPILLADO = "aluminio_cepillado"
    ALUMINIO_ESPEJO = "aluminio_espejo"
    ALUMINIO_NATURAL = "aluminio_natural"
    LED_COLOR_FIJO = "led_color_fijo"
    LED_RGB = "led_rgb"
    LED_PIXEL = "led_pixel"
    NEON_FLEX = "neon_flex"
    VINIL = "vinil"
    LONA = "lona"
    MADERA = "madera"
    METAL = "metal"

class Product(Base, TimestampMixin, SoftDeleteMixin, AuditMixin):
    """Modelo principal de productos"""
    
    __tablename__ = "products"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    product_type: Mapped[ProductType] = mapped_column(Enum(ProductType), nullable=False)
    
    # Especificaciones técnicas
    dimensions: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # "50x60cm"
    materials: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    techniques: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    
    # Precios
    base_price: Mapped[float] = mapped_column(Float, nullable=False)
    price_currency: Mapped[str] = mapped_column(String(3), default="MXN")
    price_variations: Mapped[Optional[dict]] = mapped_column(JSONB, nullable=True)
    
    # Características
    has_lighting: Mapped[bool] = mapped_column(Boolean, default=False)
    lighting_type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    is_customizable: Mapped[bool] = mapped_column(Boolean, default=True)
    production_time_days: Mapped[int] = mapped_column(Integer, default=1)
    
    # Imágenes y archivos
    main_image: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    gallery_images: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    design_files: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    
    # SEO y marketing
    seo_title: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    seo_description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    keywords: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Relaciones
    category_id: Mapped[Optional[int]] = mapped_column(ForeignKey("categories.id"), nullable=True)
    supplier_id: Mapped[Optional[int]] = mapped_column(ForeignKey("suppliers.id"), nullable=True)
    
    # Relaciones
    category = relationship("Category", back_populates="products")
    supplier = relationship("Supplier", back_populates="products")
    variants = relationship("ProductVariant", back_populates="product")
    orders = relationship("OrderItem", back_populates="product")

class Category(Base, TimestampMixin, SoftDeleteMixin):
    """Categorías de productos"""
    
    __tablename__ = "categories"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    parent_id: Mapped[Optional[int]] = mapped_column(ForeignKey("categories.id"), nullable=True)
    image: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    
    # Relaciones
    products = relationship("Product", back_populates="category")
    subcategories = relationship("Category", backref=relationship("parent", remote_side=[id]))

class ProductVariant(Base, TimestampMixin, SoftDeleteMixin):
    """Variantes de productos (tamaños, colores, materiales)"""
    
    __tablename__ = "product_variants"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    sku: Mapped[Optional[str]] = mapped_column(String(100), nullable=True, unique=True)
    
    # Especificaciones de la variante
    dimensions: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    material: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    color: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Precio de la variante
    price_adjustment: Mapped[float] = mapped_column(Float, default=0.0)
    final_price: Mapped[float] = mapped_column(Float, nullable=False)
    
    # Stock y disponibilidad
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)
    min_order_quantity: Mapped[int] = mapped_column(Integer, default=1)
    
    # Relaciones
    product = relationship("Product", back_populates="variants")

class Supplier(Base, TimestampMixin, SoftDeleteMixin, AuditMixin):
    """Proveedores de materiales y servicios"""
    
    __tablename__ = "suppliers"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    contact_person: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    email: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    
    # Información fiscal
    tax_id: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    fiscal_name: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    fiscal_address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Servicios y materiales
    services: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    materials: Mapped[List[str]] = mapped_column(ARRAY(String), nullable=True)
    
    # Información de pago
    payment_terms: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    preferred_payment_method: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Relaciones
    products = relationship("Product", back_populates="supplier")
    orders = relationship("SupplierOrder", back_populates="supplier")
    payments = relationship("SupplierPayment", back_populates="supplier")
