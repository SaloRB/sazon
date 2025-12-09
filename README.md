# 🍽️ **Sazón --- Aplicación de Recetas (Flutter + Node.js + Drizzle ORM)**

Sazón es una aplicación móvil para gestionar recetas de cocina: crear,
editar, explorar y guardar favoritas.\
Construida con un stack moderno:

-   **Frontend:** Flutter + Bloc\
-   **Backend:** Node.js + Express\
-   **Base de datos:** PostgreSQL + Drizzle ORM\
-   **Infra:** Docker para base de datos

Este README describe el proyecto, la arquitectura, la instalación y los
comandos clave.

------------------------------------------------------------------------

# 📌 **Características principales**

### 🔐 Autenticación

-   Registro e inicio de sesión con email + contraseña.
-   Tokens JWT almacenados de forma segura con Secure Storage.

### 🍳 Gestión completa de recetas

-   Crear recetas con:
    -   Título\
    -   Descripción\
    -   Dificultad\
    -   Tiempos (preparación / cocción)\
    -   Porciones\
    -   Ingredientes (ordenados)\
    -   Pasos (ordenados)
-   Editar y eliminar recetas propias.
-   Listar todas las recetas del sistema o solo las del usuario.

### ❤️ Favoritos (Sprint 4)

-   Marcar/Desmarcar recetas como favoritas.
-   Ver la lista de recetas favoritas en una pestaña dedicada.
-   Estado sincronizado entre backend y app.

------------------------------------------------------------------------

# 🏗️ **Arquitectura general**

    Flutter App
      ├── UI (Widgets)
      ├── Bloc/Cubit (Auth, Recipes, Favorites)
      ├── Repositories (consumen API REST)
      └── ApiClient (Dio + Interceptor de autenticación)

    Backend (Node.js / Express)
      ├── Routes (auth, recipes, favorites)
      ├── Controllers
      ├── Services (reglas de negocio)
      ├── Repositories (consultas con Drizzle)
      └── PostgreSQL (manejada por Docker)

### Comunicación

La app móvil usa **HTTP/JSON** hacia el backend con autenticación
**Bearer JWT**.

------------------------------------------------------------------------

# 🗄️ **Base de datos (PostgreSQL + Drizzle ORM)**

Tablas principales:

-   `users`
-   `recipes`
-   `recipe_ingredients`
-   `recipe_steps`
-   `favorites`

Relaciones:

    users (1) ---- (N) recipes
    recipes (1) -- (N) ingredients
    recipes (1) -- (N) steps
    users (N) -- (N) recipes  via favorites

Migrations generadas automáticamente vía Drizzle.

------------------------------------------------------------------------

# 🚀 **Instalación y ejecución del proyecto**

## 1️⃣ Requisitos previos

-   Node.js 20+
-   npm o pnpm
-   Docker
-   Flutter SDK 3.22+
-   Xcode / Android Studio para correr en dispositivos

------------------------------------------------------------------------

# 🔧 **Backend --- Setup**

### 1. Instalar dependencias

``` sh
cd backend
npm install
```

### 2. Levantar la base de datos con Docker

``` sh
docker compose up -d
```

### 3. Configurar variables de entorno `.env`

Ejemplo:

    DATABASE_URL=postgres://postgres:postgres@localhost:5432/sazon
    JWT_SECRET=sazon-secret
    PORT=3000

### 4. Ejecutar migraciones

``` sh
npx drizzle-kit generate
npx drizzle-kit push
```

### 5. Ejecutar backend en modo dev

``` sh
npm run dev
```

Backend listo en:

    http://localhost:3000

------------------------------------------------------------------------

# 📱 **Frontend (Flutter) --- Setup**

### 1. Instalar dependencias

``` sh
cd mobile/sazon_recetas
flutter pub get
```

### 2. Configurar base URL

En `ApiConfig`:

``` dart
static const baseUrl = 'http://localhost:3000';
```

### 3. Correr la app

iOS:

``` sh
flutter run -d ios
```

Android:

``` sh
flutter run -d android
```

------------------------------------------------------------------------

# 🧩 **Estructura de carpetas**

## Backend

    src/
      config/
      db/
      modules/
        auth/
        recipes/
        favorites/
      middlewares/
      routes/
      utils/

## Flutter

    lib/
      core/
        network/
        storage/
      features/
        auth/
        recipes/
          data/
          domain/
          presentation/
        favorites/
      theme/
      widgets/
      app/

------------------------------------------------------------------------

# 📚 **Documentos adicionales**

La carpeta `docs/` contiene:

-   architecture.md
-   api-endpoints.md
-   database-schema.md
-   setup-backend.md
-   setup-mobile.md
-   roadmap.md
-   decision-log.md

------------------------------------------------------------------------

# 🛣️ **Roadmap del proyecto**

### ✔ Versiones ya implementadas

-   Sprint 0: Configuración e infraestructura
-   Sprint 1: Autenticación
-   Sprint 2: CRUD de recetas
-   Sprint 3: UI/UX + mejoras
-   Sprint 4: Favoritos

### 🚧 Próximos sprints sugeridos

-   Sprint 5: Búsqueda avanzada
-   Sprint 6: Ratings y comentarios
-   Sprint 7: Modo offline
-   Sprint 8: Listas de compras
-   Sprint 9: Compartir recetas y deep links
-   Sprint 10: Subir fotos de recetas

------------------------------------------------------------------------

# 🤝 **Contribución**

1.  Crea una rama\
2.  Haz tus cambios\
3.  Envía un PR\
4.  Documenta lo necesario en `docs/`

------------------------------------------------------------------------

# 📄 **Licencia**

Proyecto para fines educativos y personales.
