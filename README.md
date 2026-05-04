# blume_ma — Blume Mobile App

Cross-platform mobile client (Android / iOS) for **Blume**, a live educational streaming platform. Students can explore channels, join live classes, and watch recordings; professors can manage their content from their phone.

---

## Table of contents

- [Architecture](#architecture)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the app](#running-the-app)
- [Demo mode](#demo-mode)
- [Backend integration](#backend-integration)
- [Screens and navigation](#screens-and-navigation)

---

## Architecture

The app follows **Clean Architecture** with clear layer separation:

```
Presentation  →  Domain (providers/notifiers)  →  Data (repositories)  →  API
```

- **State management:** Riverpod 2.x (`AsyncNotifier`, `FutureProvider.autoDispose`)
- **Navigation:** GoRouter with `ShellRoute` for the bottom nav and auth-based redirect guards
- **Networking:** Dio + `PersistCookieJar` — automatically handles the `blume_session` cookie set by the Spring Boot backend
- **Local persistence:** `FlutterSecureStorage` for the JWT token

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
│            Blume Backend (Traefik :80)          │
│  Spring Boot · Go Stream Engine · Record Svc    │
└─────────────────────────────────────────────────┘
```

---

## Tech stack

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6 | State management |
| `go_router` | ^14.x | Declarative navigation |
| `dio` | ^5.7 | HTTP client |
| `dio_cookie_manager` + `cookie_jar` | ^3.x / ^4.x | Session cookie handling |
| `flutter_secure_storage` | ^9.x | Secure JWT storage |
| `video_player` + `chewie` | ^2.9 / ^1.x | Video playback (live HLS + recordings) |
| `cached_network_image` | ^3.4 | Image caching |
| `shimmer` | ^3.0 | Skeleton loaders |
| `path_provider` | ^2.1 | Persistent cookie directory |

---

## Project structure

```
lib/
├── main.dart                          # Entry point — initializes PersistCookieJar and ProviderScope
├── app.dart                           # GoRouter + Material 3 theme
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # Base URLs and endpoint paths
│   │   └── app_colors.dart            # Color palette
│   ├── demo/
│   │   └── demo_data.dart             # Mock data for demo mode + demoModeProvider
│   ├── errors/
│   │   └── app_exception.dart         # Typed domain exceptions
│   ├── network/
│   │   └── dio_client.dart            # Dio + CookieManager + error interceptor
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
    ├── theme/app_theme.dart           # Light and dark Material 3 themes
    └── widgets/
        ├── blume_loading.dart         # CircularProgressIndicator + ShimmerCard
        ├── blume_error.dart           # Error view with retry button
        └── blume_empty.dart           # Empty state view
```

---

## Prerequisites

- **Flutter SDK** ≥ 3.11.5
- **Dart SDK** ≥ 3.4.0
- Android Studio or VS Code with the Flutter extension
- For a physical Android device: developer mode enabled
- To connect to the backend: [blume_business_logic_ms](../blume_business_logic_ms) + [infrastructure](../infrastructure) running

---

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Set the backend URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// Android Emulator (points to the host machine's localhost)
static const String baseUrl = 'http://10.0.2.2';

// Physical device (use your machine's LAN IP)
static const String baseUrl = 'http://192.168.1.X';

// iOS Simulator
static const String baseUrl = 'http://localhost';
```

> Find your LAN IP on Windows: `ipconfig | findstr "IPv4"`  
> Find your LAN IP on macOS/Linux: `ifconfig | grep "inet "`

### 3. Android — HTTP traffic in development

`AndroidManifest.xml` already includes `android:usesCleartextTraffic="true"` and a `network_security_config.xml` with the allowed local domains. No additional changes needed.

---

## Running the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Build a debug APK
flutter build apk --debug
```

---

## Demo mode

The app includes a **demo mode** that requires no backend. On the login screen, tap **"View demo (no backend)"**.

It loads the following sample data:

| Section | Content |
|---|---|
| Explore | 4 public channels, 2 live classes, 6 classes total |
| My Courses | 2 enrolled channels with their classes |
| Recordings | 3 playable recordings (sample videos) |
| Profile | Demo user (`demo@blume.app`) |

---

## Backend integration

The app consumes the Blume REST API through Traefik (port 80).

### Authentication

Sessions are managed via a `blume_session` cookie (httpOnly, JWT). Dio's `PersistCookieJar` stores it on disk and sends it automatically with every request.

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/login` | Login with email and password |
| `POST` | `/api/auth/registro` | Create a LOCAL account |
| `GET` | `/api/auth/me` | Get the user from the active session |
| `POST` | `/api/auth/logout` | Log out |
| `POST` | `/api/auth/onboarding` | Complete profile (username + role) |
| `POST` | `/api/auth/password-reset/request` | Request a 6-digit recovery code |
| `POST` | `/api/auth/password-reset/confirm` | Confirm code and set new password |

### Channels and classes

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/cursos/explorar` | Public channels |
| `GET` | `/api/cursos` | My enrolled channels (requires auth) |
| `POST` | `/api/cursos/:id/inscribirse` | Enroll in a channel |
| `GET` | `/api/clases` | List classes (filterable by `status`, `type`) |
| `GET` | `/api/clases/:id` | Class detail |

### Recordings

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/recordings` | Recordings catalog |
| `GET` | `/api/recordings/:id` | Recording metadata |
| `GET` | `/api/recordings/:id/play` | Stream the video |

### Live streaming (HLS)

The live stream player consumes HLS from MediaMTX. To enable it, expose port 8888 in `docker-compose.yml`:

```yaml
mediamtx:
  ports:
    - "8888:8888"   # HLS
    - "8889:8889"   # WHEP (already exposed)
    - "1935:1935"   # RTMP
```

The HLS URL is built as:
```
http://<HOST>:8888/live/<streamKey>/index.m3u8
```

---

## Screens and navigation

```
/splash         Checks active session → redirects to /login or /explorar
/login          Sign in (email + password) + demo button
/registro       Create a new account
/recuperar      Password recovery (6-digit code)
/onboarding     Choose username and role (STUDENT / PROFESSOR)

── Bottom Navigation ──────────────────────────────────
/explorar       Public channels + live and all classes
/cursos         My enrolled channels
/grabaciones    Recordings catalog
/perfil         User info + sign out

── Detail screens ─────────────────────────────────────
/canal/:id          Channel detail + class list + enroll button
/clase/:id/live     Live class player (HLS via video_player)
/grabacion/:id      Recording player with Chewie controls
```

### Test credentials (with backend)

The `V4__Seed_Data.sql` migration inserts sample users. Password for all of them:

```
Blume2025!
```

| Email | Role |
|---|---|
| `ana.garcia@unal.edu.co` | Student |
| `pedro.lopez@unal.edu.co` | Student |
| `carlos.mendoza@unal.edu.co` | Professor |
| `maria.torres@unal.edu.co` | Professor |
