#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Comprobacion del entorno · Contenedor PostgreSQL (17 o 18)
# UEA 1151055 · Administracion de Proyectos de Software · Trimestre 26-O
#
# Se ejecuta DENTRO del contenedor:
#     docker compose exec db bash
#     bash extras/comprobar.sh
#
# Revisa nueve cosas y al final dice cuantas pasaron. Si alguna falla,
# explica que significa y que hacer.
# ---------------------------------------------------------------------------

OK=0
FALLA=0

verde()  { printf '\033[32m%s\033[0m\n' "$1"; }
rojo()   { printf '\033[31m%s\033[0m\n' "$1"; }
gris()   { printf '\033[90m%s\033[0m\n' "$1"; }
titulo() { printf '\n\033[1m%s\033[0m\n' "$1"; }

pasa()  { OK=$((OK+1));       verde "  OK    $1"; }
falla() { FALLA=$((FALLA+1)); rojo  "  FALLA $1"; [ -n "$2" ] && gris "        $2"; }

printf '\033[1m'
echo "==========================================================="
echo " Comprobacion del entorno · PostgreSQL · UEA 1151055"
echo "==========================================================="
printf '\033[0m'

# --- 1 · ¿Estoy dentro del contenedor? ------------------------------------
titulo "1 · Donde me estoy ejecutando"
if [ -f /.dockerenv ]; then
    pasa "Estoy dentro del contenedor ($(hostname))"
else
    falla "Esto no parece un contenedor" \
          "Entra primero con: docker compose exec db bash"
    echo
    rojo "Comprobacion cancelada."
    exit 1
fi

# --- 2 · ¿La base responde? -----------------------------------------------
titulo "2 · El servidor responde"
# Se pregunta por TCP (127.0.0.1) y no por el socket: mientras la imagen
# inicializa la base levanta un servidor TEMPORAL que solo escucha por
# socket. Por TCP solo contesta el servidor definitivo, ya con el esquema.
# Justo despues de «up -d» la base puede seguir arrancando: se espera
# hasta 60 segundos antes de darla por caida.
LISTO=no
for i in $(seq 1 60); do
    if pg_isready -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
        LISTO=si
        break
    fi
    [ "$i" = 1 ] && gris "        La base todavia esta arrancando; espero hasta 60 segundos..."
    sleep 1
done
if [ "$LISTO" = si ]; then
    pasa "pg_isready acepta conexiones"
else
    falla "PostgreSQL no acepta conexiones despues de 60 segundos" \
          "Sal con exit y mira: docker compose logs db"
    echo
    rojo "Comprobacion cancelada: sin base de datos no se puede seguir."
    exit 1
fi

# atajo para consultar: -A sin formato, -t sin encabezado, -c un comando
consulta() { psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atc "$1" 2>/dev/null; }

# --- 3 · Version del servidor ---------------------------------------------
titulo "3 · Version de PostgreSQL"
VER=$(consulta "SHOW server_version;")
MAYOR=${VER%%.*}
case "$MAYOR" in
    17|18) pasa "PostgreSQL $VER" ;;
    "")    falla "No se pudo consultar la version" ;;
    *)     falla "PostgreSQL $VER: este entorno espera la 17 o la 18" \
                 "Revisa la linea FROM del Dockerfile" ;;
esac

# --- 4 · Donde guarda los datos (cambia de la 17 a la 18) -----------------
titulo "4 · Donde guarda los datos"
DIR=$(consulta "SHOW data_directory;")
if [ "$MAYOR" = "17" ]; then
    ESPERADO="/var/lib/postgresql/data"
else
    ESPERADO="/var/lib/postgresql/${MAYOR}/docker"
fi
if [ "$DIR" = "$ESPERADO" ]; then
    pasa "PGDATA = $DIR"
    if [ "$MAYOR" = "17" ]; then
        gris "        En la 17 los datos viven en /var/lib/postgresql/data y ahi"
        gris "        se monta el volumen. En la 18 esto CAMBIA: ojo al actualizar."
    else
        gris "        En la 17 era /var/lib/postgresql/data. Por eso el volumen"
        gris "        se monta en /var/lib/postgresql, sin el /data del final."
    fi
else
    falla "PGDATA = $DIR, se esperaba $ESPERADO" \
          "Revisa el punto de montaje del volumen en el compose.yaml"
fi

# --- 5 · Codificacion -----------------------------------------------------
titulo "5 · Codificacion de la base"
ENC=$(consulta "SHOW server_encoding;")
if [ "$ENC" = "UTF8" ]; then
    pasa "server_encoding = UTF8 (los acentos se guardan bien)"
