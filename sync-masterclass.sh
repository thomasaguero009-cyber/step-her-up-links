#!/bin/bash
# Publica la página del webinar (../step-her-up/webinar.html) en shu.stepherup.com/masterclass/
# sin redirigir: la página vive en este dominio. Los archivos pesados (logo, fotos, estilos)
# se siguen leyendo del repo del funnel, así hay una sola fuente de verdad.
# Úsalo cada vez que cambie webinar.html:  ./sync-masterclass.sh && git add -A && git commit -m "Sync masterclass" && git push
set -e
cd "$(dirname "$0")"
python3 - <<'PY'
import re
base = "https://thomasaguero009-cyber.github.io/step-her-up/"
s = open("../step-her-up/webinar.html", encoding="utf-8").read()
# rutas relativas a archivos del funnel -> absolutas (los anclas #registro quedan igual)
s = re.sub(r'(src|href)="((?:assets|images)/[^"]+)"', lambda m: f'{m.group(1)}="{base}{m.group(2)}"', s)
assert 'src="assets/' not in s and 'src="images/' not in s
s = s.replace('<meta property="og:type" content="website">',
              '<meta property="og:type" content="website">\n<meta property="og:url" content="https://shu.stepherup.com/masterclass/">\n<link rel="canonical" href="https://shu.stepherup.com/masterclass/">', 1)
s = s.replace('content="https://thomasaguero009-cyber.github.io/step-her-up/images/gianie/gianie-foto.jpg"',
              'content="https://shu.stepherup.com/assets/gianie-foto.jpg"', 1)
open("masterclass/index.html", "w", encoding="utf-8").write(s)
print("masterclass/index.html:", len(s), "bytes")
PY
