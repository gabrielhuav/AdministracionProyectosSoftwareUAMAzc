-- ---------------------------------------------------------------------------
-- Consultas de ejemplo · UEA 1151055
--
-- Se ejecutan DENTRO del contenedor, de dos maneras:
--
--   a) Todas de golpe:
--        psql -U proyecto -d proyecto -f extras/ejemplos/consultas.sql
--
--   b) Copiando y pegando dentro de psql:
--        psql -U proyecto -d proyecto
--        proyecto=# SELECT * FROM equipo;
--        proyecto=# \q
--
-- Ordenes utiles de psql (empiezan con barra invertida, no llevan ;):
--   \dt        listar tablas          \d historia   describir una tabla
--   \l         listar bases           \du           listar usuarios
--   \x         salida vertical        \q            salir
-- ---------------------------------------------------------------------------

\echo '--- 1. Todo el equipo -------------------------------------------------'
SELECT * FROM equipo ORDER BY id;

\echo '--- 2. Historias con su responsable (JOIN) ----------------------------'
SELECT h.id,
       h.titulo,
       h.puntos,
       h.estado,
       e.nombre AS responsable
  FROM historia h
  JOIN equipo   e ON e.id = h.responsable
 ORDER BY h.id;

\echo '--- 3. Puntos por estado (agregacion) ---------------------------------'
SELECT estado,
       count(*)   AS historias,
       sum(puntos) AS puntos
  FROM historia
 GROUP BY estado
 ORDER BY puntos DESC;

\echo '--- 4. Carga de trabajo por persona -----------------------------------'
SELECT e.nombre,
       count(h.id)              AS historias,
       coalesce(sum(h.puntos), 0) AS puntos
  FROM equipo e
  LEFT JOIN historia h ON h.responsable = e.id
 GROUP BY e.nombre
 ORDER BY puntos DESC;

\echo '--- 5. Avance del proyecto (porcentaje terminado) ---------------------'
SELECT round(
           100.0 * sum(puntos) FILTER (WHERE estado = 'terminada')
                 / nullif(sum(puntos), 0)
       , 1) AS porcentaje_terminado
  FROM historia;

\echo '--- 6. Insertar una historia nueva ------------------------------------'
-- Quita los dos guiones del principio para que se ejecute:
-- INSERT INTO historia (titulo, puntos, estado, responsable)
--      VALUES ('Mi primera historia', 3, 'pendiente', 2);

\echo '--- 7. Que version y donde guarda los datos ---------------------------'
SELECT current_setting('server_version') AS version,
       current_setting('data_directory') AS pgdata;