else
    falla "server_encoding = $ENC, se esperaba UTF8" \
          "Se fija al crear la base: docker compose down -v && docker compose up -d"
fi

# --- 6 · ¿Se ejecutaron los scripts de initdb? ----------------------------
titulo "6 · El esquema de prueba"
TABLAS=$(consulta "SELECT count(*) FROM information_schema.tables
                   WHERE table_schema='public' AND table_name IN ('equipo','historia');")
if [ "$TABLAS" = "2" ]; then
    pasa "Existen las tablas equipo e historia"
else
    falla "Faltan tablas del esquema de prueba (encontradas: ${TABLAS:-0} de 2)" \
          "initdb solo corre con el volumen vacio: down -v y up -d"
fi

# --- 7 · Una consulta de verdad -------------------------------------------
titulo "7 · Una consulta con JOIN"
FILAS=$(consulta "SELECT count(*) FROM historia h JOIN equipo e ON e.id = h.responsable;")
if [ -n "$FILAS" ] && [ "$FILAS" -ge 3 ] 2>/dev/null; then
    pasa "La consulta devuelve $FILAS filas"
    echo
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
        "SELECT h.id, h.titulo, h.puntos, h.estado, e.nombre AS responsable
           FROM historia h JOIN equipo e ON e.id = h.responsable
          ORDER BY h.id;" 2>/dev/null
else
    falla "La consulta no devolvio las filas esperadas" \
          "Revisa initdb/01_esquema.sql"
fi

# --- 8 · Escritura y persistencia -----------------------------------------
titulo "8 · Escribir en la base"
MARCA="prueba-$(date +%s)"
if consulta "CREATE TABLE IF NOT EXISTS comprobacion (
                 id serial PRIMARY KEY,
                 marca text NOT NULL,
                 cuando timestamptz NOT NULL DEFAULT now());
             INSERT INTO comprobacion (marca) VALUES ('$MARCA');" >/dev/null; then
    TOTAL=$(consulta "SELECT count(*) FROM comprobacion;")
    if [ "$TOTAL" = "1" ]; then PL="registro"; else PL="registros"; fi
    pasa "Escritura correcta (la tabla comprobacion lleva $TOTAL $PL)"
    gris "        Este numero crece cada vez que corres el script: esa es la"
    gris "        prueba de que el volumen conserva los datos entre reinicios."
else
    falla "No se pudo escribir en la base" \
          "Revisa que POSTGRES_USER del .env sea el dueno de la base"
fi

# --- 9 · ¿Veo la carpeta del proyecto? ------------------------------------
titulo "9 · La carpeta del proyecto"
if [ -f /trabajo/compose.yaml ] && [ -f /trabajo/Dockerfile ]; then
    pasa "Veo compose.yaml y Dockerfile en /trabajo"
    gris "        Es la misma carpeta que ves en el Explorador de Windows:"
    gris "        lo que escribas aqui aparece alla, y al reves."
else
    falla "No veo los archivos del proyecto en /trabajo" \
          "Revisa la linea './:/trabajo' en volumes: del compose.yaml"
fi

# --- resumen ---------------------------------------------------------------
echo
printf '\033[1m'
echo "==========================================================="
printf '\033[0m'
if [ "$FALLA" -eq 0 ]; then
    verde " Todo en orden: $OK de $((OK+FALLA)) comprobaciones."
    if [ "$POSTGRES_PASSWORD" = "practica_local_26o" ]; then
        echo
        printf '\033[33m%s\033[0m\n' " AVISO  Estas usando la contrasena por defecto."
        gris "        Sirve para practicar, pero en el proyecto de tu equipo"
        gris "        crea un .env con una propia. Sal con exit y ejecuta:"
        gris "            copy .env.example .env      (Simbolo del sistema)"
        gris "            docker compose down -v && docker compose up -d"
    fi
    echo
    gris " Ya puedes trabajar. Para entrar a la base:"
    gris "     psql -U $POSTGRES_USER -d $POSTGRES_DB"
    gris " Para salir del contenedor sin apagarlo:  exit"
    gris " Para apagarlo (fuera del contenedor):    docker compose stop"
else
    rojo " $FALLA de $((OK+FALLA)) comprobaciones fallaron."
    echo
    gris " Lee el mensaje de cada FALLA antes de borrar nada."
    gris " Casi siempre se arregla con:  exit"
    gris "                               docker compose down -v"
    gris "                               docker compose up -d"
fi
printf '\033[1m'
echo "==========================================================="
printf '\033[0m'

exit $(( FALLA > 0 ? 1 : 0 ))
