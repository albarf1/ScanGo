from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.database import get_db
from app import models

# Clave secreta para asinar os tokens (en produción iría nunha variable de entorno)
SECRET_KEY = "scango-secret-key-2024"
ALGORITHM = "HS256"
# Tempo de expiración do token: 24 horas
EXPIRACION_HORAS = 24

# Esquema de autenticación Bearer para as cabeceiras HTTP
_bearer = HTTPBearer()


# Xera un token JWT co ID e email do usuario
def crear_token(usuario_id: int, email: str) -> str:
    """Xera e devolve un token JWT asinado con expiración de 24 horas."""
    expiracion = datetime.now(timezone.utc) + timedelta(hours=EXPIRACION_HORAS)
    datos = {"sub": str(usuario_id), "email": email, "exp": expiracion}
    return jwt.encode(datos, SECRET_KEY, algorithm=ALGORITHM)


# Dependencia que valida o token e devolve o usuario autenticado
def get_current_user(
    credenciais: HTTPAuthorizationCredentials = Depends(_bearer),
    db: Session = Depends(get_db),
) -> models.Usuario:
    """Valida o token Bearer da cabeceira e devolve o usuario correspondente da BD.

    Raises:
        HTTPException 401: Se o token é inválido, está expirado ou o usuario non existe.
    """
    erro_credenciais = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token non válido ou expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(credenciais.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        usuario_id: str = payload.get("sub")
        if usuario_id is None:
            raise erro_credenciais
    except JWTError:
        raise erro_credenciais

    # Buscamos o usuario na base de datos
    usuario = db.query(models.Usuario).filter(
        models.Usuario.id == int(usuario_id)
    ).first()
    if usuario is None:
        raise erro_credenciais
    return usuario


# Dependencia que ademais verifica que o usuario é administrador
def get_admin_user(usuario: models.Usuario = Depends(get_current_user)) -> models.Usuario:
    """Reutiliza get_current_user e lanza 403 se o usuario non é administrador."""
    if not usuario.e_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Acceso restrinxido a administradores",
        )
    return usuario
