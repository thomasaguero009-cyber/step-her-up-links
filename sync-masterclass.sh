#!/bin/bash
# Publica la página del webinar (../step-her-up/webinar.html) en este dominio, sin redirigir, en dos versiones:
#   shu.stepherup.com/masterclass/  versión A "sistema-marca"      (el texto tal cual está en webinar.html)
#   shu.stepherup.com/clase/        versión B "sistema-instagram"  (mismo diseño, otro titular)
# Los archivos pesados (logo, fotos, estilos) se siguen leyendo del repo del funnel: hay una sola fuente de verdad.
# Cada versión manda su nombre al registrarse y el Worker lo guarda en el contacto como etiqueta "lp-<versión>".
# Úsalo cada vez que cambie webinar.html:  ./sync-masterclass.sh && git add -A && git commit -m "Sync masterclass" && git push
set -e
cd "$(dirname "$0")"
python3 - <<'PY'
import re
base = "https://thomasaguero009-cyber.github.io/step-her-up/"
fuente = open("../step-her-up/webinar.html", encoding="utf-8").read()

# Textos que cambian en la versión B. Cada par (texto en webinar.html, texto en la versión B) debe aparecer una sola vez.
VERSION_B = [
    ('El sistema para crecer tu marca personal y convertirla en ventas recurrentes. Miércoles 21 de octubre',
     'El sistema de contenido + anuncios que convierte tu Instagram en clientas que pagan. Miércoles 21 de octubre'),
    ('<h1>El sistema para crecer tu marca personal y convertirla en <em>ventas recurrentes</em></h1>',
     '<h1>El sistema de contenido + anuncios que convierte tu Instagram en <em>clientas que pagan</em></h1>'),
    ('<p class="lede">Tu nombre vale. Te muestro el paso a paso completo para posicionar tu servicio, atraer a tus clientas ideales y cobrar lo que vales, sin trabajar más horas.</p>',
     '<p class="lede">Te muestro el paso a paso completo para ordenar tu contenido, atraer a tus clientas ideales desde Instagram y cobrar lo que vales, sin trabajar más horas.</p>'),
    ('const VARIANTE = "sistema-marca";', 'const VARIANTE = "sistema-instagram";'),
]

def publicar(carpeta, cambios):
    s = fuente
    for antes, despues in cambios:
        assert s.count(antes) == 1, f"no encuentro (o está repetido) en webinar.html: {antes[:70]}"
        s = s.replace(antes, despues)
    # rutas relativas a archivos del funnel -> absolutas (los anclas #registro quedan igual)
    s = re.sub(r'(src|href)="((?:assets|images)/[^"]+)"', lambda m: f'{m.group(1)}="{base}{m.group(2)}"', s)
    assert 'src="assets/' not in s and 'src="images/' not in s
    url = f"https://shu.stepherup.com/{carpeta}/"
    s = s.replace('<meta property="og:type" content="website">',
                  f'<meta property="og:type" content="website">\n<meta property="og:url" content="{url}">\n<link rel="canonical" href="{url}">', 1)
    s = s.replace('content="https://thomasaguero009-cyber.github.io/step-her-up/images/gianie/gianie-foto.jpg"',
                  'content="https://shu.stepherup.com/assets/gianie-foto.jpg"', 1)
    open(f"{carpeta}/index.html", "w", encoding="utf-8").write(s)
    print(f"{carpeta}/index.html:", len(s), "bytes")

publicar("masterclass", [])
publicar("clase", VERSION_B)
PY
