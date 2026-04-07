"""
Script para cargar datos de proba 
    print("Creando usuarios...")
    usuario1 = Usuario(
        id=1,
        nome="Alba Rodríguez",
        email="alba@scango.com",
        contrasinal="password123",
        e_admin=False
    )
    usuario2 = Usuario(
        id=2,
        nome="Jacobo Martinez",
        email="jacobo@scango.com",
        contrasinal="password123",
        e_admin=False
    )
    
    db.add(usuario1)
    db.add(usuario2)
    db.commit()
    print("Usuarios creados correctamente")

"""

from app.database import SessionLocal
from app.models import Usuario, Producto, Carrito, LineaCarrito


def cargar_datos():
    """Función principal que carga todos os datos de proba"""
    # Crear sesión da base de datos
    db = SessionLocal()

    # Crear usuarios de proba
    print("Creando usuarios...")
    usuario1 = Usuario(id=1, nome="Alba Rodríguez", email="alba@scango.com")
    usuario2 = Usuario(id=2, nome="Jacobo Martinez", email="jacobo@scango.com")
    
    db.add(usuario1)
    db.add(usuario2)
    db.commit()
    print("Usuarios creados correctamente")
    
    #  productos de proba
    print("Creando productos...")
    productos = [
        Producto(
            nome="Leite enteiro 1L",
            prezo=1.29,
            stock=50,
            codigo_qr="PROD001",
            descripcion="Leite integral pasteurizado"
        ),
        Producto(
            nome="Pan integral 500g",
            prezo=1.99,
            stock=30,
            codigo_qr="PROD002",
            descripcion="Pan de trigo integral "
        ),
        Producto(
            nome="Queso semicurado 250g",
            prezo=3.45,
            stock=20,
            codigo_qr="PROD003",
            descripcion="Queso semicurado de vaca"
        ),
        Producto(
            nome="Aceite de oliva 1L",
            prezo=6.99,
            stock=15,
            codigo_qr="PROD004",
            descripcion="Aceite de oliva virgen extra"
        ),
        Producto(
            nome="Auga mineral 6x500ml",
            prezo=1.50,
            stock=100,
            codigo_qr="PROD005",
            descripcion="Pack de 6 botellas de auga mineral"
        ),
        Producto(
            nome="Café molido 250g",
            prezo=2.79,
            stock=40,
            codigo_qr="PROD006",
            descripcion="Café torrado e molido de tueste natural"
        ),
        Producto(
            nome="Iogur natural 125g",
            prezo=0.89,
            stock=60,
            codigo_qr="PROD007",
            descripcion="Iogur natural "
        ),
        Producto(
            nome="Atún en aceite 190g",
            prezo=1.45,
            stock=35,
            codigo_qr="PROD008",
            descripcion="Atún en aceite de oliva"
        ),
    ]
    
    for producto in productos:
        db.add(producto)
    
    db.commit()
    print(f"{len(productos)} productos creados correctamente")
    
    # Carrito de proba para alba
    print("Creando carritos de proba...")
    carrito1 = Carrito(usuario_id=1)
    db.add(carrito1)
    db.commit()
    
    # Engadir algunos productos ao carrito 
    linea1 = LineaCarrito(
        carrito_id=carrito1.id,
        producto_id=1, 
        cantidad=2
    )
    linea2 = LineaCarrito(
        carrito_id=carrito1.id,
        producto_id=2,  
        cantidad=1
    )
    
    db.add(linea1)
    db.add(linea2)
    db.commit()
    
    print("Carritos creados correctamente")
    
    # Pechar sesión
    db.close()
    
    print("\n Datos de proba cargados")
    print(f"   - {len(productos)} productos disponibles")
    print(f"   - 2 usuarios creados")
    print(f"   - 1 carrito con 2 productos")


if __name__ == "__main__":
    cargar_datos()
