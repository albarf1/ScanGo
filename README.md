# ScanGo

**ScanGo** é unha aplicación de autocompra para tendas físicas. Permite aos clientes escanear os produtos co seu móbil mentres fan a compra, xestionando todo desde a app e evitando ter que pasar pola caixa.

## 📖 Que é ScanGo?

A idea de ScanGo é facer que comprar sexa rápido e sinxelo. En lugar de esperar na cola, o cliente vai escaneando os produtos co móbil a medida que os colle, vendo en todo momento o que leva no carrito e o total da compra.

A app conecta co servidor para obter información de cada produto (nome, prezo, etc.) e engadila automaticamente ao carrito virtual.

## 🚀 Funcionalidades principais

### Para o cliente
- Escanear produtos co móbil.
- Ver prezo e información básica de cada artigo.
- Engadir produtos ao carrito virtual.
- Consultar o total da compra en tempo real.

### Para o administrador
- Engadir ou modificar produtos no sistema.
- Controlar o stock dispoñible.
- Consultar datos básicos de vendas.
- Xerar códigos QR ou códigos de barras para os produtos.

## 🏗️ Como funciona

O backend está organizado en capas para que cada parte teña a súa responsabilidade:

- **DAO**: accede á base de datos.
- **Services**: lóxica da aplicación e xestión das transaccións.
- **DTOs**: envían datos entre backend e frontend.
- **API REST**: comunica a app co servidor.

## 💻 Tecnoloxías que usamos

- **Frontend**: Flutter e Dart
- **Backend**: Python, FastAPI, SQLAlchemy
- **Base de datos**: PostgreSQL
- **Control de versións**: Git e repositorio en GitHub

## 📂 Estrutura do proxecto

scan-go/
│
├── README.md
├── docs/
│   └── proposta_proxecto.md
├── backend/
└── frontend/


## 📑 Documentación

A documentación completa atópase en:  
`docs/proposta_proxecto.md`
