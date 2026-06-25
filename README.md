# Seremi Adultos Mayores

Salud Mayor es una aplicación móvil desarrollada con Flutter, diseñada para ayudar a los usuarios de edad avanzada a administrar sus rutinas de salud diarias. La aplicación proporciona un sistema sólido para programar y rastrear la ingesta de medicamentos, mediciones de salud, citas médicas y actividades físicas. Cuenta con una arquitectura offline-first (prioridad sin conexión), que garantiza una funcionalidad completa sin una conexión constante a Internet, e incluye integración del cuidador para un mejor monitoreo y soporte.

## Caracteristicas

*   **Almacenamiento local**: La aplicación es completamente funcional sin conexión. Todos los datos se guardan en una base de datos SQLite local y se sincronizan con el servidor backend mediante un sistema de colas cuando vuelve a haber conexión a Internet disponible.
*   **Gestión de recordatorios**: Los usuarios pueden crear, editar y eliminar recordatorios para:
    *   **Medicamentos**: Configurar recordatorios para múltiples dosis diarias, incluyendo la dosis específica, instrucciones y fotos de referencia del medicamento y su empaque.
    *   **Medición de presión**: Programar chequeos regulares, enfocados principalmente en la presión arterial.
    *   **Actividades**: Recordatorios para actividades físicas como la hidratación.
    *   **Citas medicas**: Hacer un seguimiento de las próximas citas con profesionales de la salud.
*   **Alarmas intrusivas**: Los recordatorios críticos (medicamentos y presión arterial) activan alarmas sonoras a pantalla completa que no se pueden descartar fácilmente, garantizando que sean atendidos. Las alarmas aumentan de intensidad si son ignoradas.
*   **Integración del cuidador**: El sistema notifica automáticamente a un cuidador designado a través de WhatsApp en situaciones críticas, tales como:
    *   Un medicamento o una medición de presión arterial olvidados.
    *   Lecturas de presión arterial persistentemente altas.
    *   Cuando el usuario activa manualmente una alerta de emergencia.
*   **Semaforización en medición de presión**: Las lecturas de presión arterial se categorizan como `normal`, `elevado` o `critico`. La aplicación proporciona una respuesta visual inmediata y guía al usuario sobre los siguientes pasos a seguir, incluyendo la programación de una medición de seguimiento o el contacto con un cuidador/servicios de emergencia.
*   **Recordatorios diarios y calendario**:
    *   La pantalla de inicio ofrece un resumen claro de las tareas del día, organizadas en secciones de "Mañana", "Tarde" y "Noche".
    *   Una vista completa de calendario permite a los usuarios ver y gestionar eventos para cualquier día determinado.
*   **Historial de recordatios**: Un registro de historial detallado guarda el cumplimiento del usuario, mostrando qué recordatorios fueron completados, omitidos o registrados.
*   **Asistente de voz**: La funcionalidad de Texto a Voz (TTS) lee los recordatorios e instrucciones en voz alta para mejorar la accesibilidad de los usuarios con discapacidades visuales.

## Stack tecnologico & Arquitectura

Esta aplicación está construida utilizando el framework **Flutter** y sigue el patrón MVVM (Model-View-ViewModel) para la gestión del estado utilizando el paquete **Provider**.

*   **Base de datos local**: Se utiliza **SQLite** (`sqflite`) para el almacenamiento local de datos, lo que permite la funcionalidad offline-first.
*   **Backend & sincronización**:
    *   Un servicio backend personalizado alojado en **Railway** maneja la lógica de negocio, incluyendo el envío de notificaciones de WhatsApp a los cuidadores.
    *   Se utiliza **Supabase** (PostgreSQL) para la autenticación de usuarios y como la base de datos principal en la nube.
    *   Se utiliza **Supabase Storage** para alojar las imágenes subidas por el usuario (por ejemplo, fotos de medicamentos).
    *   Un `SyncService` personalizado gestiona el flujo bidireccional de datos entre la base de datos SQLite local y los servicios backend. Utiliza una cola para procesar las operaciones pendientes una vez que se restablece la conectividad.
*   **Librerias y dependencias**:
    *   `provider`: Para la gestión del estado.
    *   `supabase_flutter`: Para la autenticación y la interacción con la base de datos.
    *   `sqflite` y `path`: Para la gestión de la base de datos local.
    *   `http`: Para la comunicación con el backend en Railway.
    *   `flutter_local_notifications` y `permission_handler`: Para programar y gestionar las alarmas y notificaciones locales.
    *   `flutter_tts`: Para la funcionalidad de Texto a Voz.
    *   `table_calendar`: Para la vista de calendario.
    *   `image_picker`: Para seleccionar fotos desde la cámara o la galería.

## Pasos de instalación

Para ejecutar este proyecto localmente, sigue estos pasos:

1. **Clonar el repositorio:**
```bash
    git clone [https://github.com/velaskovsy/seremi-adultos-mayores.git](https://github.com/velaskovsy/seremi-adultos-mayores.git)
    cd seremi-adultos-mayores
```

2. **Instalar dependencias:**
```bash
    flutter pub get
```

3. **Ejecutar la aplicación:**
```bash
    flutter run
```
