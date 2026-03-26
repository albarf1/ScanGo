from fastapi import FastAPI
from app.database import Base, engine
from app.routers import produtos, carrito

# Crea as taboas na base de datos ao arrancar
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ScanGo API",
    description="Backend da aplicacion ScanGo",
)

# Rexistramos os routers
app.include_router(produtos.router)
app.include_router(carrito.router)


@app.get("/")
def inicio():
    # Comprobacion de que o servidor esta activo
    return {"mensaxe": "ScanGo API funcionando"}