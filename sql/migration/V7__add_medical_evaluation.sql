CREATE TEMP TABLE tmp_medical_raw (
    núm_corre TEXT,
    año_ocu TEXT,
    mes_ocu TEXT,
    día_ocu TEXT,
    dia_sem_ocu TEXT,
    depto_ocu TEXT,
    edad_per TEXT,
    g_edad_60ymás TEXT,
    g_edad_80ymás TEXT,
    edad_quinquenales TEXT,
    menor_mayor TEXT,
    sexo_per TEXT,
    clasif_eval TEXT
);

COPY tmp_medical_raw
FROM '/data/medical_evaluation.csv'
WITH (
    FORMAT CSV,
    HEADER,
    DELIMITER ','
);

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
    CONCAT('Ofendida ', csv.núm_corre)
FROM tmp_medical_raw csv
JOIN typology tp_parent ON tp_parent.value = 'GENDER' AND tp_parent.parent_id IS NULL
LEFT JOIN typology tp_gender
    ON tp_gender.parent_id = tp_parent.typology_id AND TRIM(tp_gender.value) = TRIM(csv.sexo_per);


INSERT INTO offended (person_id, offense_id)
SELECT
    p.person_id,
    (SELECT offense_id FROM offense ORDER BY random() LIMIT 1)
FROM tmp_medical_raw tmp
JOIN person p ON p.last_name = CONCAT('Ofendida ', tmp.núm_corre);

INSERT INTO diagnosis (description)
SELECT DISTINCT TRIM(clasif_eval)
FROM tmp_medical_raw tmp
WHERE NOT EXISTS (
    SELECT 1 FROM diagnosis d WHERE d.description = TRIM(tmp.clasif_eval)
);

INSERT INTO medical_evaluation (
    medical_evaluation_id,
    medical_check_date,
    territory_id,
    diagnosis_id,
    offended_id
)
SELECT
    tmp.núm_corre::BIGINT,
    TO_DATE(
        CONCAT(
            tmp.año_ocu, '-',
            LPAD(CASE tmp.mes_ocu
                WHEN 'Enero' THEN '1' WHEN 'Febrero' THEN '2'
                WHEN 'Marzo' THEN '3' WHEN 'Abril' THEN '4'
                WHEN 'Mayo' THEN '5' WHEN 'Junio' THEN '6'
                WHEN 'Julio' THEN '7' WHEN 'Agosto' THEN '8'
                WHEN 'Septiembre' THEN '9' WHEN 'Octubre' THEN '10'
                WHEN 'Noviembre' THEN '11' WHEN 'Diciembre' THEN '12'
            END, 2, '0'),
            '-', LPAD(tmp.día_ocu, 2, '0')
        ), 'YYYY-MM-DD'
    ),
    t.territory_id,
    d.diagnosis_id,
    o.offended_id
FROM tmp_medical_raw tmp
JOIN territory t ON TRIM(t.name) = TRIM(tmp.depto_ocu) AND t.parent_id IS NULL
JOIN person p ON p.last_name = CONCAT('Ofendida ', tmp.núm_corre)
JOIN offended o ON o.person_id = p.person_id
JOIN diagnosis d ON d.description = TRIM(tmp.clasif_eval);
