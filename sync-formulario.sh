#!/bin/bash
# Publica el embudo de calificación en este dominio, todo bajo shu.stepherup.com (así el lead y sus datos quedan en un solo origen):
#   shu.stepherup.com/landing/              la VSL (../step-her-up/index.html); su botón "Aplicar" va a /formulario/
#   shu.stepherup.com/formulario/           el quiz (../step-her-up/formulario.html); al terminar sigue a calendario.html
#   shu.stepherup.com/formulario/calendario.html
# Las imágenes siguen leyéndose del repo del funnel (rutas absolutas); son archivos, no se ven como link de la página.
# Úsalo cada vez que cambien index.html, formulario.html o calendario.html:
#   ./sync-formulario.sh && git add -A && git commit -m "Sync formulario" && git push
# (SRC=/otra/carpeta ./sync-formulario.sh   para tomar los archivos de otro checkout)
set -e
cd "$(dirname "$0")"
SRC="${SRC:-../step-her-up}"
mkdir -p formulario landing
cp "$SRC/formulario.html" formulario/index.html
cp "$SRC/calendario.html" formulario/calendario.html
SRC="$SRC" python3 - <<'PY'
import os, re
base = "https://thomasaguero009-cyber.github.io/step-her-up/"
s = open(os.environ["SRC"] + "/index.html", encoding="utf-8").read()
# rutas relativas a archivos del funnel -> absolutas
s = re.sub(r'(src|href|poster)="((?:assets|images)/[^"]+)"', lambda m: f'{m.group(1)}="{base}{m.group(2)}"', s)
# el botón "Aplicar al programa" pasa al formulario de este mismo dominio
for antes, despues in [('id="applyBtn" href="formulario.html"', 'id="applyBtn" href="/formulario/"'),
                       ('applyBtn.href = "formulario.html?"', 'applyBtn.href = "/formulario/?"')]:
    assert s.count(antes) == 1, antes
    s = s.replace(antes, despues)
assert 'src="assets/' not in s and 'src="images/' not in s and 'poster="assets/' not in s
open("landing/index.html", "w", encoding="utf-8").write(s)
print("landing/index.html:", len(s), "bytes")
PY
echo "listo: landing/index.html, formulario/index.html y formulario/calendario.html"
