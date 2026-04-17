from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app import models
import hashlib

router = APIRouter(prefix="/auth", tags=["Autenticación"])


# Datos que chegan cando o cliente quere rexistrarse
class DatosRexistro(BaseModel):
    nome: str
    email: str
    contrasinal: str


# Datos que chegan cando o cliente quere iniciar sesión
class DatosLogin(BaseModel):
    email: str
    contrasinal: str


# Información do usuario que se devolve tras o rexistro ou login
class RespostaUsuario(BaseModel):
    id: int
    nome: str
    email: str

    class Config:
        from_attributes = True


# Xera o hash SHA-256 do contrasinal para gardalo de forma segura
def _hash_contrasinal(contrasinal: str) -> str:
    return hashlib.sha256(contrasinal.encode()).hexdigest()


# Rexistra un novo usuario validando os datos e comprobando que o correo non estea en uso
@router.post("/register", response_model=RespostaUsuario, status_code=201)
def rexistrarse(datos: DatosRexistro, db: Session = Depends(get_db)):
    # Validamos que o nome teña polo menos 2 caracteres
    if not datos.nome.strip() or len(datos.nome.strip()) < 2:
        raise HTTPException(status_code=422, detail="O nome debe ter polo menos 2 caracteres")

    # Validamos o formato básico do correo
    if "@" not in datos.email or "." not in datos.email.split("@")[-1]:
        raise HTTPException(status_code=422, detail="Formato de correo non válido")

    # Validamos que o contrasinal teña polo menos 8 caracteres
    if len(datos.contrasinal) < 8:
        raise HTTPException(status_code=422, detail="O contrasinal debe ter polo menos 8 caracteres")

    # Comprobamos se o correo xa está rexistrado
    existente = db.query(models.Usuario).filter(
        models.Usuario.email == datos.email.lower()
    ).first()
    if existente:
        raise HTTPException(
            status_code=409,
            detail="O correo xa está rexistrado. Inicia sesión."
        )

    # Creamos o novo usuario co contrasinal hasheado
    novo_usuario = models.Usuario(
        nome=datos.nome.strip(),
        email=datos.email.lower(),
        contrasinal=_hash_contrasinal(datos.contrasinal),
        e_admin=False,
    )
    db.add(novo_usuario)
    db.commit()
    db.refresh(novo_usuario)
    return novo_usuario


# Inicia sesión comprobando o correo e o contrasinal hasheado
@router.post("/login", response_model=RespostaUsuario)
def iniciar_sesion(datos: DatosLogin, db: Session = Depends(get_db)):
    # Buscamos o usuario polo correo
    usuario = db.query(models.Usuario).filter(
        models.Usuario.email == datos.email.lower()
    ).first()

    # Se non existe ou o contrasinal non coincide, rexeitamos o acceso
    if not usuario or usuario.contrasinal != _hash_contrasinal(datos.contrasinal):
        raise HTTPException(status_code=401, detail="Correo ou contrasinal incorrectos")

    return usuario
