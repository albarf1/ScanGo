from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import Base, engine
from app.routers import produtos, carrito, usuarios

# Crea as taboas na base de datos ao arrancar
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ScanGo API",
    description="Backend da aplicacion ScanGo",
)

# Permite que a app Flutter Web faga peticións ao backend

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # calquerorixen
    allow_credentials=True,
    allow_methods=["*"], # Permite GET, POST, DELETE
    allow_headers=["*"],
)

# Rexistramos os routers
app.include_router(produtos.router)
app.include_router(carrito.router)
app.include_router(usuarios.router)

@app.get("/")
def inicio():
    # Comprobacion de que o servidor esta activo
    return {"mensaxe": "ScanGo API funcionando"}
