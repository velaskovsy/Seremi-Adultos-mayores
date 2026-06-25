# Seremi Adultos Mayores

App móvil desarrollada en Flutter para ayudar a adultos mayores a gestionar su rutina de salud diaria. Permite registrar y hacer seguimiento de medicamentos, mediciones de presión, citas médicas y actividades físicas.

Funciona con arquitectura **offline-first**: todos los datos se guardan en SQLite local y se sincronizan con el servidor cuando hay conexión disponible.

## Stack

- **Framework:** Flutter (Dart)
- **Patrón de arquitectura:** MVVM con Provider
- **Base de datos local:** SQLite (`sqflite`)
- **Backend:** API REST en Railway → [ServidorAPPSEREMI](https://github.com/Dmarcan/ServidorAPPSEREMI.git)
- **Almacenamiento de imágenes:** Supabase Storage (fotos de medicamentos)
- **Notificaciones:** `flutter_local_notifications` + alarmas intrusivas con `alarm`
- **Voz:** `flutter_tts` para leer instrucciones en voz alta

## Funcionalidades principales

- Recordatorios para medicamentos, mediciones de presión, actividades y citas médicas
- Alarmas a pantalla completa para recordatorios críticos (medicamentos y presión)
- Semaforización de presión arterial: clasifica cada medición como `normal`, `elevado` o `crítico` y guía al usuario en los pasos a seguir
- Notificaciones WhatsApp al cuidador ante medicamentos olvidados, presión alta persistente o botón de emergencia
- Vista de inicio con tareas del día divididas en mañana / tarde / noche
- Calendario mensual con marcadores de días con eventos
- Historial de cumplimiento con estado de cada recordatorio (tomado / no tomado)
- Login offline: valida el PIN localmente si no hay internet

## Estructura del proyecto

```
lib/
├── main.dart                  # Inicialización de Supabase, SQLite, notificaciones y sincronización
├── models/                    # Modelos de datos (Recordatorio, Usuario)
├── database/
│   └── db_helper.dart         # SQLite local: tablas, cola de sincronización, sesión offline
├── services/
│   ├── auth_service.dart      # Login/registro contra Railway; fallback offline con hash SHA-256
│   ├── storage_service.dart   # Subida de fotos a Supabase Storage
│   ├── sync_service.dart      # Sincronización bidireccional SQLite ↔ Railway
│   ├── recordatorio_service.dart
│   ├── medicamento_service.dart
│   ├── medicion_service.dart
│   ├── activity_service.dart
│   ├── cita_medica_service.dart
│   ├── historial_service.dart
│   ├── notificacion_service.dart
│   ├── notificacion_cuidador_service.dart
│   ├── connectivity_service.dart
│   └── voice_service.dart
├── viewmodels/                # Lógica de presentación (MVVM), uno por pantalla
└── views/                     # Pantallas organizadas por funcionalidad
    ├── home/
    ├── login/ y register/
    ├── add medication/
    ├── add measurement/
    ├── add activity/
    ├── add appointment/
    ├── alarma_medicacion/
    ├── alarma_presion/
    ├── calendario/
    ├── historial/
    ├── semaforizacion/
    └── editar o eliminar recordatorio/
```

## Cómo corre el offline-first

1. Cada operación (crear, editar, eliminar) se guarda primero en SQLite local
2. Si hay internet se ejecuta directo contra Railway; si no, se encola en `cola_sincronizacion`
3. `SyncService` escucha cambios de conectividad y procesa la cola cuando vuelve el internet
4. Al recuperar conexión también baja los cambios desde Railway (pull) para mantener ambas BDs sincronizadas

## Configuración

### Supabase Storage (fotos de medicamentos)

Las credenciales ya están en `main.dart`. Para un entorno propio, reemplazar en `main.dart`:

```dart
await Supabase.initialize(
  url: 'TU_SUPABASE_URL',
  anonKey: 'TU_SUPABASE_ANON_KEY',
);
```

Y crear un bucket llamado `fotos-recordatorios` con acceso público en el panel de Supabase.

### Backend (Railway)

La URL del servidor está definida en `auth_service.dart` y `sync_service.dart`:

```dart
static const String _baseUrl = 'https://servidorappseremi-production.up.railway.app';
```

El repositorio del backend está en: https://github.com/Dmarcan/ServidorAPPSEREMI.git

## Instalación y ejecución local

```bash
git clone <url-de-este-repo>
cd seremi-adultos-mayores
flutter pub get
flutter run
```

Requiere Flutter SDK ≥ 3.11 y un dispositivo/emulador Android (iOS también funciona pero las alarmas intrusivas están optimizadas para Android).
