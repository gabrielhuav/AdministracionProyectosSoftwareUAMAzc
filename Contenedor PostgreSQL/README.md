# Contenedor de prueba · PostgreSQL 18

**UEA 1151055 · Administración de Proyectos de Software · Trimestre 26-O**
UAM Azcapotzalco · División de CBI · Departamento de Sistemas

Entorno mínimo para comprobar que Docker Desktop quedó bien instalado y que el
equipo puede levantar una base de datos idéntica en todas sus computadoras.
Es el punto de partida de la **Práctica 1** (semana 2, jueves 24 de septiembre).

> ### ¿Es tu primera vez con Docker?
>
> **Empieza por [TUTORIAL.md](TUTORIAL.md)**, que te lleva paso a paso desde
> instalar Docker Desktop hasta consultar la base, y dice qué vas a ver en
> pantalla en cada momento.
>
> Este README es la **referencia**: sirve para consultar un detalle concreto
> cuando ya tienes el entorno funcionando.

---

## Los cuatro comandos

No hay que preparar nada antes. Con estos cuatro se trabaja todo el trimestre.
Lo único: **Docker Desktop tiene que estar abierto** antes del primero.

```bash
docker compose up -d
```

```bash
docker compose exec db bash
```

```bash
bash extras/comprobar.sh
```

```bash
docker compose stop
```

| # | Comando | Qué hace | Dónde se escribe |
|---|---|---|---|
| 1 | `docker compose up -d` | Prende. La primera vez construye la imagen. | En tu terminal de Windows, dentro de esta carpeta |
| 2 | `docker compose exec db bash` | Entra al contenedor. Apareces en `/trabajo`. | En tu terminal de Windows |
| 3 | `bash extras/comprobar.sh` | Comprueba que todo responde. | **Ya dentro**, en la terminal del paso 2 |
| 4 | `docker compose stop` | Apaga. No borra nada. | Fuera del contenedor: primero `exit` |

> **Los comandos de Docker se escriben FUERA del contenedor.** Si escribes
> `docker compose stop` estando dentro sale `bash: docker: command not found`.
> Está bien que así sea: es la prueba del aislamiento. Primero `exit`, después
> el comando.

### Sobre la `-d`

`up -d` prende y te devuelve la terminal. Si escribes `docker compose up` sin
la `-d`, la terminal se queda *enganchada* mostrando los registros de los
contenedores y parece colgada. No lo está. Para salir de ahí: `Ctrl + C`, y
después `docker compose up -d`.

### Qué debe salir en el paso 3

```
1 · Donde me estoy ejecutando        OK
2 · El servidor responde             OK
3 · Version de PostgreSQL            OK   PostgreSQL 18.6
4 · Donde guarda los datos           OK   PGDATA = /var/lib/postgresql/18/docker
5 · Codificacion de la base          OK   UTF8
6 · El esquema de prueba             OK
7 · Una consulta con JOIN            OK   3 filas
8 · Escribir en la base              OK
9 · La carpeta del proyecto          OK

Todo en orden: 9 de 9 comprobaciones.
```

Si alguna dice `FALLA`, el propio script explica qué significa y qué hacer.

### Sobre `--build`

La primera vez, `up -d` construye la imagen solo: no hace falta `--build`.
Sólo se añade cuando **cambias el `Dockerfile`**:

```bash
docker compose up -d --build
```

---

## El archivo `.env` (recomendado, no obligatorio)

Para que arranque a la primera, el `compose.yaml` trae valores por defecto:

| Variable | Valor por defecto |
|---|---|
| `POSTGRES_DB` | `proyecto` |
| `POSTGRES_USER` | `proyecto` |
| `POSTGRES_PASSWORD` | `practica_local_26o` |
| `POSTGRES_PORT` | `5434` |
| `ADMINER_PORT` | `8080` |

Con eso basta para practicar. Pero **una contraseña escrita en un archivo que
se versiona es justo lo que no se debe hacer**, y aquí sólo se tolera porque
este contenedor se publica únicamente en `127.0.0.1`.

En el proyecto de tu equipo, crea tu propio `.env`. Lo que pongas ahí gana
sobre los valores por defecto:

**Símbolo del sistema (`cmd.exe`)**

```bash
copy .env.example .env
```

**PowerShell**

```bash
Copy-Item .env.example .env
```

**Git Bash, macOS o Linux**

