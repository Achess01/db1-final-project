CREATE TEMP TABLE tmp_exhumation_raw (
    núm_corre TEXT,
    año_ocu TEXT,
    mes_ocu TEXT,
    día_ocu TEXT,
    dia_sem_ocu TEXT,
    depto_ocu TEXT
);

COPY tmp_exhumation_raw FROM '/data/exhumaciones.csv' WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);


INSERT INTO exhumation (
    exhumation_id,
    exhumation_date,
    territory_id,
    detention_id
)
SELECT
    núm_corre::BIGINT AS exhumation_id,
    TO_DATE(
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
            '-', LPAD(día_ocu, 2, '0')
        ), 'YYYY-MM-DD'
    ) AS exhumation_date,
    t.territory_id,
    d.detention_id
FROM tmp_exhumation_raw r
LEFT JOIN territory t ON TRIM(t.name) = TRIM(r.depto_ocu) AND t.parent_id IS NULL
LEFT JOIN detention d ON d.detention_id = r.núm_corre::BIGINT;
