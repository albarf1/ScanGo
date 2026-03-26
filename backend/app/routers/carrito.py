from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models

router = APIRouter(prefix="/carrito", tags=["Carrito"])


# Datos que chegan cando o cliente quere engadir un produto
class PeticionEngadir(BaseModel):
    usuario_id: int
    codigo_qr: str
    cantidad: int = 1


# Informacion dunha liña do carrito
class ProductoEnCarrito(BaseModel):
    nome_produto: str
    prezo_unitario: float
    cantidad: int
    subtotal: float


# Informacion completa do carrito co total
class CarritoDetalle(BaseModel):
    id: int
    lineas: List[ProductoEnCarrito]
    total: float


# Engade un produto ao carrito activo do usuario
@router.post("/engadir", status_code=201)
def engadir_produto(datos: PeticionEngadir, db: Session = Depends(get_db)):
    # Buscamos o produto polo codigo QR
    produto = db.query(models.Producto).filter(
        models.Producto.codigo_qr == datos.codigo_qr
    ).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    # Buscamos o carrito activo do usuario ou creamos un novo
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == datos.usuario_id,
        models.Carrito.activo == True
    ).first()

    if not carrito:
        carrito = models.Carrito(usuario_id=datos.usuario_id)
        db.add(carrito)
        db.commit()
        db.refresh(carrito)

    # Se o produto xa esta no carrito, sumamos a cantidade
    linea = db.query(models.LineaCarrito).filter(
        models.LineaCarrito.carrito_id == carrito.id,
        models.LineaCarrito.producto_id == produto.id
    ).first()

    if linea:
        linea.cantidad += datos.cantidad
    else:
        # Se non esta, creamos unha nova liña no carrito
        linea = models.LineaCarrito(
            carrito_id=carrito.id,
            producto_id=produto.id,
            cantidad=datos.cantidad
        )
        db.add(linea)

    db.commit()
    return {"mensaxe": f"{produto.nome} engadido ao carrito ✓"}


# Devolve o carrito activo do usuario co total calculado
@router.get("/ver/{usuario_id}", response_model=CarritoDetalle)
def ver_carrito(usuario_id: int, db: Session = Depends(get_db)):
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_id,
        models.Carrito.activo == True
    ).first()

    if not carrito:
        raise HTTPException(status_code=404, detail="Non temos ningun carrito activo")

    # Calculamos o total e montamos a resposta
    lineas = []
    total = 0.0

    for l in carrito.lineas:
        subtotal = l.producto.prezo * l.cantidad
        total += subtotal
        lineas.append(ProductoEnCarrito(
            nome_produto=l.producto.nome,
            prezo_unitario=l.producto.prezo,
            cantidad=l.cantidad,
            subtotal=subtotal
        ))

    return CarritoDetalle(id=carrito.id, lineas=lineas, total=total)


# Elimina un produto do carrito
@router.delete("/eliminar/{usuario_id}/{codigo_qr}")
def eliminar_produto(usuario_id: int, codigo_qr: str, db: Session = Depends(get_db)):
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_id,
        models.Carrito.activo == True
    ).first()

    if not carrito:
        raise HTTPException(status_code=404, detail="Non temos ningun carrito activo")

    produto = db.query(models.Producto).filter(
        models.Producto.codigo_qr == codigo_qr
    ).first()

    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    # Buscamos a liña e eliminamola
    linea = db.query(models.LineaCarrito).filter(
        models.LineaCarrito.carrito_id == carrito.id,
        models.LineaCarrito.producto_id == produto.id
    ).first()

    if not linea:
        raise HTTPException(status_code=404, detail="O produto non está no carrito")

    db.delete(linea)
    db.commit()
    return {"mensaxe": f"{produto.nome} eliminado do carrito "}