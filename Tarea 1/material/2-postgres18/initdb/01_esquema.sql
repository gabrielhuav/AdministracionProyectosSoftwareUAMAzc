-- ---------------------------------------------------------------------------
-- Esquema de prueba · UEA 1151055 · Administración de Proyectos de Software
--
-- Este archivo lo ejecuta la imagen de PostgreSQL UNA sola vez: la primera
-- vez que arranca con el volumen vacío. Si ya hay datos, se ignora.
--
-- Para volver a ejecutarlo hay que borrar el volumen:
--     docker compose down -v && docker compose up -d
-- ---------------------------------------------------------------------------

CREATE TABLE equipo (
    id          smallserial PRIMARY KEY,
    nombre      text        NOT NULL,
    matricula   char(10)    NOT NULL UNIQUE,
    rol         text        NOT NULL
);

CREATE TABLE historia (
    id          serial      PRIMARY KEY,
    titulo      text        NOT NULL,
    puntos      smallint    NOT NULL CHECK (puntos IN (1, 2, 3, 5, 8, 13)),
    estado      text        NOT NULL DEFAULT 'pendiente'
                            CHECK (estado IN ('pendiente', 'en curso', 'terminada')),
    responsable smallint    REFERENCES equipo (id),
    creada      timestamptz NOT NULL DEFAULT now()
);

INSERT INTO equipo (nombre, matricula, rol) VALUES
    ('Integrante 1', '2212345678', 'Líder de proyecto'),
    ('Integrante 2', '2212345679', 'Desarrollo'),
    ('Integrante 3', '2212345680', 'Calidad');

INSERT INTO historia (titulo, puntos, estado, responsable) VALUES
    ('Levantar el entorno con Docker Compose',        3, 'terminada', 1),
    ('Configurar la protección de la rama principal', 2, 'en curso',  3),
    ('Redactar el acta de constitución',              5, 'pendiente', 1);

-- Comprobación visible en los logs del contenedor al arrancar.
DO $$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n FROM historia;
    RAISE NOTICE 'Esquema de prueba creado: % historias cargadas.', n;
END $$;
