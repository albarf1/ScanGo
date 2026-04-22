from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models

router = APIRouter(prefix="/produtos", tags=["Produtos"])


# Datos que chegan cando o admin quere crear un produto
class PeticionProduto(BaseModel):
    nome: str
    prezo: float
    descripcion: Optional[str] = None
    stock: int
    codigo_qr: str


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


# Crea un novo produto no catálogo, comprobando que o código QR non estea repetido
@router.post("/", response_model=DatosProduto, status_code=201)
def crear_produto(datos: PeticionProduto, db: Session = Depends(get_db)):
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