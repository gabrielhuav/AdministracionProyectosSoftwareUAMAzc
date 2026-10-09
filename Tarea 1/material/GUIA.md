# Tarea 1 · Guía paso a paso

**UEA 1151055 · Administración de Proyectos de Software · Trimestre 26-O**

Qué escribir y qué debe salir en pantalla. Si es su primera vez con Docker, haga
antes el [TUTORIAL.md](../../Contenedor%20PostgreSQL/TUTORIAL.md) del curso.

```
Fase 0 · el repositorio ──────────────────────── commit
Fase A · el contenedor viejo  (PostgreSQL 17) ── commit
Fase B · el contenedor nuevo  (PostgreSQL 18) ── commit
Fase C · otro stack           (MySQL)         ── commit
```

> ⚠️ Use las carpetas de este material, no lo que copió de Classroom: ahí
> faltan `initdb/` y `extras/`, y un archivo aparece como `Dockerfiile`.

---

## Fase 0 · El repositorio

En <https://github.com/new>: un nombre como `administracion-proyectos-1151055`,
**Public**, ✅ *Add a README file* y *Choose a license* → **MIT License**.

Cree el `.gitignore` **en GitHub** (*Add file → Create new file*), no en el Bloc
de notas, que lo guarda como `.gitignore.txt`. Contenido:

```
data/
.env
Thumbs.db
.DS_Store
```

Clónelo con GitHub Desktop (*File → Clone repository*) o con la terminal:

```bash
git clone https://github.com/SU-USUARIO/administracion-proyectos-1151055.git
```

Copie el `.gitattributes` del material a la raíz del repositorio y súbalo:

```bash
git add -A
```

```bash
git commit -m "chore: agrega .gitattributes"
```

```bash
git push
```

> El aviso `LF will be replaced by CRLF` es normal en Windows. Ignórelo.

---

## Fase A · El contenedor viejo (PostgreSQL 17)

Copie el `Dockerfile` y el `docker-compose.yml` de `1-postgres17/` a
`tarea1\postgres\`, **sin cambiarles nada**. Abra la terminal ahí:

```bash
docker compose up -d --build
```

```
WARN ... the attribute `version` is obsolete, it will be ignored
 ✔ Container postgres173CV231AGO2026  Started
```

📸 **1** · `01-pg17-up.png`

```bash
docker compose ps
```

```bash
docker compose exec postgres psql -U postgres -c "SELECT version();"
```

```
 PostgreSQL 17.11 (Debian 17.11-1.pgdg13+2) on x86_64-pc-linux-gnu, ...
```

Si dice `the database system is starting up`, espere unos segundos y repita.

> **Así se comprueba en las tres fases:** `ps` responde *¿está prendido?* y la
> consulta de la versión responde *¿es la que debe ser?*

📸 **2** · `02-pg17-version.png`

Apareció una carpeta `data`: ahí vive la base. **No debe subirse.** Revíselo:

```bash
git add -A
```

```bash
git status
```

```
	new file:   tarea1/postgres/Dockerfile
	new file:   tarea1/postgres/docker-compose.yml
```

Sólo esos dos. Si aparece algo de `data/`, su `.gitignore` está mal: corríjalo
y repita `git add -A`. Si está bien:

```bash
git commit -m "feat: levanta el contenedor de PostgreSQL 17"
```

```bash
git push
```

---

## Fase B · El contenedor nuevo (PostgreSQL 18)

**Primero apague el viejo**, con sus archivos todavía ahí:

```bash
docker compose down
```

Después, en `tarea1\postgres\`: **borre** `docker-compose.yml`, `Dockerfile` y
la carpeta `data`, y **copie** todo el contenido de `2-postgres18/`.

```bash
docker compose up -d
```

```
 ✔ Container apsw_db       Healthy
 ✔ Container apsw_adminer  Started
```

Compruébelo igual que el viejo. Ahora el servicio se llama `db` y el usuario
`proyecto`:

```bash
docker compose ps
```

```
NAME           IMAGE                  STATUS
apsw_adminer   adminer:5.5.1          Up 6 seconds
apsw_db        postgres-1151055:26o   Up 6 seconds (healthy)
```

```bash
docker compose exec db psql -U proyecto -d proyecto -c "SELECT version();"
```

```
 PostgreSQL 18.6 (Debian 18.6-1.pgdg13+2) on x86_64-pc-linux-gnu, ...
