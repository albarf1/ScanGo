from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models
from app.auth_jwt import get_current_user

router = APIRouter(prefix="/carrito", tags=["Carrito"])


# Datos que chegan cando o cliente quere engadir un produto
class PeticionEngadir(BaseModel):
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


# Engade un produto ao carrito activo do usuario autenticado
@router.post("/engadir", status_code=201)
def engadir_produto(datos: PeticionEngadir, db: Session = Depends(get_db), usuario_actual: models.Usuario = Depends(get_current_user)):
    # Buscamos o produto polo codigo QR
    produto = db.query(models.Producto).filter(
        models.Producto.codigo_qr == datos.codigo_qr
    ).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    # Buscamos o carrito activo do usuario ou creamos un novo
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_actual.id,
        models.Carrito.activo == True
    ).first()

    if not carrito:
        carrito = models.Carrito(usuario_id=usuario_actual.id)
        db.add(carrito)
        db.commit()
        db.refresh(carrito)

    # Se o produto xa esta no carrito, sumamos a cantidade
    linea = db.query(models.LineaCarrito).filter(
        models.LineaCarrito.carrito_id == carrito.id,
        models.LineaCarrito.producto_id == produto.id
    ).first()

    # Comprobamos que hai stock suficiente tendo en conta o que xa está no carrito
    cantidad_en_carrito = linea.cantidad if linea else 0
    if cantidad_en_carrito + datos.cantidad > produto.stock:
        dispoñible = produto.stock - cantidad_en_carrito
        raise HTTPException(
            status_code=400,
            detail=f"Stock insuficiente. Só quedan {dispoñible} unidades dispoñibles de {produto.nome}"
        )

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


# Devolve o carrito activo do usuario autenticado co total calculado
@router.get("/ver", response_model=CarritoDetalle)
def ver_carrito(db: Session = Depends(get_db), usuario_actual: models.Usuario = Depends(get_current_user)):
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_actual.id,
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


# Elimina un produto do carrito do usuario autenticado
@router.delete("/eliminar/{codigo_qr}")
def eliminar_produto(codigo_qr: str, db: Session = Depends(get_db), usuario_actual: models.Usuario = Depends(get_current_user)):
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_actual.id,
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


# Actualiza a cantidade dun produto no carrito do usuario autenticado
@router.put("/actualizar/{codigo_qr}")
def actualizar_cantidad(codigo_qr: str, datos: PeticionActualizar, db: Session = Depends(get_db), usuario_actual: models.Usuario = Depends(get_current_user)):
    if datos.cantidad < 1:
        raise HTTPException(status_code=400, detail="A cantidade debe ser maior que cero")

    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_actual.id,
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

    # Comprobamos que a nova cantidade non supera o stock dispoñible
    if datos.cantidad > produto.stock:
        raise HTTPException(
            status_code=400,
            detail=f"Stock insuficiente. Só quedan {produto.stock} unidades dispoñibles de {produto.nome}"
        )

    linea.cantidad = datos.cantidad
    db.commit()
    return {"mensaxe": f"Cantidade actualizada a {datos.cantidad}"}


# Finaliza a compra do usuario autenticado: garda o rexistro, marca o carrito como inactivo e devolve o ticket
@router.post("/finalizar", response_model=RespostaCompra, status_code=201)
def finalizar_compra(db: Session = Depends(get_db), usuario_actual: models.Usuario = Depends(get_current_user)):
    # Buscamos o carrito activo do usuario
    carrito = db.query(models.Carrito).filter(
        models.Carrito.usuario_id == usuario_actual.id,
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
        usuario_id=usuario_actual.id,
        carrito_id=carrito.id,
        total=total,
    )
    db.add(compra)

    # Marcamos o carrito como inactivo e descontamos o stock de cada produto
    carrito.activo = False
    for l in carrito.lineas:
        l.producto.stock -= l.cantidad
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
