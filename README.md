# Wolkio

App de servicios de ayuda bajo demanda (tipo Uber/TaskRabbit) para la Región de Valparaíso.
Un solicitante publica una tarea (limpieza de patio, mudanza pequeña, armado de muebles, limpieza del hogar) y un prestador cercano recibe una alerta según su radio de búsqueda y modo de traslado (a pie, bicicleta, auto).

## Estructura del repo

```
wolkio/
├── supabase/
│   └── migrations/        # Esquema SQL de la base de datos (PostgreSQL + PostGIS)
├── mobile/                # App Flutter (Android + iOS)
│   └── lib/
│       ├── models/        # Clases de datos (Usuario, Tarea, Pago, etc.)
│       ├── screens/       # Pantallas de la app
│       ├── services/      # Conexión a Supabase, geolocalización, pagos
│       └── widgets/       # Componentes reutilizables
└── docs/                  # Documentación del proyecto
```

## Stack técnico

| Capa | Tecnología |
|---|---|
| App móvil | Flutter |
| Backend / base de datos | Supabase (PostgreSQL + PostGIS) |
| Notificaciones push | Firebase Cloud Messaging |
| Mapas y trayecto | Google Maps SDK + deep link a Waze/Google Maps |
| Pagos | Mercado Pago |

## Estado del proyecto

- [x] Definición del modelo de negocio y plan piloto (Quilpué / Villa Alemana)
- [x] Modelo de datos
- [x] Esquema SQL inicial
- [ ] Configurar proyecto Supabase real y aplicar migración
- [ ] Conectar Flutter con Supabase (auth + queries)
- [ ] Flujo de crear tarea → alerta → aceptar
- [ ] Integración de pagos (Mercado Pago)
- [ ] Notificaciones push (Firebase)

## Cómo levantar el proyecto

### Base de datos (Supabase)
1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En el editor SQL, ejecuta el contenido de `supabase/migrations/0001_init.sql`.
3. Copia la URL del proyecto y la `anon key` para usarlas en la app.

### App móvil (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
