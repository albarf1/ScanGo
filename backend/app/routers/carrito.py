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


# Datos para actualizar a cantidade dunha liña do carrito
class PeticionActualizar(BaseModel):
    cantidad: int


# Informacion dunha liña do ticket de compra
class LineaTicket(BaseModel):
    nome_produto: str
    prezo_unitario: float
    cantidad: int
    subtotal: float


# Resposta ao finalizar a compra: ticket co resumo
class RespostaCompra(BaseModel):
    compra_id: int
    total: float
    data: str
    lineas: List[LineaTicket]


# Informacion dunha liña do carrito
class ProductoEnCarrito(BaseModel):
    nome_produto: str
    prezo_unitario: float
    cantidad: int
    subtotal: float
    codigo_qr: str


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
    return {"mensaxe": f"{produto.nome} engadido ao carrito "}


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
            subtotal=subtotal,
            codigo_qr=l.producto.codigo_qr
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


# Actualiza a cantidade dun produto no carrito
@router.put("/actualizar/{usuario_id}/{codigo_qr}")
def actualizar_cantidad(usuario_id: int, codigo_qr: str, datos: PeticionActualizar, db: Session = Depends(get_db)):
    if datos.cantidad < 1:
        raise HTTPException(status_code=400, detail="A cantidade debe ser maior que cero")

    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_id,
        models.Carrito.activo == True
    ).first()
    if not carrito:
        raise HTTPException(status_code=404, detail="Non hai carrito activo")

    produto = db.query(models.Producto).filter(
        models.Producto.codigo_qr == codigo_qr
    ).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    linea = db.query(models.LineaCarrito).filter(
        models.LineaCarrito.carrito_id == carrito.id,
        models.LineaCarrito.producto_id == produto.id
    ).first()
    if not linea:
        raise HTTPException(status_code=404, detail="O produto non está no carrito")

    linea.cantidad = datos.cantidad
    db.commit()
    return {"mensaxe": f"Cantidade actualizada a {datos.cantidad}"}


# Finaliza a compra: garda o rexistro, marca o carrito como inactivo e devolve o ticket
@router.post("/finalizar/{usuario_id}", response_model=RespostaCompra, status_code=201)
def finalizar_compra(usuario_id: int, db: Session = Depends(get_db)):
    # Buscamos o carrito activo do usuario
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_id,
        models.Carrito.activo == True
    ).first()

    if not carrito:
        raise HTTPException(status_code=404, detail="Non hai carrito activo para finalizar")

    if not carrito.lineas:
        raise HTTPException(status_code=400, detail="O carrito está baleiro")

    # Calculamos o total
    total = sum(l.producto.prezo * l.cantidad for l in carrito.lineas)

    # Gardamos o rexistro da compra
    compra = models.Compra(
        usuario_id=usuario_id,
        carrito_id=carrito.id,
        total=total,
    )
    db.add(compra)

    # Marcamos o carrito como inactivo
    carrito.activo = False
    db.commit()
    db.refresh(compra)

    # Montamos as liñas do ticket
    lineas = [
        LineaTicket(
            nome_produto=l.producto.nome,
            prezo_unitario=l.producto.prezo,
            cantidad=l.cantidad,
            subtotal=l.producto.prezo * l.cantidad,
        )
        for l in carrito.lineas
    ]

    return RespostaCompra(
        compra_id=compra.id,
        total=total,
        data=compra.data.strftime("%d/%m/%Y %H:%M"),
        lineas=lineas,
    )