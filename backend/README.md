# ScanGo Backend - API REST

## 📋 Descripción

Este documento contén a lóxica de servidor do sistema **ScanGo**. O backend actúa como o núcleo central que xestiona a persistencia de datos, a lóxica de negocio e a comunicación coa aplicación móbil a través dunha API REST.

## 2️⃣ Tecnoloxías empregadas

- **Framework**: FastAPI (Python) para unha xestión rápida e eficiente das peticións
- **ORM**: SQLAlchemy para a interacción coa base de datos
- **Base de datos**: 
  - Fase actual: SQLite (ficheiro local `scango.db`)
  - Produción: PostgreSQL 15 (futuro)
- **Documentación**: Swagger UI (dispoñible en `/docs`)

## 3️⃣ Funcionalidades implementadas

De acordo coa especificación de alcance, o servidor ofrece soporte para:

- **Xestión de produtos (CU03/CU04)**: Endpoints para listar o catálogo e buscar artigos mediante o código QR
- **Integridade referencial**: Estrutura de táboas normalizada para produtos, usuarios e carriños
- **Datos de proba**: Script automatizado para a carga inicial de información técnica

## 4️⃣ Estrutura do proxecto

```
backend/
├── app/
│   ├── main.py              # Punto de entrada e configuración
│   ├── models.py            # Modelos da BD (Usuario, Producto, Carrito)
│   ├── database.py          # Configuración da conexión á BD
│   ├── routers/
│   │   ├── produtos.py      # Endpoints de productos
│   │   ├── carrito.py       # Endpoints do carrito
│   │   └── usuarios.py      # Endpoints de usuarios
│   └── __init__.py
├── datosProba.py            # Script para cargar datos de proba
├── requirements.txt         # Dependencias do proxecto
└── scango.db               # Base de datos SQLite (creada automáticamente)
```

## 5️⃣ Instalación e Execución

### Requisitos
- Python 3.9 ou superior
- pip

### Pasos a seguir

1. **Instalar dependencias:**
```bash
cd backend
pip install -r requirements.txt
```

2. **Cargar datos de proba:**
```bash
python3 datosProba.py
```

3. **Iniciar o servidor:**
```bash
python3 -m uvicorn app.main:app --reload --port 8001
```

Unha vez iniciado, o servidor estará dispoñible en: **http://localhost:8001**

## 📡 Endpoints Dispoñibles

### Productos

#### GET `/produtos/`
Devolve todos os productos dispoñibles no catálogo.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nome": "Leite enteiro 1L",
    "prezo": 1.29,
    "stock": 50,
    "codigo_qr": "PROD001"
  }
]
```

#### GET `/produtos/escanear/{codigo_qr}`
Busca un producto polo seu código QR. Úsase cando o usuario escanea un producto.

**Exemplo:**
```
GET /produtos/escanear/PROD001
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "Leite enteiro 1L",
  "prezo": 1.29,
  "stock": 50,
  "codigo_qr": "PROD001"
}
```

**Response (404 Not Found):**
```json
{
  "detail": "Producto non atopado"
}
```

#### GET `/produtos/id/{producto_id}`
Devolve os datos dun producto concreto a través do seu ID.

### Carrito

#### POST `/carrito/engadir`
Engade un producto ao carrito dun usuario.

**Request:**
```json
{
  "usuario_id": 1,
  "codigo_qr": "PROD001"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "usuario_id": 1,
  "lineas": [
    {
      "id": 1,
      "producto_id": 1,
      "cantidad": 1,
      "prezo_unitario": 1.29
    }
  ],
  "total": 1.29
}
```

#### GET `/carrito/ver/{usuario_id}`
Mostra o carrito activo do usuario.

**Response (200 OK):**
```json
{
  "id": 1,
  "usuario_id": 1,
  "lineas": [...],
  "total": 4.57
}
```

#### DELETE `/carrito/eliminar/{usuario_id}/{codigo_qr}`
Elimina un producto do carrito do usuario.

### Usuarios

#### GET `/usuarios/{usuario_id}`
Obtén os datos dun usuario.

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "Alba Rodríguez",
  "email": "alba@scango.com"
}
```

## 🗄️ Base de Datos

Empregase **SQLite** cun ficheiro local chamado `scango.db`.

### Táboas principais

| Taboa | Descripción |
|-------|-------------|
| **usuarios** | Garda os usuarios da aplicación |
| **productos** | Contén o catálogo de productos |
| **carritos** | Xestiona os carritos de compra |
| **lineas_carrito** | Garda os productos dentro de cada carrito |

## 📚 Documentación Automática

FastAPI xera documentación automaticamente cando o servidor está en funcionamento:

- **Swagger UI:** http://localhost:8001/docs
- **ReDoc:** http://localhost:8001/redoc

Podes usar estas ferramentas para probar os endpoints de forma interactiva.

## 🧪 Exemplo de Uso (cURL)

### Listar productos
```bash
curl -X GET "http://localhost:8001/produtos/"
```

### Buscar por QR
```bash
curl -X GET "http://localhost:8001/produtos/escanear/PROD001"
```

### Engadir ao carrito
```bash
curl -X POST "http://localhost:8001/carrito/engadir" \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1, "codigo_qr": "PROD001"}'
```

### Ver carrito
```bash
curl -X GET "http://localhost:8001/carrito/ver/1"
```

## 📦 Dependencias

Ver arquivo `requirements.txt` para a lista completa de dependencias.

Principais:
- `fastapi` - Framework web
- `sqlalchemy` - ORM para a base de datos
- `uvicorn` - Servidor ASGI
- `python-multipart` - Soporte para formularios

