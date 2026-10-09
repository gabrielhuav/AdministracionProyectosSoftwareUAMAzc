# ---------------------------------------------------------------------------
# Contenedor de prueba · PostgreSQL 18
# UEA 1151055 · Administración de Proyectos de Software · Trimestre 26-O
#
# Este Dockerfile parte de la imagen oficial y le añade sólo lo que el
# entorno del curso necesita y la imagen no trae:
#   · nano y less, para editar y leer sin salir del contenedor
#   · la zona horaria y la codificación del curso
#   · /trabajo como carpeta de entrada, donde se monta tu proyecto
#
# Se construye solo con «docker compose up -d --build».
# ---------------------------------------------------------------------------

# Versión completa fijada: 18.6, no «18» ni «latest».
# latest no significa estable, significa «la última que subieron».
FROM postgres:18.6

# Un solo RUN: cada instrucción crea una capa, y encadenar con && pesa menos.
# El rm -rf del final borra el índice de paquetes que ya no sirve (~40 MB).
RUN apt-get update && apt-get install -y --no-install-recommends \
        nano \
        less \
    && rm -rf /var/lib/apt/lists/*

# Acentos, hora de la Ciudad de México y paginador para psql.
ENV LANG=C.UTF-8 \
    TZ=America/Mexico_City \
    PAGER=less

# Al entrar con «docker compose exec db bash» apareces aquí.
# El compose.yaml monta esta carpeta del proyecto en este punto,
# así que dentro ves los mismos archivos que en el Explorador de Windows.
WORKDIR /trabajo

# No se escribe CMD ni ENTRYPOINT: los hereda de la imagen oficial, que es
# la que sabe inicializar el cluster y arrancar el servidor.