```

Fíjese en el `(healthy)`: el viejo no lo tenía, porque no sabía si la base
estaba lista.

📸 **3** · `03-pg18-version.png`

Abra <http://localhost:8080>: PostgreSQL, servidor `db`, usuario y base
`proyecto`, contraseña `practica_local_26o`.

📸 **4** · `04-pg18-adminer.png`

```bash
git add -A
```

```bash
git status
```

Verá tres clases de cambio: `modified` (Dockerfile), `deleted`
(docker-compose.yml) y `new file` (lo demás).

```bash
git commit -m "build!: actualiza el contenedor a PostgreSQL 18"
```

```bash
git push
```

El `!` indica un cambio que rompe la compatibilidad. En GitHub, abra esa
confirmación en **Commits**: lo quitado sale en rojo y lo nuevo en verde.

📸 **5** · `05-pg18-diff.png`

### Para la tabla de diferencias del README

| Busque… | Viejo | Nuevo |
|---|---|---|
| Nombre del archivo | `docker-compose.yml` | `compose.yaml` |
| Primera línea | `version: '3.8'` | No hay |
| Imagen | `postgres:17` | `FROM postgres:18.6` |
| Datos | `./data:/var/lib/postgresql/data` | `datos_db:/var/lib/postgresql` |
| Contraseña | escrita: `postgres` | `${POSTGRES_PASSWORD:-...}` |
| Puerto | `"5432:5432"` | `"127.0.0.1:5434:5432"` |
| ¿Sabe si está lista? | No | `healthcheck` |
| Interfaz web | No | Adminer |
| La carpeta del proyecto, dentro | No, sólo `data/` | `./:/trabajo` |

Y busque la palabra `build` en el `docker-compose.yml` viejo: ¿se usaba el
Dockerfile?

---

## Fase C · Otro stack: MySQL + phpMyAdmin

Copie el `compose.yaml` de `3-mysql/` a `tarea1\mysql\`. Tiene **11 huecos**
(`________`). Llénelos, en orden, con esta tabla:

| # | Concepto | PostgreSQL | MySQL |
|---|---|---|---|
| 1 | Imagen | `postgres:18.6` | `mysql:9.7.2` |
| 2 | Contraseña del administrador | `POSTGRES_PASSWORD` | `MYSQL_ROOT_PASSWORD` |
| 3 | Base | `POSTGRES_DB` | `MYSQL_DATABASE` |
| 4 | Usuario | `POSTGRES_USER` | `MYSQL_USER` |
| 5 | Contraseña del usuario | `POSTGRES_PASSWORD` | `MYSQL_PASSWORD` |
| 6 | Puerto interno | `5432` | `3306` |
| 7 | Carpeta de datos | `/var/lib/postgresql` | `/var/lib/mysql` |
| 8 | Imagen web | `adminer:5.5.1` | `phpmyadmin:5.2.3` |
| 9 | Puerto web interno | `8080` | `80` |
| 10 | Servidor al que se conecta | `ADMINER_DEFAULT_SERVER: db` | `PMA_HOST: db` |
| 11 | Esperar a la base | `service_healthy` | `service_healthy` |

> **LTS.** `mysql:latest` hoy da la **26.7.0**, una versión *innovation* con
> soporte corto. La **9.7.2** es la **LTS**: se mantiene años.

Busque `____` con **Ctrl + F**: no debe quedar ninguno. No mueva los espacios.
Después, desde `tarea1\mysql\`:

```bash
docker compose config --quiet
```

Sin salida, el archivo está bien escrito.

```bash
docker compose up -d
```

```
 ✔ Container tarea1_mysql        Healthy
 ✔ Container tarea1_phpmyadmin   Started
```

MySQL tarda casi un minuto la primera vez.

Se comprueba como las otras dos: con `docker compose ps`, que debe decir
`(healthy)`, y con la versión.

Abra <http://localhost:8081>, entre con `proyecto` / `practica_local_26o` y, en
la pestaña **SQL**:

```sql
SELECT VERSION();
```

📸 **6** · `06-phpmyadmin.png` — debe decir `9.7.2`.

Prenda también el de PostgreSQL: no chocan, usan otros puertos.

```bash
cd ..\postgres
```

```bash
docker compose up -d
```

📸 **7** · `07-docker-desktop.png` — panel *Containers* con los dos grupos.

```bash
git add -A
```

```bash
git commit -m "feat: agrega el stack MySQL + phpMyAdmin"
```

```bash
git push
```

📸 **8** · `08-historial.png` — **Commits** en GitHub: 17, 18 y MySQL, en orden.

Al terminar, `docker compose stop` en cada carpeta.

---

## Si algo sale mal

Antes de borrar nada: `docker compose ps -a` y `docker compose logs`.

| Lo que sale | Qué hacer |
|---|---|
| `Conflict. The container name ... is already in use` | Ya lo había levantado en otra carpeta: bórrelo en Docker Desktop → Containers |
| `port is already allocated` | Otro contenedor o un PostgreSQL instalado usa el puerto: apáguelo |
| `failed to read dockerfile` | El archivo no se llama exactamente `Dockerfile` |
| Adminer no muestra las tablas `equipo` e `historia` | Copió sólo los dos archivos de Classroom. Copie **todo** `2-postgres18/`, con `initdb/`, y luego `docker compose down -v` y `docker compose up -d` |
| `Found multiple config files` | Borre el `docker-compose.yml` viejo |
| `mapping key "________" already defined` | Quedan huecos en `environment` |
| `unable to get image '________'` | Queda un hueco en una `image:` |
| phpMyAdmin: `Cannot log in to the MySQL server` | Revise usuario, contraseña y que `PMA_HOST` sea `db` |

---

*Material del curso · M. en C. Gabriel Hurtado Avilés · Trimestre 26-O*