```bash
cp .env.example .env
```

Abre el `.env`, cambia `POSTGRES_PASSWORD`, y vuelve a crear la base:

```bash
docker compose down -v && docker compose up -d
```

> El `down -v` es necesario: la contraseña **se fija cuando se crea la base**.
> Cambiar el `.env` con la base ya creada no la cambia, y entonces sale
> `password authentication failed`.

El `.env` está en el `.gitignore` y no se sube nunca. El que sí se sube es el
`.env.example`, que le dice al equipo qué variables hacen falta.

---

## Qué levanta

| Servicio | Imagen | Para qué | Dónde se ve |
|---|---|---|---|
| `db` | construida sobre `postgres:18.6` | La base de datos | `localhost:5434` |
| `adminer` | `adminer:5.5.1` | Interfaz web para verla sin instalar nada | <http://localhost:8080> |

Para entrar a Adminer: servidor `db`, y el usuario, contraseña y base que
estés usando. Con los valores por defecto: `proyecto` / `practica_local_26o` /
`proyecto`.

> El servidor es `db`, **no** `localhost`. Dentro de la red de Compose los
> servicios se encuentran por el nombre del servicio. `localhost`, desde el
> contenedor de Adminer, sería el propio Adminer.

---

## Qué hace el `Dockerfile`

Parte de la imagen oficial y le añade sólo lo que la imagen no trae:

| Instrucción | Qué hace aquí |
|---|---|
| `FROM postgres:18.6` | La base. Versión completa fijada, nunca `latest`. |
| `RUN apt-get install nano less` | Editar y leer sin salir del contenedor. |
| `ENV LANG TZ PAGER` | Acentos, hora de la Ciudad de México, paginador de `psql`. |
| `WORKDIR /trabajo` | La carpeta en la que apareces al entrar con `exec`. |

No lleva `CMD` ni `ENTRYPOINT`: los hereda de la imagen oficial, que es la que
sabe inicializar el cluster y arrancar el servidor. Tampoco lleva `EXPOSE`:
`EXPOSE` sólo *documenta* un puerto, quien lo publica es la clave `ports:` del
`compose.yaml`.

### `Dockerfile` y `compose.yaml` no son lo mismo

| | Qué es | Qué dice |
|---|---|---|
| `Dockerfile` | El **plano de fabricación** | **QUÉ** lleva dentro la imagen. Se usa una vez, al construir. |
| `compose.yaml` | El **manual de arranque** | **CÓMO** se pone a correr: qué carpeta se comparte, qué puerto se publica, qué variables se fijan. Se usa cada día. |

En el `compose.yaml`, el servicio `db` tiene las dos claves:

```yaml
build: .                      # construye con el Dockerfile de esta carpeta
image: postgres-1151055:26o   # el nombre que tendrá la imagen construida
```

Cuando aparecen las dos, `image:` **no es de dónde se baja: es cómo se va a
llamar la tuya**. Para verla: `docker image ls`.

Sólo hay que volver a escribir `--build` cuando **cambies el `Dockerfile`**:

```bash
docker compose up -d --build
```

El resto del trimestre, `docker compose up -d` a secas.

---

## `stop`, `down` y `down -v`

La confusión más frecuente del curso:

| Comando | Qué hace | ¿Se pierden los datos? |
|---|---|---|
| `docker compose stop` | Apaga los contenedores, como un interruptor | No |
| `docker compose down` | Los apaga **y los borra** | No |
| `docker compose down -v` | Además borra el volumen `datos_db` | **Sí, todos** |

`down` borra los contenedores, no los datos: éstos viven en el volumen con
nombre `datos_db`, que Docker administra aparte. Por eso `up -d` después de un
`down` devuelve la base tal como estaba.

**Para el día a día, usa `stop`.** Deja `down -v` para cuando quieras volver a
empezar de cero, por ejemplo para que se vuelvan a ejecutar los scripts de
`initdb/`.

> El paso 8 de `comprobar.sh` deja un registro cada vez que lo corres. Ese
> número creciendo es la prueba de que el volumen conserva los datos: apaga con
> `stop`, vuelve a prender y córrelo otra vez.

---

## Jugar con la base

Ya dentro del contenedor:

```bash
psql -U proyecto -d proyecto
```

Órdenes de `psql` (empiezan con barra invertida y no llevan `;`):

