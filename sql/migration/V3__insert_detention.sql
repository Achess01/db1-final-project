CREATE TEMP TABLE violencia_raw (
    num_corre VARCHAR(10),
    año_ocu VARCHAR(10),
    mes_ocu VARCHAR(20),
    día_ocu VARCHAR(10),
    día_sem_ocu VARCHAR(20),
    hora_ocu VARCHAR(10),
    g_hora VARCHAR(30),
    g_hora_mañ_tar_noch VARCHAR(30),
    area_geo_ocu VARCHAR(20),
    depto_ocu VARCHAR(50),
    mupio_ocu VARCHAR(50),
    zona_ocu VARCHAR(10),
    sexo_per VARCHAR(10),
    edad_per VARCHAR(10),
    g_edad_60ymás VARCHAR(20),
    g_edad_80ymás VARCHAR(20),
    edad_quinquenales VARCHAR(20),
    delito_com VARCHAR(100),
    g_delitos VARCHAR(100)
);


COPY violencia_raw FROM '/data/detenciones.csv' WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);


-- Insert parent area
INSERT INTO typology (value, parent_id) VALUES ('AREA_GEO', NULL);

-- Insert distinct areas
INSERT INTO typology (value, parent_id)
SELECT DISTINCT area_geo_ocu, 1
FROM violencia_raw
WHERE area_geo_ocu IS NOT NULL AND area_geo_ocu <> 'Ignorada'
  AND NOT EXISTS (
    SELECT 1 FROM typology t WHERE t.value = area_geo_ocu AND t.parent_id = 1
);

-- Insert parent genero
INSERT INTO typology (value, parent_id) VALUES ('GENDER', NULL);

INSERT INTO typology (value, parent_id)
SELECT DISTINCT sexo_per, 4
FROM violencia_raw
WHERE sexo_per IS NOT NULL AND sexo_per <> 'Ignorada'
  AND NOT EXISTS (
    SELECT 1 FROM typology t WHERE t.value = sexo_per AND t.parent_id = 4
);

-- Insert parent crime
INSERT INTO typology (value, parent_id) VALUES ('CRIME', NULL); -- 7

INSERT INTO typology (value, parent_id)
SELECT DISTINCT delito_com, 7
FROM violencia_raw
WHERE delito_com IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM typology t WHERE t.value = delito_com AND t.parent_id = 7
);

-- Insert persons
INSERT INTO person (
    date_of_death,
    tp_gender_id,
    age,
    first_name,
    last_name
)
SELECT
    null,
    tp_gender.typology_id,
    CASE
        WHEN csv.edad_per ~ '^\d+$' THEN csv.edad_per::INT
        ELSE NULL
    END AS age,
    'Persona',
    CONCAT('Detenida ', csv.num_corre)
FROM violencia_raw csv
LEFT JOIN typology tp_gender
    ON tp_gender.parent_id = 4 AND TRIM(tp_gender.value) = TRIM(csv.sexo_per);


INSERT INTO detention (
    detention_id,
    detention_date,
    tp_area_id,
    zone,
    territory_id,
    tp_crime_id,
    person_id
)
SELECT
    num_corre::INT,
    TO_TIMESTAMP(
        CONCAT(
            año_ocu, '-',
            LPAD((
                CASE mes_ocu
                    WHEN 'Enero' THEN '1' WHEN 'Febrero' THEN '2'
                    WHEN 'Marzo' THEN '3' WHEN 'Abril' THEN '4'
                    WHEN 'Mayo' THEN '5' WHEN 'Junio' THEN '6'
                    WHEN 'Julio' THEN '7' WHEN 'Agosto' THEN '8'
                    WHEN 'Septiembre' THEN '9' WHEN 'Octubre' THEN '10'
                    WHEN 'Noviembre' THEN '11' WHEN 'Diciembre' THEN '12'
                END
            ), 2, '0'),
            '-', LPAD(día_ocu, 2, '0'),
            ' ', LPAD(hora_ocu, 2, '0'), ':00:00'
        ), 'YYYY-MM-DD HH24:MI:SS'
    ),
    tp_area.typology_id,
    CASE
        WHEN csv.zona_ocu ~ '^\d+$' THEN csv.zona_ocu::INT
        ELSE NULL
    END AS zone,
    t.territory_id,
    tp_crime.typology_id,
    p.person_id
FROM violencia_raw csv
JOIN person p
    ON p.last_name = CONCAT('Detenida ', csv.num_corre)
LEFT JOIN typology tp_area
    ON tp_area.parent_id = 1 AND TRIM(tp_area.value) = TRIM(csv.area_geo_ocu)
LEFT JOIN territory t ON
    TRIM(t.name) = TRIM(csv.mupio_ocu) AND
    t.parent_id = (
        SELECT d.territory_id
        FROM territory d
        WHERE TRIM(d.name) = TRIM(csv.depto_ocu) AND d.parent_id IS NULL
        LIMIT 1
    )
LEFT JOIN typology tp_crime
    ON tp_crime.parent_id = 7 AND TRIM(tp_crime.value) = TRIM(csv.delito_com)
WHERE
    día_ocu ~ '^[0-9]+$' AND hora_ocu ~ '^[0-9]+$';
