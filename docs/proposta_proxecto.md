# Proposta de proxecto – ScanGo

## 1. Nome do proxecto

**ScanGo – App de autocompra para tendas físicas**

## 2. Para que serve

A idea de ScanGo é facer que comprar nas tendas sexa máis rápido e cómodo. En vez de esperar na caixa, o cliente pode ir escaneando os produtos co seu móbil e ir vendo o total da compra en tempo real.

Tamén permite aos administradores xestionar produtos e stock dunha forma sinxela.

## 3. Obxectivos

### Principais
- Que os clientes poidan escanear e comprar produtos co móbil sen pasar pola caixa.
- Crear un backend que xestione produtos, stock e transaccións.
- Manter a información de produtos e vendas nunha base de datos.
- Garantir que a app e o servidor se comuniquen de forma segura.

### Secundarios
- Que os administradores poidan engadir ou modificar produtos sen complicacións.
- Xerar códigos QR ou códigos de barras para os produtos.
- Facilitar informes básicos de vendas e stock.

## 4. Tecnoloxías que imos usar

- **Frontend**: Flutter e Dart  
- **Backend**: Python, FastAPI, SQLAlchemy  
- **Base de datos**: PostgreSQL  
- **Control de versións**: Git e GitHub  

## 5. Como estará organizado o proxecto

O backend terá varias capas:

- **DAO**: para acceder á base de datos.  
- **Services**: para a lóxica da aplicación e xestionar as compras.  
- **DTOs**: para enviar datos entre o backend e o frontend.  
- **API REST**: para que a app e o servidor falen entre eles.  

## 6. Funcionalidades principais

### Para o cliente
- Escanear produtos co móbil.  
- Engadir produtos ao carrito virtual e ver o total da compra.  
- Consultar información básica de cada produto.  

### Para o administrador
- Engadir, modificar ou eliminar produtos.  
- Controlar o stock dispoñible.  
- Consultar vendas e xerar informes simples.  
- Xerar códigos QR ou códigos de barras para os produtos.  

## 7. Estrutura do repositorio

scan-go/
│
├── README.md
├── docs/
│   └── proposta_proxecto.md
├── backend/
└── frontend/