| Orden | Qué hace |
|---|---|
| `\dt` | Listar las tablas |
| `\d historia` | Describir una tabla |
| `\l` | Listar las bases |
| `\x` | Salida vertical, útil con muchas columnas |
| `\q` | Salir |

Y hay consultas de ejemplo listas para ejecutar:

```bash
psql -U proyecto -d proyecto -f extras/ejemplos/consultas.sql
```

---

## Qué se actualizó respecto de la plantilla anterior

Esta plantilla reemplaza a la de trimestres anteriores. Cada cambio tiene su
motivo, y varios son los que se evalúan en la Práctica 1.

### 1 · `compose.yaml`, no `docker-compose.yml`

Hacen exactamente lo mismo; la diferencia es histórica. `compose.yaml` es el
nombre que recomienda la **Compose Specification**, la especificación abierta
que Docker sigue desde Compose V2. Docker busca los archivos en este orden y se
queda con el primero: `compose.yaml`, `compose.yml`, `docker-compose.yaml`,
`docker-compose.yml`.

> No pongas los dos en la misma carpeta: Docker usaría `compose.yaml` y el otro
> no se leería nunca. De ahí el desconcierto de «edité el archivo y no pasa nada».

### 2 · Fuera la clave `version:`

```yaml
version: '3.8'     # obsoleta
```

Compose V2 la ignora y avisa que es obsoleta. Se borra.

### 3 · PostgreSQL 18 cambió el punto de montaje

El cambio más importante, y el que rompe las plantillas viejas:

| Versión | `PGDATA` | Qué se monta |
|---|---|---|
| 17 y anteriores | `/var/lib/postgresql/data` | `datos:/var/lib/postgresql/data` |
| **18 en adelante** | `/var/lib/postgresql/18/docker` | `datos:/var/lib/postgresql` |

Si montas la ruta vieja con la imagen 18, **el contenedor no arranca**: sale
con código 1 y el log dice

```
Error: in 18+, these Docker images are configured to store database data in a
       format which is compatible with "pg_ctlcluster" ...
       Counter to that, there appears to be PostgreSQL data in:
         /var/lib/postgresql/data (unused mount/volume)
```

Por eso este `compose.yaml` monta `datos_db:/var/lib/postgresql`, sin el `/data`.

### 4 · Volumen con nombre en vez de `./data`

La plantilla anterior usaba `./data:/var/lib/postgresql/data`, una carpeta del
proyecto (*bind mount*). Tiene dos problemas: se cuela al repositorio si falta
el `.gitignore`, y en Windows y macOS los permisos del directorio de datos de
PostgreSQL dan guerra. Un volumen con nombre lo administra Docker.

La regla corta para saber qué borra `down -v`:

> Si la ruta empieza por `.` o por `/` → es una carpeta tuya, y `-v` **no la toca**.
> Si es un nombre a secas → es un volumen de Docker, y `-v` **sí lo borra**.

### 5 · Las contraseñas pueden salir de un archivo aparte

La plantilla anterior traía `POSTGRES_PASSWORD: postgres` escrito dentro del
`compose.yaml` y no había manera de cambiarlo sin editar el archivo que se
versiona. Ahora hay un valor por defecto para que el contenedor de práctica
levante a la primera, pero cualquier `.env` lo sustituye sin tocar el
`compose.yaml`; el repositorio lleva el `.env.example` que documenta las
variables. En el proyecto del equipo se usa el `.env`.

### 6 · El puerto se publica sólo en tu máquina

```yaml
- "127.0.0.1:5434:5432"      # sólo esta computadora
- "5434:5432"                # visible desde la red local
```

Los puertos se leen **mi máquina : contenedor**. El de la izquierda lo eliges tú
y se cambia si está ocupado; el de la derecha lo fija PostgreSQL y no se toca.

### 7 · Versión completa fijada

`postgres:18.6`, no `postgres:latest` ni `postgres:18`. `latest` no significa
«estable», significa «la última que subieron». Fijar la versión es lo que hace
que el proyecto siga levantando dentro de un año, y es **requisito de entrega**.

### 8 · `healthcheck` y `depends_on: condition`

`depends_on` a secas sólo espera a que el contenedor **exista**, no a que la
base **responda**. Con `condition: service_healthy`, Adminer arranca cuando
`pg_isready` confirma que PostgreSQL acepta conexiones.

