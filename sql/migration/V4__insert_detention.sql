USE [violencia-db]
GO

CREATE TABLE #violencia_raw (
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

BULK INSERT #violencia_raw
FROM '/data/detenciones.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FORMAT = 'CSV'
);

INSERT INTO typology (value, parent_id)
VALUES ('AREA_GEO', NULL); -- 1

DECLARE @area_parent_id INT = SCOPE_IDENTITY();

INSERT INTO typology (value, parent_id)
SELECT DISTINCT area_geo_ocu, @area_parent_id
FROM #violencia_raw
WHERE area_geo_ocu IS NOT NULL AND area_geo_ocu <> 'Ignorada'
AND NOT EXISTS (
    SELECT 1 FROM typology t WHERE t.value = area_geo_ocu AND t.parent_id = @area_parent_id
);

INSERT INTO typology (value, parent_id)
VALUES ('GENDER', NULL);

DECLARE @gender_parent_id INT = SCOPE_IDENTITY(); -- 4

INSERT INTO typology (value, parent_id)
SELECT DISTINCT sexo_per, @gender_parent_id
FROM #violencia_raw
WHERE sexo_per IS NOT NULL AND sexo_per <> 'Ignorada'
AND NOT EXISTS (
    SELECT 1 FROM typology t WHERE t.value = sexo_per AND t.parent_id = @gender_parent_id
);

INSERT INTO detention (
    detention_id,
    detention_date,
    tp_area_id,
    zone,
    tp_gender_id,
    territory_id
)
SELECT
    CAST(csv.num_corre AS INT) AS detention_id,
    TRY_CAST(
        CONCAT(
            csv.año_ocu, '-',
            RIGHT('0' + CAST(
                CASE csv.mes_ocu
                    WHEN 'Enero' THEN 1 WHEN 'Febrero' THEN 2
                    WHEN 'Marzo' THEN 3 WHEN 'Abril' THEN 4
                    WHEN 'Mayo' THEN 5 WHEN 'Junio' THEN 6
                    WHEN 'Julio' THEN 7 WHEN 'Agosto' THEN 8
                    WHEN 'Septiembre' THEN 9 WHEN 'Octubre' THEN 10
                    WHEN 'Noviembre' THEN 11 WHEN 'Diciembre' THEN 12
                END AS VARCHAR), 2), '-',
            RIGHT('0' + csv.día_ocu, 2), ' ',
            RIGHT('0' + csv.hora_ocu, 2), ':00:00'
        ) AS DATETIME
    ) AS detention_date,
    tp_area.typology_id,
    TRY_CAST(csv.zona_ocu AS INT) AS zone,
    tp_gender.typology_id,
    t.territory_id

FROM #violencia_raw csv
LEFT JOIN typology tp_area
    ON (tp_area.parent_id = 1 AND TRIM(tp_area.value) = TRIM(csv.area_geo_ocu))
LEFT JOIN typology tp_gender
    ON (tp_gender.parent_id = 4 AND TRIM(tp_gender.value) = TRIM(csv.sexo_per))
LEFT JOIN territory t ON
    t.name = csv.mupio_ocu
    AND t.parent_id = (SELECT d.territory_id FROM territory d WHERE d.name = csv.depto_ocu AND d.parent_id IS NULL)
WHERE
    TRY_CAST(csv.día_ocu AS INT) IS NOT NULL
    AND TRY_CAST(csv.hora_ocu AS INT) IS NOT NULL;
