# ScanGo Backend

## Descripción

Este proxecto corresponde ao backend da aplicación ScanGo, desenvolvido con **FastAPI**. O seu obxectivo é ofrecer unha **API REST** que permita xestionar produtos e carritos da compra mediante códigos QR.

O backend é responsable de:
- Xestionar o catálogo de productos
- Buscar productos por código QR
- Crear e xestionar carritos de compra
- Calcular totais de compra
- Almacenar datos en base de datos

## 🚀 Instalación

### Requisitos
- Python 3.9 ou superior  
- pip  

### Pasos a seguir

1. **Instalar as dependencias:**
```bash
cd backend
pip install -r requirements.txt
```

2. **Cargar datos de proba (opcional):**
```bash
python datosProba.py
```
Este script crea:
- 2 usuarios de proba 
- 8 productos de proba con códigos QR
- 1 carrito con 2 produtos de exemplo

3. **Iniciar o servidor:**
```bash
python -m uvicorn app.main:app --reload
```

Unha vez iniciado, o servidor estará dispoñible en: **http://localhost:8000**

## Endpoints

### Produtos

#### **GET** `/produtos/`
Devolve todos os productos dispoñibles no catálogo.

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nome": "Leite enteiro 1L",
    "prezo": 1.29,
    "stock": 48,
    "categoria": "Lácteos",
    "codigo_qr": "QR-00423",
    "descripcion": "Leite integral pasteurizado"
  }
]
```

#### **GET** `/produtos/escanear/{codigo_qr}`
Permite obter a información dun producto a partir do seu código QR. Úsase cando o usuario escanea un producto.

**Exemplo:**
```
GET /produtos/escanear/QR-00423
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nome": "Leite enteiro 1L",
  "prezo": 1.29,
  "stock": 48,
  "categoria": "Lácteos",
  "codigo_qr": "QR-00423",
  "descripcion": "Leite integral pasteurizado"
}
```

**Response (404 Not Found):**
```json
{
  "detail": "Produto non atopado"
}
```

#### **GET** `/produtos/id/{produto_id}`
Devolve os datos dun producto concreto a través do seu ID.

**Exemplo:**
```
GET /produtos/id/1
```

**Response (200 OK):** (igual ao anterior)

---

### Carrito

#### **POST** `/carrito/engadir`
Permite engadir un producto ao carrito dun usuario.

**Request:**
```json
{
  "usuario_id": 1,
  "codigo_qr": "QR-00423"
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
      "codigo_qr": "QR-00423",
      "nome_produto": "Leite enteiro 1L",
      "prezo_unitario": 1.29,
      "cantidad": 1,
      "subtotal": 1.29
    }
  ],
  "total": 1.29
}
```

#### **GET** `/carrito/ver/{usuario_id}`
Mostra o carrito activo do usuario, incluíndo os productos e o total.

**Exemplo:**
```
GET /carrito/ver/1
```

**Response (200 OK):** (igual ao anterior)

#### **DELETE** `/carrito/eliminar/{usuario_id}/{codigo_qr}`
Elimina un producto do carrito do usuario.

**Exemplo:**
```
DELETE /carrito/eliminar/1/QR-00423
```

**Response (200 OK):**
```json
{
  "mensaje": "Producto eliminado do carrito"
}
```

---

## Base de Datos

Empregase **SQLite** cun ficheiro local chamado `scango.db`.

### Táboas principais

| Taboa | Descripción |
|-------|-------------|
| **usuarios** | Garda os usuarios da aplicación |
| **productos** | Contén o catálogo de productos |
| **carritos** | Xestiona os carritos de compra |
| **lineas_carrito** | Garda os productos dentro de cada carrito |

---

## 📁 Estrutura do Proxecto

```
backend/
├── seed.py                 # Script con datos de proba
├── requirements.txt        # Dependencias do proxecto
├── app/
│   ├── main.py             # Configuración principal de FastAPI
│   ├── models.py           # Modelos da base de datos 
│   ├── database.py         # Configuración da base de datos
│   └── routers/
│       ├── __init__.py
│       ├── produtos.py     # Endpoints de productos
│       └── carrito.py      # Endpoints do carrito
└── scango.db               # Base de datos SQLite 
```

---

## 🔧 Configuración

O servidor está configurado por defecto en:
- **Host:** localhost
- **Porto:** 8000
- **Recarga automática:** Activada (--reload)

Para cambiar a configuración, modifica `app/main.py`.

---

## Documentación Automática

FastAPI xera documentación automaticamente cando o servidor está en funcionamento:

- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc


---

## Exemplo de Uso

### Listar productos
```bash
curl -X GET "http://localhost:8000/produtos/"
```

### Buscar por QR
```bash
curl -X GET "http://localhost:8000/produtos/escanear/QR-00423"
```

### Engadir ao carrito
```bash
curl -X POST "http://localhost:8000/carrito/engadir" \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1, "codigo_qr": "QR-00423"}'
```

### Ver carrito
```bash
curl -X GET "http://localhost:8000/carrito/ver/1"
```