### 9 · `name:` del proyecto

Sin esa clave, Compose nombra el proyecto según la carpeta. Si un integrante la
llama `contenedor` y otro `Contenedor PostgreSQL`, acaban con contenedores y
volúmenes distintos sin darse cuenta.

### 10 · El `Dockerfile` ahora hace algo

El anterior era `FROM postgres:17` más `EXPOSE 5432`, y eso no instala ni copia
nada: producía una copia de la imagen oficial con otro nombre. El de ahora
añade las herramientas del entorno y fija `/trabajo`, que es lo que permite
entrar con `exec` y correr `extras/comprobar.sh`.

---

## Cuando algo falla

Antes de borrar nada, en este orden:

```bash
docker compose ps -a
```

```bash
docker compose logs db
```

Primero `ps -a`: ¿está encendido, apagado, o nunca arrancó? Después `logs`:
¿qué dijo antes de morir? El 90 % de los problemas se resuelve leyendo la
última línea de `logs`.

| Lo que sale | Casi siempre es | Qué hacer |
|---|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop no está abierto | Abrirlo y esperar a que el icono deje de animarse |
| `port is already allocated` | Otro programa usa el 5434 | Cambiar `POSTGRES_PORT` en el `.env` |
| `Error: in 18+, these Docker images are configured...` y sale con código 1 | Punto de montaje de PostgreSQL 17 con la imagen 18 | Montar `/var/lib/postgresql`, sin `/data`; si había datos, respaldar y restaurar |
| `password authentication failed` | Creaste o cambiaste el `.env` con la base ya creada | La contraseña se fija al inicializar: `down -v` y `up -d` |
| `database "proyecto" does not exist` | El volumen se creó con otro `POSTGRES_DB` | `down -v` y `up -d` |
| Los scripts de `initdb/` no se ejecutan | Sólo corren con el volumen vacío | `down -v` y `up -d` |
| `bash: docker: command not found` | Escribiste el comando **dentro** del contenedor | `exit` primero |
| `service "db" is not running` al hacer `exec` | Está apagado | `docker compose up -d` primero |
| `comprobar.sh: cannot execute: required file not found` | El script se guardó con finales de línea de Windows | Lo evita el `.gitattributes`; si ya pasó: `sed -i 's/\r$//' extras/comprobar.sh` |
| `Database is uninitialized and superuser password is not specified` | Un `.env` vacío o sin `POSTGRES_PASSWORD` | Revisar el `.env`, después `down -v` y `up -d` |
| `dependency failed to start: container apsw_db is unhealthy` | Adminer esperaba a la base y la base nunca arrancó | El problema está en `db`: `docker compose logs db` |
| El servicio dice `Restarting (1)` una y otra vez | La base falla al arrancar y `restart: unless-stopped` la reintenta | `docker compose down`, leer `logs db`, arreglar y `up -d` |

### Empezar de cero sin miedo

```bash
docker compose down -v && docker compose up -d
```

Borra los datos de prueba y vuelve a ejecutar `initdb/`. Tarda segundos.

---

## Estructura

```
Contenedor PostgreSQL/
  Dockerfile            qué lleva dentro la imagen
  compose.yaml          cómo se levanta el sistema
  .env.example          qué variables hacen falta  (SÍ se versiona)
  .env                  tus contraseñas            (NO se versiona)
  .gitignore
  .gitattributes        obliga a finales de línea LF en los .sh
  initdb/
    01_esquema.sql      se ejecuta al crear la base por primera vez
  extras/
    comprobar.sh        las nueve comprobaciones del entorno
    ejemplos/
      consultas.sql     consultas de ejemplo para psql
  README.md
```

Todo menos el `.env` **va al repositorio**: es parte de la entrega, no un
accesorio. Es lo que permite que otra persona reconstruya el entorno.

---

## Las cinco reglas que no se negocian

1. **Nunca `latest`.** Fija siempre la versión.
2. **Lee el error antes de borrar nada.** `ps -a`, después `logs`.
3. **Lo que no se puede perder va en un volumen.** El contenedor es desechable.
4. **`stop` apaga; `down` borra el contenedor.** Sólo `down -v` toca los datos.
5. **El `Dockerfile` y el `compose.yaml` van en el repositorio.** Son parte del trabajo.

---

*Material del curso · M. en C. Gabriel Hurtado Avilés · Trimestre 26-O*
