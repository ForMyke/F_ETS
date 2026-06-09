# F_ETS — Flutter Web

App Flutter compilada y servida con Docker. Tiene dos modos: **producción** (build estático con `dhttpd`) y **desarrollo** (hot-reload con `flutter run`).

---

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) con el plugin Compose v2
- `make` (viene preinstalado en macOS y Linux)

No necesitas tener Flutter ni Dart instalados localmente; todo corre dentro del contenedor.

---

## Comandos rápidos (via `make`)

Ejecuta `make help` para ver todos los comandos disponibles:

```
make help
```

### Producción — http://localhost:8080

| Comando        | Descripción                                 |
|----------------|---------------------------------------------|
| `make build-prod` | Construye la imagen de producción        |
| `make up`      | Levanta el contenedor en segundo plano      |
| `make down`    | Detiene y elimina el contenedor             |
| `make restart` | Reinicia el contenedor                      |
| `make logs`    | Sigue los logs en tiempo real               |
| `make shell`   | Abre una shell dentro del contenedor        |

Flujo habitual:

```bash
make build-prod   # Solo la primera vez o cuando cambies dependencias
make up           # Levanta en segundo plano
make logs         # Verifica que arrancó bien
```

### Desarrollo (hot-reload) — http://localhost:5000

| Comando         | Descripción                                        |
|-----------------|----------------------------------------------------|
| `make dev-build`| Construye la imagen de desarrollo                  |
| `make dev`      | Levanta con hot-reload (se queda en foreground)    |
| `make dev-down` | Detiene el contenedor de desarrollo                |
| `make dev-logs` | Sigue los logs de desarrollo                       |
| `make dev-shell`| Abre una shell en el contenedor de desarrollo      |

Flujo habitual:

```bash
make dev-build   # Solo la primera vez o cuando cambies pubspec.yaml
make dev         # Levanta con hot-reload en foreground
```

Los cambios en `lib/` se reflejan al recargar el navegador (el volumen monta el directorio local directamente en el contenedor).

### Limpiar todo

```bash
make clean    # Elimina contenedores, imágenes y volúmenes
make rebuild  # Reconstruye todo sin usar caché de Docker
```

---

## Estructura del proyecto

```
F_ETS/
├── Dockerfile           # Multi-stage: base → builder → prod / dev
├── docker-compose.yml   # Servicios flutter-web (prod) y flutter-dev (dev)
├── Makefile             # Atajos para los comandos de Docker Compose
├── lib/                 # Código Dart/Flutter
├── web/                 # Assets y entrypoint web (index.html, manifest…)
├── pubspec.yaml         # Dependencias Flutter
└── pubspec.lock
```

---

## Notas

- **Flutter SDK**: `3.44.0` (definido en `Dockerfile` vía `ARG FLUTTER_VERSION`).
- El primer build tarda ~5-10 min porque descarga el SDK de Flutter desde GitHub. Las siguientes veces son mucho más rápidas gracias al caché de capas de Docker.
- Si cambias `pubspec.yaml` debes reconstruir la imagen (`make build-prod` o `make dev-build`) para que `flutter pub get` instale las nuevas dependencias.
- En modo desarrollo el código fuente se monta como volumen, por lo que los cambios en `lib/` no requieren reconstruir la imagen.
