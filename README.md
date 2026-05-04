# blume_ma — Aplicación Móvil de Blume

Cliente móvil multiplataforma (Android / iOS) para **Blume**, una plataforma de streaming educativo en vivo. Permite a estudiantes explorar canales, unirse a clases en vivo, y ver grabaciones; y a profesores gestionar su contenido desde el celular.

---

## Tabla de contenidos

- [Arquitectura](#arquitectura)
- [Stack tecnológico](#stack-tecnológico)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos previos](#requisitos-previos)
- [Configuración](#configuración)
- [Ejecución](#ejecución)
- [Modo demo](#modo-demo)
- [Integración con el backend](#integración-con-el-backend)
- [Pantallas y navegación](#pantallas-y-navegación)

---

## Arquitectura

La app sigue **Clean Architecture** con separación en capas:

```
Presentation  →  Domain (providers/notifiers)  →  Data (repositories)  →  API
```

- **State management:** Riverpod 2.x (`AsyncNotifier`, `FutureProvider.autoDispose`)
- **Navegación:** GoRouter con `ShellRoute` para el bottom nav y redirect guards basados en auth
- **Red:** Dio + `PersistCookieJar` — maneja automáticamente la cookie de sesión `blume_session` del backend Spring Boot
- **Persistencia local:** `FlutterSecureStorage` para el token JWT

```
┌─────────────────────────────────────────────────┐
│                  Presentation                   │
│   Screens  ←→  Providers (Riverpod)             │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│                  Data Layer                     │
│   Repositories  →  Dio HTTP Client              │
│                  ↕                              │
│   PersistCookieJar  (blume_session cookie)      │
└──────────────────────┬──────────────────────────┘
                       │ HTTP / REST
┌──────────────────────▼──────────────────────────┐
│            Backend Blume (Traefik :80)          │
│  Spring Boot · Go Stream Engine · Record Svc    │
└─────────────────────────────────────────────────┘
```

---

## Stack tecnológico

| Paquete | Versión | Uso |
|---|---|---|
| `flutter_riverpod` | ^2.6 | State management |
| `go_router` | ^14.x | Navegación declarativa |
| `dio` | ^5.7 | Cliente HTTP |
| `dio_cookie_manager` + `cookie_jar` | ^3.x / ^4.x | Manejo de cookies de sesión |
| `flutter_secure_storage` | ^9.x | Almacenamiento seguro del JWT |
| `video_player` + `chewie` | ^2.9 / ^1.x | Reproducción de video (live HLS + grabaciones) |
| `cached_network_image` | ^3.4 | Caché de imágenes |
| `shimmer` | ^3.0 | Skeleton loaders |
| `path_provider` | ^2.1 | Directorio de cookies persistentes |

---

## Estructura del proyecto

```
lib/
├── main.dart                          # Entry point — inicializa PersistCookieJar y ProviderScope
├── app.dart                           # GoRouter + tema Material 3
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # URLs base y paths de endpoints
│   │   └── app_colors.dart            # Paleta de colores
│   ├── demo/
│   │   └── demo_data.dart             # Datos mock para modo demo + demoModeProvider
│   ├── errors/
│   │   └── app_exception.dart         # Excepciones tipadas del dominio
│   ├── network/
│   │   └── dio_client.dart            # Dio + CookieManager + interceptor de errores
│   └── storage/
│       └── auth_storage.dart          # FlutterSecureStorage wrapper
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/auth_notifier.dart   # AsyncNotifier<UserModel?>
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           ├── register_screen.dart
│   │           ├── forgot_password_screen.dart
│   │           └── onboarding_screen.dart
│   │
│   ├── shell/presentation/screens/
│   │   ├── main_shell.dart            # Bottom navigation bar
│   │   └── profile_screen.dart
│   │
│   ├── explore/
│   │   ├── data/
│   │   │   ├── models/{channel,stream}_model.dart
│   │   │   └── repositories/explore_repository.dart
│   │   └── presentation/
│   │       ├── providers/explore_notifier.dart
│   │       ├── screens/{explore,channel_detail}_screen.dart
│   │       └── widgets/{channel_card,stream_card}.dart
│   │
│   ├── courses/
│   │   ├── data/repositories/courses_repository.dart
│   │   └── presentation/
│   │       ├── providers/courses_notifier.dart
│   │       └── screens/{courses,course_detail}_screen.dart
│   │
│   ├── streams/
│   │   ├── data/repositories/streams_repository.dart
│   │   └── presentation/
│   │       ├── providers/stream_notifier.dart
│   │       └── screens/live_player_screen.dart
│   │
│   └── recordings/
│       ├── data/
│       │   ├── models/recording_model.dart
│       │   └── repositories/recordings_repository.dart
│       └── presentation/
│           ├── providers/recordings_notifier.dart
│           └── screens/{recordings,recording_player}_screen.dart
│
└── shared/
    ├── theme/app_theme.dart           # Tema claro y oscuro Material 3
    └── widgets/
        ├── blume_loading.dart         # CircularProgressIndicator + ShimmerCard
        ├── blume_error.dart           # Vista de error con botón reintentar
        └── blume_empty.dart           # Vista de estado vacío
```

---

## Requisitos previos

- **Flutter SDK** ≥ 3.11.5
- **Dart SDK** ≥ 3.4.0
- Android Studio / VS Code con extensión Flutter
- Para Android físico: modo desarrollador activado en el dispositivo
- Para conectar con el backend: [blume_business_logic_ms](../blume_business_logic_ms) + [infrastructure](../infrastructure) corriendo

---

## Configuración

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar la URL del backend

Edita `lib/core/constants/api_constants.dart`:

```dart
// Android Emulator (apunta al localhost del host)
static const String baseUrl = 'http://10.0.2.2';

// Dispositivo físico (usa la IP LAN de tu máquina)
static const String baseUrl = 'http://192.168.1.X';

// iOS Simulator
static const String baseUrl = 'http://localhost';
```

> Tu IP LAN en Windows: `ipconfig | findstr "IPv4"`  
> Tu IP LAN en macOS/Linux: `ifconfig | grep "inet "`

### 3. Android — tráfico HTTP en desarrollo

El `AndroidManifest.xml` ya incluye `android:usesCleartextTraffic="true"` y el `network_security_config.xml` con los dominios locales permitidos. No requiere cambios adicionales.

---

## Ejecución

```bash
# Listar dispositivos disponibles
flutter devices

# Correr en un dispositivo específico
flutter run -d <device-id>

# Build APK de debug
flutter build apk --debug
```

---

## Modo demo

La app incluye un **modo demo** que no requiere backend. En la pantalla de login, pulsa **"Ver demo (sin backend)"**.

Carga datos de ejemplo:

| Sección | Contenido |
|---|---|
| Explorar | 4 canales públicos, 2 clases en vivo, 6 clases totales |
| Mis cursos | 2 canales inscritos con sus clases |
| Grabaciones | 3 grabaciones reproducibles (videos de muestra) |
| Perfil | Usuario demo (`demo@blume.app`) |

---

## Integración con el backend

La app consume la API REST del stack de Blume a través de Traefik (puerto 80):

### Autenticación

La sesión se maneja con una cookie `blume_session` (httpOnly, JWT). El `PersistCookieJar` de Dio la almacena en disco y la envía automáticamente en cada request.

| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/api/auth/login` | Login con email y contraseña |
| `POST` | `/api/auth/registro` | Crear cuenta LOCAL |
| `GET` | `/api/auth/me` | Obtener usuario de la sesión activa |
| `POST` | `/api/auth/logout` | Cerrar sesión |
| `POST` | `/api/auth/onboarding` | Completar perfil (username + rol) |
| `POST` | `/api/auth/password-reset/request` | Solicitar código de recuperación |
| `POST` | `/api/auth/password-reset/confirm` | Confirmar código y nueva contraseña |

### Canales y clases

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/cursos/explorar` | Canales públicos |
| `GET` | `/api/cursos` | Mis canales inscritos (requiere auth) |
| `POST` | `/api/cursos/:id/inscribirse` | Inscribirse a un canal |
| `GET` | `/api/clases` | Listar clases (filtrables por `status`, `type`) |
| `GET` | `/api/clases/:id` | Detalle de una clase |

### Grabaciones

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/recordings` | Catálogo de grabaciones |
| `GET` | `/api/recordings/:id` | Metadata de una grabación |
| `GET` | `/api/recordings/:id/play` | Stream del video |

### Streaming en vivo (HLS)

El player de live streams consume HLS desde MediaMTX. Para habilitarlo, expón el puerto 8888 en el `docker-compose.yml`:

```yaml
mediamtx:
  ports:
    - "8888:8888"   # HLS
    - "8889:8889"   # WHEP (ya expuesto)
    - "1935:1935"   # RTMP
```

La URL HLS se construye como:
```
http://<HOST>:8888/live/<streamKey>/index.m3u8
```

---

## Pantallas y navegación

```
/splash         Verifica sesión activa → redirige a /login o /explorar
/login          Inicio de sesión (email + contraseña) + botón demo
/registro       Crear cuenta nueva
/recuperar      Recuperación de contraseña (código de 6 dígitos)
/onboarding     Elegir username y rol (STUDENT / PROFESSOR)

── Bottom Navigation ──────────────────────────────────
/explorar       Canales públicos + clases en vivo y todas las clases
/cursos         Mis canales inscritos
/grabaciones    Catálogo de grabaciones
/perfil         Datos del usuario + cerrar sesión

── Pantallas de detalle ───────────────────────────────
/canal/:id          Detalle de canal + lista de clases + inscribirse
/clase/:id/live     Player de clase en vivo (HLS via video_player)
/grabacion/:id      Player de grabación con controles Chewie
```

### Credenciales de prueba (con backend)

La migración `V4__Seed_Data.sql` inserta usuarios de ejemplo. Contraseña para todos:

```
Blume2025!
```

| Email | Rol |
|---|---|
| `ana.garcia@unal.edu.co` | Estudiante |
| `pedro.lopez@unal.edu.co` | Estudiante |
| `carlos.mendoza@unal.edu.co` | Profesor |
| `maria.torres@unal.edu.co` | Profesor |
