#!/bin/bash

# 1. Definimos el nombre del feature (cámbialo por 'login', 'home', etc. en el futuro)
FEATURE="number_trivia"

echo "🚀 Iniciando creación de Clean Architecture para: $FEATURE..."

# ---------------------------------------------------------
# 2. CREAR ESTRUCTURA CORE (Compartida)
# ---------------------------------------------------------
echo "📂 Creando Core..."
mkdir -p lib/core/{error,network,usecases,util}
mkdir -p test/core/{error,network,usecases,util}

# ---------------------------------------------------------
# 3. CREAR ESTRUCTURA DEL FEATURE (En lib)
# ---------------------------------------------------------
echo "📂 Creando Feature: $FEATURE en lib..."
mkdir -p lib/features/$FEATURE/data/{datasources,models,repositories}
mkdir -p lib/features/$FEATURE/domain/{entities,repositories,usecases}
mkdir -p lib/features/$FEATURE/presentation/{bloc,pages,widgets}

# ---------------------------------------------------------
# 4. CREAR ESTRUCTURA DEL FEATURE (En test - Mirror)
# ---------------------------------------------------------
echo "📂 Creando Feature: $FEATURE en test..."
mkdir -p test/features/$FEATURE/data/{datasources,models,repositories}
mkdir -p test/features/$FEATURE/domain/{entities,repositories,usecases}
mkdir -p test/features/$FEATURE/presentation/{bloc,pages,widgets}

# ---------------------------------------------------------
# 5. EXTRAS (Fixtures)
# ---------------------------------------------------------
mkdir -p test/fixtures

# ---------------------------------------------------------
# 6. TRUCO PRO: Crear .gitkeep 
# (Para que Git suba las carpetas aunque estén vacías)
# ---------------------------------------------------------
echo "👻 Añadiendo .gitkeep para control de versiones..."
find lib -type d -empty -not -path "*.git*" -exec touch {}/.gitkeep \;
find test -type d -empty -not -path "*.git*" -exec touch {}/.gitkeep \;

echo "✅ ¡Estructura completada con éxito!"
echo "   Revisa tu árbol con: tree -d lib test"
