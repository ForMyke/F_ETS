#!/bin/bash
FEATURE="ets_android"
echo "Iniciando creacion de Clean Architecture para: $FEATURE..."
echo "Creando Core..."
mkdir -p lib/core/{error,network,usecases,util}
mkdir -p test/core/{error,network,usecases,util}
echo "Creando Feature: $FEATURE en lib..."
mkdir -p lib/features/$FEATURE/data/{datasources,models,repositories}
mkdir -p lib/features/$FEATURE/domain/{entities,repositories,usecases}
mkdir -p lib/features/$FEATURE/presentation/{bloc,pages,widgets}
echo "Creando Feature: $FEATURE en test..."
mkdir -p test/features/$FEATURE/data/{datasources,models,repositories}
mkdir -p test/features/$FEATURE/domain/{entities,repositories,usecases}
mkdir -p test/features/$FEATURE/presentation/{bloc,pages,widgets}
mkdir -p test/fixtures
echo "Anadiendo .gitkeep para control de versiones..."
find lib -type d -empty -not -path "*.git*" -exec touch {}/.gitkeep \;
find test -type d -empty -not -path "*.git*" -exec touch {}/.gitkeep \;
echo "Estructura completada con exito!"
echo "   Revisa tu arbol con: tree -d lib test"