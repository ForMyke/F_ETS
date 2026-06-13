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


FROM dart:stable-slim AS prod

RUN dart pub global activate dhttpd

WORKDIR /app
COPY --from=builder /app/build/web ./build/web

EXPOSE 8080
CMD ["dhttpd", "--path", "build/web", "--host", "0.0.0.0", "--port", "8080"]

FROM base AS dev

EXPOSE 5000
CMD ["flutter", "run", "-d", "web-server", \
     "--web-port=5000", "--web-hostname=0.0.0.0"]
