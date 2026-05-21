# F_ETS — Flutter Web en Docker

## Estructura de archivos necesaria

```
F_ETS/          ← raíz del proyecto Flutter (donde está pubspec.yaml)
├── Dockerfile
├── docker-compose.yml
├── lib/
├── web/
├── pubspec.yaml
└── ...
```

## Instrucciones

### 1. Colocar los archivos

Copia `Dockerfile`, `docker-compose.yml` y `nginx.conf` dentro de la carpeta
`F_ETS/F_ETS/` (donde está `pubspec.yaml`).

### 2. Build y levantar (producción)

```bash
# Construir la imagen y levantar
docker compose up --build

# En segundo plano
docker compose up --build -d
```

La app estará disponible en: **http://localhost:8080**

### 3. Solo build de la imagen

```bash
docker build -t f_ets_web .
docker run -p 8080:80 f_ets_web
```

### 4. Modo desarrollo (con hot-reload)

```bash
docker compose --profile dev up flutter-dev
```

Disponible en: **http://localhost:5000**

---

## Comandos útiles

```bash
# Ver logs del contenedor
docker logs f_ets_web

# Entrar al contenedor
docker exec -it f_ets_web sh

# Detener
docker compose down

# Reconstruir sin caché
docker compose build --no-cache
```

## Notas

- El build de Flutter tarda ~5-10 minutos la primera vez (descarga el SDK).
- Las siguientes veces es mucho más rápido gracias al caché de Docker.
- Flutter SDK usado: **3.22.2** (compatible con sdk: '>=3.0.0 <4.0.0')
