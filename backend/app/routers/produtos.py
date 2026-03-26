from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models

router = APIRouter(prefix="/produtos", tags=["Produtos"])


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