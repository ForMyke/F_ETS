#!/bin/bash

FEATURE=${1:-"my_feature"}

echo "Let me cook, I'm working in $FEATURE"

# Crear estructura en lib y test
mkdir -p lib/features/$FEATURE/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
mkdir -p test/features/$FEATURE/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
mkdir -p test/fixtures

echo "Wait a moment, adding .gitkeeps..."

# Añadir .gitkeep en carpetas vacías
find lib/$FEATURE test/$FEATURE -type d -empty -not -path "*.git*" -exec touch {}/.gitkeep \;

echo "It's ready"
echo "--------------------------"
# Ejecuta tree solo en la carpeta de la nueva feature
tree -d lib/features/$FEATURE test/features/$FEATURE
