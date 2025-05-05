CREATE TEMP TABLE tmp_judgment_raw (
    núm_corre TEXT,
    año_reg TEXT,
    mes_reg TEXT,
    men_may TEXT,
    sexo TEXT,
    nacionalidad TEXT,
    Involucramiento TEXT,
    tip_fallo TEXT,
    depto_reg TEXT,
    delito_cod TEXT,
    tip_ley TEXT,
    título TEXT,
    capítulo TEXT
);

COPY tmp_judgment_raw FROM '/data/judgments.csv' WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

-- Involucramiento
INSERT INTO typology (value, parent_id) VALUES ('INVOLUCRAMIENTO', NULL);

INSERT INTO typology (value, parent_id)
SELECT DISTINCT TRIM(Involucramiento), tparent.typology_id
FROM tmp_judgment_raw r
JOIN typology tparent ON tparent.value = 'INVOLUCRAMIENTO' AND tparent.parent_id IS NULL
WHERE TRIM(Involucramiento) IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM typology t
    WHERE t.value = TRIM(r.Involucramiento) AND t.parent_id = tparent.typology_id
);

-- Tipo de fallo
INSERT INTO typology (value, parent_id) VALUES ('TIPO_FALLO', NULL);

INSERT INTO typology (value, parent_id)
SELECT DISTINCT TRIM(tip_fallo), tparent.typology_id
FROM tmp_judgment_raw r
JOIN typology tparent ON tparent.value = 'TIPO_FALLO' AND tparent.parent_id IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM typology t
    WHERE t.value = TRIM(r.tip_fallo) AND t.parent_id = tparent.typology_id
);


-- Tipo de ley
INSERT INTO law (name, description)
SELECT DISTINCT TRIM(tip_ley), TRIM(título)
FROM tmp_judgment_raw r
WHERE NOT EXISTS (
    SELECT 1 FROM law l
    WHERE l.name = TRIM(r.tip_ley) AND l.description = TRIM(r.título)
);


-- Sentencias
INSERT INTO judgment (
    judgment_id,
    judgement_date,
    tp_involment_id,
    tp_rule_id,
    territory_id,
    law_id,
    offense_id
)
SELECT
    r.núm_corre::BIGINT AS judgment_id,
    TO_DATE(
        CONCAT(
            r.año_reg, '-',
            LPAD((
                CASE r.mes_reg
                    WHEN 'Enero' THEN '1' WHEN 'Febrero' THEN '2'
                    WHEN 'Marzo' THEN '3' WHEN 'Abril' THEN '4'
                    WHEN 'Mayo' THEN '5' WHEN 'Junio' THEN '6'
                    WHEN 'Julio' THEN '7' WHEN 'Agosto' THEN '8'
                    WHEN 'Septiembre' THEN '9' WHEN 'Octubre' THEN '10'
                    WHEN 'Noviembre' THEN '11' WHEN 'Diciembre' THEN '12'
                END
            ), 2, '0'), '-01'
        ), 'YYYY-MM-DD'
    ) AS judgement_date,
    ti.typology_id AS tp_involment_id,
    tf.typology_id AS tp_rule_id,
    t.territory_id,
    l.law_id,
    (SELECT offense_id FROM offense ORDER BY random() LIMIT 1) AS offense_id
FROM tmp_judgment_raw r
JOIN typology tparent ON tparent.value = 'INVOLUCRAMIENTO' AND tparent.parent_id IS NULL
JOIN typology tparentf ON tparentf.value = 'TIPO_FALLO' AND tparentf.parent_id IS NULL
JOIN typology ti ON TRIM(ti.value) = TRIM(r.Involucramiento) AND ti.parent_id = tparent.typology_id
JOIN typology tf ON TRIM(tf.value) = TRIM(r.tip_fallo) AND tf.parent_id = tparentf.typology_id
JOIN territory t ON TRIM(t.name) = TRIM(r.depto_reg) AND t.parent_id IS NULL
JOIN law l ON TRIM(l.name) = TRIM(r.tip_ley) AND TRIM(l.description) = TRIM(r.título);
