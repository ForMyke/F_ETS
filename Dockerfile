FROM debian:12-slim AS base

ARG FLUTTER_VERSION=3.44.0

RUN apt-get update -q && \
    apt-get install -y -q --no-install-recommends \
        curl git unzip xz-utils ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --no-analytics && \
    flutter precache --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get


FROM base AS builder

COPY . .
RUN flutter build web --release


FROM nginx:alpine AS prod

COPY --from=builder /app/build/web /usr/share/nginx/html

RUN printf 'server {\n    listen 8080;\n    root /usr/share/nginx/html;\n    index index.html;\n    location / { try_files $uri $uri/ /index.html; }\n}\n' \
    > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

FROM base AS dev

EXPOSE 5000
CMD ["flutter", "run", "-d", "web-server", \
     "--web-port=5000", "--web-hostname=0.0.0.0"]
