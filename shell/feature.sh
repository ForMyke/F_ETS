#!/bin/bash

FEATURE=${1:-"testiganding"}
cd "$(dirname "$0")/.." || exit
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
tree -d lib/features/