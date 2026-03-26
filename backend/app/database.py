from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Base

# Configuracion da base de datos
DATABASE_URL = "sqlite:///./scango.db"

# Creo o motor da conexion a BD
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

# SessionLocal e a clase para crear sesions coa BD
# autoflush=False: os cambios non se gardan automaticamente
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# Creamos todas as taboas na BD baseandose nos modelos definidos en models.py
Base.metadata.create_all(bind=engine)


def get_db():
    """
    Dependencia para FastAPI que proporciona unha sesion de BD a cada request.
    Usase nos endpoints como: db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        # Pechamos a sesion despois de usala
        db.close()