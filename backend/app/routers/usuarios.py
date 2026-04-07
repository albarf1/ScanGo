from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

# Usuario por ahora sin contraseña
class DatoUsuario(BaseModel):
    id: int
    nome: str
    email: str
    e_admin: bool

    class Config:
        from_attributes = True

# Aqui obtemos a información dun usuario polo seu ID
@router.get("/{usuario_id}", response_model=DatoUsuario)
def obter_usuario(usuario_id: int, db: Session = Depends(get_db)):
    usuario = db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()
    
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario non atopado")
        
    return usuario
