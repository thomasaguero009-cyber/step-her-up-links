#!/bin/bash
# Publica el formulario de calificación (../step-her-up/formulario.html) y su calendario en este dominio:
#   shu.stepherup.com/formulario/   (el quiz; al terminar sigue a calendario.html, que queda en la misma carpeta)
# Úsalo cada vez que cambien formulario.html o calendario.html:  ./sync-formulario.sh && git add -A && git commit -m "Sync formulario" && git push
set -e
cd "$(dirname "$0")"
mkdir -p formulario
cp ../step-her-up/formulario.html formulario/index.html
cp ../step-her-up/calendario.html formulario/calendario.html
echo "listo: formulario/index.html y formulario/calendario.html"
