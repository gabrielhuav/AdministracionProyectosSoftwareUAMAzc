# Práctica 1 · Parte A — Tu primer contenedor

**UEA 1151055 · Administración de Proyectos de Software · Trimestre 26-O**
UAM Azcapotzalco · División de CBI · Departamento de Sistemas

---

## Para quién es esto

Para quien **nunca ha usado Docker**. No se supone nada: ni que sepas qué es
una imagen, ni que hayas abierto una terminal antes.

Son nueve pasos. La primera vez tarda entre **10 y 20 minutos**, casi todo
esperando descargas. Después, prender el entorno tarda dos segundos.

Si algo no sale como aquí dice, no sigas adelante: ve a
[Si algo sale mal](#si-algo-sale-mal) al final. Casi todo está previsto.

> Este documento es el **paso a paso**. El [README.md](README.md) es la
> **referencia**: consúltalo después, cuando ya funcione y quieras entender
> el detalle de cada archivo.

---

## Lo que vas a construir

Una base de datos PostgreSQL corriendo en tu computadora, dentro de una caja
aislada, idéntica a la de tus compañeros.

```
   TU COMPUTADORA (Windows)
   ┌──────────────────────────────────────────────┐
   │                                              │
   │   Carpeta "Contenedor PostgreSQL"            │
   │   Dockerfile, compose.yaml, extras/ ...      │
   │              │                               │
   │              │ se comparte                   │
   │              ▼                               │
   │   ┌─────────────────────┐  ┌──────────────┐  │
   │   │  Contenedor  db     │  │  Contenedor  │  │
   │   │                     │  │  adminer     │  │
   │   │  PostgreSQL 18.6    │  │              │  │
   │   │  /trabajo  ◄────────┼──┤ página web   │  │
   │   └─────────────────────┘  └──────────────┘  │
   │            │                      │          │
   │      localhost:5434        localhost:8080    │
   └──────────────────────────────────────────────┘
```

Dos palabras, y son las únicas que necesitas por ahora:

| Palabra | Qué es | Analogía |
|---|---|---|
| **Imagen** | Una plantilla congelada. No se ejecuta. | La receta escrita |
| **Contenedor** | Una imagen puesta a funcionar. | El plato ya servido |

De una receta salen muchos platos. De una imagen, muchos contenedores.

---

## Antes de empezar

Necesitas:

- **Windows 10 u 11 de 64 bits**, con al menos 4 GB de RAM.
- **Conexión a internet** para la primera vez (se descargan unos 500 MB).
- **Esta carpeta** (`Contenedor PostgreSQL`) guardada en tu computadora.

---

## Paso 1 · Instalar Docker Desktop

1. Entra a <https://www.docker.com/products/docker-desktop> y descarga
   **Docker Desktop for Windows**.
2. Ejecuta el instalador. Deja marcada la casilla **«Use WSL 2»**.
3. **Reinicia la computadora** cuando termine. Sí, hace falta.
4. Abre Docker Desktop desde el menú Inicio.

Espera a que el icono de la ballena, abajo a la derecha en la barra de tareas,
**deje de moverse**. Mientras se mueve, Docker está arrancando y nada funciona
todavía. Puede tardar un minuto.

> ### ⚠️ Lo más importante de todo el tutorial
>
> **Docker Desktop tiene que estar abierto** cada vez que trabajes. Si lo
> cierras, ningún comando responde. Es, con diferencia, el tropiezo más común
> de la primera semana.
>
> Si un día nada funciona, lo primero que debes preguntarte es: *¿está abierto
> Docker Desktop?*

### En macOS o Linux

- **macOS**: descarga del mismo sitio, pero **fíjate bien**: hay una versión
  para Intel y otra para Apple Silicon (M1, M2, M3…) y no son intercambiables.
- **Linux**: no se usa Docker Desktop. Se instala `docker-ce` siguiendo la
  documentación oficial, y después se añade tu usuario al grupo `docker`.

---

## Paso 2 · Comprobar que Docker responde

Abre el **Símbolo del sistema**: tecla Windows, escribe `cmd`, Enter.

Escribe esto y presiona Enter:

```bash
docker --version
```

Debe responder algo parecido a:

```
Docker version 29.8.0, build 88096ef
```

Ahora el segundo:

```bash
docker compose version
```

```
Docker Compose version v2.41.0
```

**Los números no tienen que coincidir exactamente** con los de arriba. Lo que
importa es que responda algo y no un error.

> **Es `docker compose`, con espacio en medio.** Vas a encontrar por internet
> `docker-compose` con guion: ésa es la versión antigua, de cuando Compose era
> un programa aparte. Está descontinuada. Usa siempre el espacio.

### Si sale un error

| Lo que sale | Qué significa | Qué hacer |
|---|---|---|
| `'docker' no se reconoce como un comando` | No está instalado, o falta reiniciar | Reinicia. Si sigue, reinstala Docker Desktop |
| `Cannot connect to the Docker daemon` | Está instalado pero **no abierto** | Abre Docker Desktop y espera a la ballena |

---

## Paso 3 · Abrir la terminal en la carpeta correcta

**Éste es el paso donde más gente se atora.** Los comandos sólo funcionan si la
terminal está *parada* dentro de la carpeta del proyecto.

### La forma fácil

1. Abre el **Explorador de archivos** y entra a la carpeta
   `Contenedor PostgreSQL`. Debes ver dentro: `Dockerfile`, `compose.yaml`,
   `README.md`, y las carpetas `extras` e `initdb`.
2. Haz clic en la **barra de direcciones** de arriba, donde se ve la ruta.
   Se pondrá azul.
3. Borra lo que dice, escribe `cmd` y presiona **Enter**.

Se abre una ventana negra que **ya está** en la carpeta correcta. La última
línea termina con la ruta y un `>`:

```
C:\Users\gabri\Downloads\1151055 Administracion\Contenedor PostgreSQL>
```

### Comprueba que estás en el lugar correcto

```bash
dir
```

Tienen que aparecer `Dockerfile` y `compose.yaml`. **Si no aparecen, estás en
otra carpeta** y nada de lo que sigue va a funcionar. Vuelve a empezar el paso.

> **¿Por qué importa tanto?** Porque `docker compose` busca el archivo
> `compose.yaml` en la carpeta donde estás parado. Si no lo encuentra, no sabe
> qué levantar.

---

## Paso 4 · Prender el contenedor

Escribe:

```bash
docker compose up -d
```

**La primera vez tarda varios minutos.** Vas a ver muchísimas líneas pasando:
está descargando PostgreSQL y construyendo tu imagen. Es normal. No cierres la
ventana.

Cuando termina, las últimas líneas son éstas:

```
 ✔ Image postgres-1151055:26o   Built
 ✔ Network apsw-1151055-contenedor_default  Created
 ✔ Volume apsw-1151055-contenedor_datos_db  Created
 ✔ Container apsw_db            Started
 ✔ Container apsw_db            Healthy
 ✔ Container apsw_adminer       Started
```

La palabra que buscas es **`Healthy`**. Significa que la base de datos ya
acepta conexiones, no sólo que el contenedor existe.

Y te devuelve el `>` para escribir otro comando. Eso lo hace la `-d`.

> ### Si escribiste `docker compose up` sin la `-d`
>
> La terminal se queda mostrando texto y **parece colgada**. No lo está: la
> `-d` (de *detached*) es la que devuelve el control. Sin ella, la terminal se
> queda «enganchada» mostrando lo que el contenedor imprime.
>
> Para salir: presiona **Ctrl + C**, y vuelve a escribir `docker compose up -d`.

> **De aquí en adelante, prender tarda dos segundos.** La descarga y la
> construcción sólo pasan la primera vez.

---

## Paso 5 · Comprobar que está vivo

### Forma 1 · Desde la terminal

```bash
docker compose ps
```

```
NAME           IMAGE                  SERVICE   STATUS
apsw_adminer   adminer:5.5.1          adminer   Up 8 seconds
apsw_db        postgres-1151055:26o   db        Up 15 seconds (healthy)
```

Busca **`(healthy)`** en la línea de `apsw_db`.

### Forma 2 · En Docker Desktop

Abre Docker Desktop y ve al panel **Containers**, a la izquierda. Ahí están tus
dos contenedores con un punto verde. Es lo mismo que acabas de ver en la
terminal, pero con ratón.

### Forma 3 · En el navegador

Abre <http://localhost:8080>. Sale una página de inicio de sesión llamada
**Adminer**. Llena así:

| Campo | Qué escribir |
|---|---|
| Motor / System | `PostgreSQL` |
| Servidor / Server | `db` |
| Usuario / Username | `proyecto` |
| Contraseña / Password | `practica_local_26o` |
| Base de datos / Database | `proyecto` |

> **El servidor es `db`, no `localhost`.** Dentro de la red de Docker, los
> contenedores se buscan por su nombre de servicio. Para Adminer, `localhost`
> sería él mismo.

Si entras y ves las tablas `equipo` e `historia`, **ya funciona todo**.

---

## Paso 6 · Entrar al contenedor

Hasta ahora le has hablado a Docker *desde fuera*. Ahora vas a meterte dentro:

```bash
docker compose exec db bash
```

Fíjate en cómo **cambia el texto antes del cursor**:

```
Antes:    C:\Users\...\Contenedor PostgreSQL>

Después:  root@a1b2c3d4e5f6:/trabajo#
```

> ### ¿Dónde estoy? Aprende a leer el cursor
>
> Es la señal más importante que vas a usar todo el trimestre:
>
> | Si ves… | Estás en… | Aquí funcionan… |
> |---|---|---|
> | `C:\...\algo>` | **Tu Windows** | Los comandos `docker` |
> | `root@...:/trabajo#` | **Dentro del contenedor** | Los comandos de Linux y `psql` |
>
> **Los comandos de Docker se escriben FUERA.** Si escribes
> `docker compose stop` estando dentro, sale `bash: docker: command not found`.
> No hiciste nada mal: es la prueba de que el contenedor está aislado y no ve
> tu Windows.

Ya dentro, mira qué hay:

```bash
ls
```

```
Dockerfile  README.md  TUTORIAL.md  compose.yaml  extras  initdb
```

**Son los mismos archivos que ves en el Explorador de Windows.** Esa carpeta
está compartida entre tu computadora y el contenedor: lo que escribas de un
lado aparece del otro.

---

## Paso 7 · Pasar las nueve comprobaciones

Sigues dentro del contenedor. Escribe:

```bash
bash extras/comprobar.sh
```

Esto ejecuta un guion que revisa nueve cosas y te dice si el entorno quedó
bien. Debe terminar así:

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

**Ésta es la captura de pantalla que va en tu entrega.**

Si alguna línea dice `FALLA` en rojo, el propio guion te explica debajo qué
significa y qué hacer. Léelo antes de borrar nada.

> Verás también un `AVISO` de que usas la contraseña por defecto. Para esta
> práctica está bien. Cuando tu equipo monte su propio proyecto, ahí sí toca
> crear un archivo `.env` con una contraseña propia; el
> [README.md](README.md) explica cómo.

---

## Paso 8 · Hablar con la base de datos

Sigues dentro del contenedor. Abre el cliente de PostgreSQL:

```bash
psql -U proyecto -d proyecto
```

El cursor cambia otra vez, ahora a:

```
proyecto=#
```

Estás **dentro de la base de datos**. Tercer nivel: Windows → contenedor →
PostgreSQL.

Lista las tablas:

```bash
\dt
```

```
              List of tables
 Schema |     Name     | Type  |  Owner
--------+--------------+-------+----------
 public | comprobacion | table | proyecto
 public | equipo       | table | proyecto
 public | historia     | table | proyecto
(3 rows)
```

> `comprobacion` la creó el guion del paso 7; `equipo` e `historia` venían con
> el entorno. Si corriste el guion varias veces, esa tabla tiene más filas: es
> justo lo que demuestra que los datos no se pierden al apagar.

Ahora una consulta de verdad. **Ojo: ésta sí lleva punto y coma al final.**

```sql
SELECT nombre, rol FROM equipo ORDER BY id;
```

```
    nombre    |        rol
--------------+-------------------
 Integrante 1 | Líder de proyecto
 Integrante 2 | Desarrollo
 Integrante 3 | Calidad
(3 rows)
```

> ### Las dos clases de órdenes en `psql`
>
> | Tipo | Empieza con | ¿Punto y coma? | Ejemplo |
> |---|---|---|---|
> | Órdenes de `psql` | `\` | **No** | `\dt`, `\q` |
> | Consultas SQL | Una palabra | **Sí, siempre** | `SELECT * FROM equipo;` |
>
> Si olvidas el punto y coma, `psql` no hace nada y el cursor cambia a
> `proyecto-#`, esperando que termines. Escribe `;` y Enter.

Hay más consultas de ejemplo preparadas. Sal de `psql` primero:

```bash
\q
```

Y ejecútalas todas de golpe:

```bash
psql -U proyecto -d proyecto -f extras/ejemplos/consultas.sql
```

---

## Paso 9 · Salir y apagar

Son **dos cosas distintas** y en este orden.

Primero sal del contenedor:

```bash
exit
```

El cursor vuelve a ser el de Windows: `C:\...\Contenedor PostgreSQL>`. El
contenedor **sigue encendido**. Puedes volver a entrar con `exec` las veces
que quieras.

Ahora sí, apágalo:

```bash
docker compose stop
```

```
 ✔ Container apsw_adminer  Stopped
 ✔ Container apsw_db       Stopped
```

Listo. Mañana, `docker compose up -d` y sigues donde lo dejaste: **los datos
no se pierden**.

---

## Tarjeta de referencia

Imprímela o tenla a la mano. Con esto trabajas todo el trimestre.

### Los cuatro de siempre

| Comando | Qué hace | ¿Dónde? |
|---|---|---|
| `docker compose up -d` | Prender | Windows |
| `docker compose exec db bash` | Entrar | Windows |
| `bash extras/comprobar.sh` | Comprobar | Dentro |
| `docker compose stop` | Apagar | Windows |

### Para mirar qué pasa

| Comando | Qué hace |
|---|---|
| `docker compose ps` | ¿Está encendido? |
| `docker compose ps -a` | ¿Existe, aunque esté apagado? |
| `docker compose logs db` | ¿Qué dijo antes de morir? |

### Dentro del contenedor

| Comando | Qué hace |
|---|---|
| `psql -U proyecto -d proyecto` | Entrar a la base |
| `\dt` | Listar tablas (sin `;`) |
| `SELECT * FROM equipo;` | Consultar (con `;`) |
| `\q` | Salir de psql |
| `exit` | Salir del contenedor |

### Apagar, borrar, empezar de cero

| Comando | Qué le pasa al contenedor | ¿Y a los datos? |
|---|---|---|
| `docker compose stop` | Se **apaga** | Intactos |
| `docker compose start` | Se vuelve a prender | Intactos |
| `docker compose down` | Se apaga **y se borra** | Intactos |
| `docker compose down -v` | Se borra **y el volumen también** | **Se pierden** |

**Para el día a día usa `stop`.** Si el contenedor desaparece de Docker Desktop
después de un `down`, no hiciste nada mal: eso hace. `up -d` lo vuelve a crear
en dos segundos.

---

## Qué acabas de hacer

Ahora que ya funciona, vale la pena entender qué pasó. Cinco ideas:

**1 · El contenedor está aislado.** Dentro no existe tu Windows. Por eso
`docker` no funciona ahí dentro, y por eso da igual qué tengas instalado en tu
máquina: el entorno es el mismo para todo el equipo.

**2 · Los contenedores son desechables; los datos, no.** El contenedor se borra
y se vuelve a crear sin drama. Los datos viven aparte, en un **volumen** que
Docker administra. Por eso `down` no los toca y sólo `down -v` los borra.

**3 · Hay dos archivos y hacen cosas distintas.**

| | Qué es | Cuándo se usa |
|---|---|---|
| `Dockerfile` | El **plano**: qué lleva dentro la imagen | Una vez, al construir |
| `compose.yaml` | El **manual de arranque**: cómo se pone a correr | Cada día |

**4 · La versión se fija siempre.** En el `compose.yaml` dice `postgres:18.6`,
no `postgres:latest`. `latest` no significa «estable», significa «la última que
subieron». Fijar la versión es lo que hace que esto siga funcionando dentro de
un año, cuando alguien más clone tu repositorio. **Es requisito de entrega.**

**5 · Todo esto va al repositorio.** El `Dockerfile` y el `compose.yaml` son
parte de la entrega, no un accesorio: son lo que permite que otra persona
reconstruya tu trabajo.

---

## Si algo sale mal

**Antes de borrar nada, ejecuta estos dos, en este orden:**

```bash
docker compose ps -a
```

```bash
docker compose logs db
```

El primero dice si el contenedor está encendido, apagado o si nunca arrancó. El
segundo dice qué pasó. **El 90 % de los problemas se resuelve leyendo la última
línea de `logs`.**

| Lo que sale en pantalla | Casi siempre es | Qué hacer |
|---|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop no está abierto | Abrirlo y esperar a la ballena |
| `no configuration file provided` | La terminal está en otra carpeta | Repetir el paso 3 |
| `'docker' no se reconoce como un comando` | Falta instalar o reiniciar | Reiniciar la computadora |
| `bash: docker: command not found` | Escribiste un comando de Docker **dentro** | `exit` primero |
| `port is already allocated` | Otro programa usa el puerto 5434 | Ver abajo |
| La terminal se queda sin cursor | Usaste `up` sin `-d` | `Ctrl + C`, luego `up -d` |
| `service "db" is not running` | El contenedor está apagado | `docker compose up -d` |
| `password authentication failed` | La contraseña cambió después de crear la base | `down -v` y `up -d` |
| En `psql`, el cursor dice `proyecto-#` | Falta el punto y coma | Escribe `;` y Enter |

### Si el puerto está ocupado

Significa que ya tienes algo usando el 5434 (a veces, otro PostgreSQL
instalado). Crea un archivo `.env` en la carpeta:

```bash
copy .env.example .env
```

Ábrelo con el Bloc de notas y cambia el número:

```
POSTGRES_PORT=5435
```

Después `docker compose down` y `docker compose up -d`.

### Empezar de cero sin miedo

Si algo se enredó y quieres volver al principio:

```bash
docker compose down -v
```

```bash
docker compose up -d
```

Pierdes los datos de prueba, nada más. Los archivos de tu carpeta no se tocan,
y tarda segundos.

---

## Qué entregar

Esto es la **parte A** de la Práctica 1. En el repositorio de tu equipo:

- [ ] El `Dockerfile` y el `compose.yaml` versionados.
- [ ] Captura de pantalla de `docker compose ps` con el `(healthy)`.
- [ ] Captura de las **9 de 9 comprobaciones** del paso 7.
- [ ] En el `README.md` del equipo, el comando exacto con el que levanta el
      sistema.
- [ ] Comprobado en **al menos dos computadoras distintas** del equipo.

Recuerda la **puerta de calidad**: un entregable sólo cuenta si hay un Pull
Request ligado a un issue, la integración continua pasa en verde, lo aprobó
alguien distinto del autor, y el sistema levanta con el comando documentado en
el README.

> **Sigue la parte B: el repositorio del equipo en GitHub.** Sin ella la
> Práctica 1 está a la mitad.

---

## Las cinco reglas que no se negocian

1. **Nunca `latest`.** Fija siempre la versión.
2. **Lee el error antes de borrar nada.** `ps -a`, después `logs`.
3. **Lo que no se puede perder va en un volumen.** El contenedor es desechable.
4. **`stop` apaga; `down` borra el contenedor.** Sólo `down -v` toca los datos.
5. **El `Dockerfile` y el `compose.yaml` van en el repositorio.** Son parte del
   trabajo.

---

*Material del curso · M. en C. Gabriel Hurtado Avilés · Trimestre 26-O*
