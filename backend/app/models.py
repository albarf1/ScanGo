from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()


class Usuario(Base):
    # Taboa de usuarios da aplicacion
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    contrasinal = Column(String)
    e_admin = Column(Boolean, default=False)

    # Un usuario pode ter moitos carritos
    carritos = relationship("Carrito", back_populates="usuario")

    def __repr__(self):
        return f"<Usuario {self.nome}>"


class Producto(Base):
    # Taboa de produtos da tenda
    __tablename__ = "productos"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, index=True)
    prezo = Column(Float)
    descripcion = Column(String, nullable=True)
    stock = Column(Integer)
    codigo_qr = Column(String, unique=True, index=True)

    # Un produto pode estar en moitas liñas do carrito
    lineas_carrito = relationship("LineaCarrito", back_populates="producto")

    def __repr__(self):
        return f"<Producto {self.nome}>"


class Carrito(Base):
    # Taboa do carrito de compra de cada usuario
    __tablename__ = "carritos"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    activo = Column(Boolean, default=True)
    creado_en = Column(DateTime, default=datetime.utcnow)

    usuario = relationship("Usuario", back_populates="carritos")
    lineas = relationship("LineaCarrito", back_populates="carrito")

    def __repr__(self):
        return f"<Carrito {self.id} usuario={self.usuario_id} activo={self.activo}>"


class Compra(Base):
    # Taboa que rexistra cada compra finalizada
    __tablename__ = "compras"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))
    carrito_id = Column(Integer, ForeignKey("carritos.id"))
    total = Column(Float)
    data = Column(DateTime, default=datetime.utcnow)

    usuario = relationship("Usuario")
    carrito = relationship("Carrito")

    def __repr__(self):
        return f"<Compra {self.id} usuario={self.usuario_id} total={self.total}>"


class LineaCarrito(Base):
    # Cada liña representa un produto dentro do carrito
    __tablename__ = "lineas_carrito"

    id = Column(Integer, primary_key=True, index=True)
    carrito_id = Column(Integer, ForeignKey("carritos.id"))
    producto_id = Column(Integer, ForeignKey("productos.id"))
    cantidad = Column(Integer, default=1)

    carrito = relationship("Carrito", back_populates="lineas")
    producto = relationship("Producto", back_populates="lineas_carrito")

    def __repr__(self):
        # Mostramos o nome do produto se esta cargado, se non o ID do produto
        nome = self.producto.nome if self.producto else f"ID:{self.producto_id}"
        return f"<LineaCarrito {nome} x{self.cantidad}>"