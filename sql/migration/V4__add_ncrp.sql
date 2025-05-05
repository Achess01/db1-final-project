CREATE TABLE necropcy (
                necropcy_id BIGINT NOT NULL,
                necropcy_date DATE NOT NULL,
                territory_id INTEGER,
                tp_causa_id INTEGER NOT NULL,
                person_id BIGINT NOT NULL,
                CONSTRAINT necropcy_pk PRIMARY KEY (necropcy_id)
);

ALTER TABLE necropcy ADD CONSTRAINT territory_necropcy_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE necropcy ADD CONSTRAINT typology_necropcy_fk
FOREIGN KEY (tp_causa_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE necropcy ADD CONSTRAINT person_necropcy_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- Insert necropcy data
CREATE TEMP TABLE necropsia_raw (
    num_corre VARCHAR(10),
    año_ing VARCHAR(10),
    mes_ing VARCHAR(20),
    día_ing VARCHAR(10),
    día_sem_ing VARCHAR(20),
    depto_ocu VARCHAR(50),
    mupio_ocu VARCHAR(50),
    edad_per VARCHAR(10),
    g_edad_60ymás VARCHAR(20),
    g_edad_80ymás VARCHAR(20),
    edad_quinquenales VARCHAR(20),
    menor_mayor VARCHAR(20),
    sexo_per VARCHAR(10),
    causa_muerte VARCHAR(100)
);

COPY necropsia_raw FROM '/data/necropsias.csv' WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);


-- Insert parent area
INSERT INTO typology (value, parent_id) VALUES ('CAUSAS_MUERTE', NULL);

INSERT INTO typology (value, parent_id)
SELECT DISTINCT causa_muerte, t.typology_id
FROM necropsia_raw nr
JOIN typology t ON t.value = 'CAUSAS_MUERTE' AND t.parent_id IS NULL
WHERE causa_muerte IS NOT NULL;

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
    CONCAT('Necropsia ', csv.num_corre)
FROM necropsia_raw csv
JOIN typology tp_parent ON tp_parent.value = 'GENDER' AND tp_parent.parent_id IS NULL
LEFT JOIN typology tp_gender
    ON tp_gender.parent_id = tp_parent.typology_id AND TRIM(tp_gender.value) = TRIM(csv.sexo_per);


INSERT INTO necropcy (
    necropcy_id,
    necropcy_date,
    territory_id,
    tp_causa_id,
    person_id
)
SELECT
    num_corre::INT,
    TO_DATE(
        CONCAT(
            año_ing, '-',
            LPAD((
                CASE mes_ing
                    WHEN 'Enero' THEN '1' WHEN 'Febrero' THEN '2'
                    WHEN 'Marzo' THEN '3' WHEN 'Abril' THEN '4'
                    WHEN 'Mayo' THEN '5' WHEN 'Junio' THEN '6'
                    WHEN 'Julio' THEN '7' WHEN 'Agosto' THEN '8'
                    WHEN 'Septiembre' THEN '9' WHEN 'Octubre' THEN '10'
                    WHEN 'Noviembre' THEN '11' WHEN 'Diciembre' THEN '12'
                END
            ), 2, '0'),
            '-', LPAD(día_ing, 2, '0')
        ),
        'YYYY-MM-DD'
    ),
    t.territory_id,
    tp_causa.typology_id,
    p.person_id
FROM necropsia_raw csv
JOIN typology tp_causas_parent ON tp_causas_parent.value = 'CAUSAS_MUERTE' AND tp_causas_parent.parent_id IS NULL
JOIN person p
    ON p.last_name = CONCAT('Necropsia ', csv.num_corre)
LEFT JOIN typology tp_causa
    ON tp_causa.parent_id = tp_causas_parent.typology_id AND TRIM(tp_causa.value) = TRIM(csv.causa_muerte)
LEFT JOIN territory t ON
    TRIM(t.name) = TRIM(csv.mupio_ocu) AND
    t.parent_id = (
        SELECT d.territory_id
        FROM territory d
        WHERE TRIM(d.name) = TRIM(csv.depto_ocu) AND d.parent_id IS NULL
        LIMIT 1
    )
WHERE
    día_ing ~ '^[0-9]+$';
