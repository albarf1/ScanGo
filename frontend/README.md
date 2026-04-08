# ScanGo Frontend - Aplicación Flutter

## 📱 Descripción

Aplicación Flutter multiplataforma para **ScanGo**. Permite aos clientes:
- ✅ Escanear productos con cámara (códigos QR)
- ✅ Ver detalles de productos
- ✅ Xestionar carrito de compra
- ✅ Ver total de compra

## 🚀 Instalación

### Requisitos
- Flutter 3.x
- Dart 3.x
- Conexión de rede (para conexión ao backend)

### Pasos a seguir

1. **Instalar as dependencias:**
```bash
cd frontend
flutter pub get
```

## 📱 Executar

### Web (Chrome) 
```bash
flutter run -d chrome
```

### iOS (Emulador)
```bash
flutter run -d ios
```

### Android (Emulador)
```bash
flutter run -d android
```

### Dispositivo Físico
```bash
flutter devices                    # Ver dispositivos conectados
flutter run -d <device-id>       # Executar en dispositivo específico
```

## 📂 Estrutura do Código

```
lib/
├── main.dart                           # Punto de entrada da app
├── pantallas/                          # Pantallas 
│   ├── pantalla_principal.dart        # Navegación principal
│   ├── pantalla_escaner.dart          # Escaneo de códigos QR
│   ├── pantalla_produto.dart          # Detalles do producto
│   └── pantalla_carrito.dart          # Carrito de compra
└── servizos/                           # Servicios
    └── api_servizo.dart               # Cliente HTTP (REST API)
```

## 🔌 Conexión Backend

A app se conecta ao backend mediante a clase `ApiServizo` en `lib/servizos/api_servizo.dart`.


### Métodos dispoñibles

```dart
// Buscar producto por código QR
ApiServizo.escanearProduto(String codigoQr)

// Engadir producto ao carrito
ApiServizo.engadirAoCarrito(int usuarioId, String codigoQr)

// Ver carrito do usuario
ApiServizo.verCarrito(int usuarioId)

// Obter datos do usuario
ApiServizo.obterUsuario(int usuarioId)
```

## 📋 Flujo de Uso

### 1️⃣ Pantalla Principal (Inicio)
- Mostra bienvenida a ScanGo
- Acceso a todas as seccións mediante Bottom Navigation Bar
- Botón **"Simular Escaneo"** para probar sen cámara real

### 2️⃣ Pantalla Escanear
- Accede á cámara en tempo real
- Detecta códigos QR automaticamente
- Ao detectar QR → vai a detalles do producto

### 3️⃣ Pantalla Producto
- Mostra detalles (nome, prezo, stock)
- Botón **"Engadir ao carrito"** azul
- Volve ao escaneo ao terminar

### 4️⃣ Pantalla Carrito
- Lista de productos engadidos
- Mostra prezo unitario × cantidad = subtotal
- Calcula e mostra total automático
- Botón **"Actualizar"** para refrescar datos
- Botón **"Finalizar compra"** (funcionalidade próxima)

### 5️⃣ Pantalla Perfil
- Información do usuario (Nome, Email)
- Datos obtidos en tempo real desde o backend


## 📦 Dependencias

| Librería | Versión | Uso |
|----------|---------|-----|
| flutter | sdk | Framework principal |
| http | ^1.2.0 | Cliente HTTP para API REST |
| mobile_scanner | ^5.1.0 | Detección de códigos QR |


## 📚 Exemplos de Uso

### Escanear un producto (fluxo completo)
1. Abrir app → Pantalla Principal
2. Clicar en "Escanear"
3. Apuntar cámara a código QR
4. Sistema detecta QR automaticamente
5. Ve detalles do producto
6. Clica "Engadir ao carrito"
7. Vai ao carrito
8. Ve lista de productos con total


## 🚀 Para Levantar o Proxeto Completo

### 1. Backend (Terminal 1)
```bash
cd backend
pip install -r requirements.txt
python3 datosProba.py
python3 -m uvicorn app.main:app --reload --port 8001
```

### 2. Frontend (Terminal 2)
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

