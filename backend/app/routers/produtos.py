from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models
from app.auth_jwt import get_admin_user

router = APIRouter(prefix="/produtos", tags=["Produtos"])


# Datos que chegan cando o admin quere crear un produto
class PeticionProduto(BaseModel):
    nome: str
    prezo: float
    descripcion: Optional[str] = None
    stock: int
    codigo_qr: str


# Datos para editar un produto, todos os campos son opcionais
class PeticionEditarProduto(BaseModel):
    nome: Optional[str] = None
    prezo: Optional[float] = None
    descripcion: Optional[str] = None
    stock: Optional[int] = None
    codigo_qr: Optional[str] = None


# Informacion do produto que se envia ao cliente
class DatosProduto(BaseModel):
    id: int
    nome: str
    prezo: float
    descripcion: Optional[str] = None
    stock: int
    codigo_qr: str

    class Config:
        from_attributes = True


# Crea un novo produto no catálogo, só accesible para administradores autenticados
@router.post("/", response_model=DatosProduto, status_code=201)
def crear_produto(datos: PeticionProduto, db: Session = Depends(get_db), _=Depends(get_admin_user)):
    # Validamos que o prezo sexa maior que cero
    if datos.prezo <= 0:
        raise HTTPException(status_code=422, detail="O prezo debe ser maior que cero")

    # Validamos que o stock non sexa negativo
    if datos.stock < 0:
        raise HTTPException(status_code=422, detail="O stock non pode ser negativo")

    # Comprobamos que o código QR non estea xa en uso
    existente = db.query(models.Producto).filter(
        models.Producto.codigo_qr == datos.codigo_qr
    ).first()
    if existente:
        raise HTTPException(status_code=409, detail="O código QR xa está en uso")

    # Creamos e gardamos o novo produto
    novo = models.Producto(
        nome=datos.nome.strip(),
        prezo=datos.prezo,
        descripcion=datos.descripcion,
        stock=datos.stock,
        codigo_qr=datos.codigo_qr.strip(),
    )
    db.add(novo)
    db.commit()
    db.refresh(novo)
    return novo


# Busca un produto polo seu codigo QR, usase cando o cliente escanea
@router.get("/escanear/{codigo_qr}", response_model=DatosProduto)
def escanear_produto(codigo_qr: str, db: Session = Depends(get_db)):
    produto = db.query(models.Producto).filter(
        models.Producto.codigo_qr == codigo_qr
    ).first()

    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    return produto


# Lista todos os produtos da base de datos
@router.get("/", response_model=List[DatosProduto])
def listar_produtos(db: Session = Depends(get_db)):
    produtos = db.query(models.Producto).all()
    return produtos


# Obtemos un produto polo seu identidicador, usase para obter os detalles dun produto concreto
@router.get("/id/{produto_id}", response_model=DatosProduto)
def obter_produto(produto_id: int, db: Session = Depends(get_db)):
    produto = db.query(models.Producto).filter(
        models.Producto.id == produto_id
    ).first()

    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    return produto


# Edita os datos dun produto existente, só accesible para administradores
@router.put("/{produto_id}", response_model=DatosProduto)
def editar_produto(produto_id: int, datos: PeticionEditarProduto, db: Session = Depends(get_db), _=Depends(get_admin_user)):
    produto = db.query(models.Producto).filter(
        models.Producto.id == produto_id
    ).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    # Actualizamos só os campos que chegan na petición
    if datos.nome is not None:
        produto.nome = datos.nome.strip()
    if datos.prezo is not None:
        if datos.prezo <= 0:
            raise HTTPException(status_code=422, detail="O prezo debe ser maior que cero")
        produto.prezo = datos.prezo
    if datos.stock is not None:
        if datos.stock < 0:
            raise HTTPException(status_code=422, detail="O stock non pode ser negativo")
        produto.stock = datos.stock
    if datos.descripcion is not None:
        produto.descripcion = datos.descripcion
    if datos.codigo_qr is not None:
        # Comprobamos que o novo QR non estea en uso por outro produto
        existente = db.query(models.Producto).filter(
            models.Producto.codigo_qr == datos.codigo_qr,
            models.Producto.id != produto_id
        ).first()
        if existente:
            raise HTTPException(status_code=409, detail="O código QR xa está en uso")
        produto.codigo_qr = datos.codigo_qr.strip()

    db.commit()
    db.refresh(produto)
    return produto


# Elimina un produto do catálogo, só accesible para administradores
@router.delete("/{produto_id}", status_code=204)
def eliminar_produto(produto_id: int, db: Session = Depends(get_db), _=Depends(get_admin_user)):
    produto = db.query(models.Producto).filter(
        models.Producto.id == produto_id
    ).first()
    if not produto:
        raise HTTPException(status_code=404, detail="Produto non atopado")

    db.delete(produto)
    db.commit()
    return None