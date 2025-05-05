CREATE TEMP TABLE tmp_pregnancy_import (
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    pregnancy_year INTEGER,
    age_at_pregnancy SMALLINT,
    result VARCHAR(100),
    sex_per VARCHAR(100),
    territory_id INTEGER
);

COPY tmp_pregnancy_import
FROM '/data/pregnancy.csv'
WITH (
    FORMAT CSV,
    HEADER,
    DELIMITER ','
);

INSERT INTO pregnancy_result (description)
SELECT DISTINCT result
FROM tmp_pregnancy_import
WHERE result IS NOT NULL;

INSERT INTO person (first_name, last_name, age, date_of_death, tp_gender_id)
SELECT
    tpi.first_name,
    CONCAT('Embarazo ', tpi.last_name),
    NULL,
    NULL,
    ty.typology_id
FROM tmp_pregnancy_import tpi
JOIN typology ty ON ty.value = tpi.sex_per;

INSERT INTO pregnancy (pregnancy_year, age_at_pregnancy, person_id, pregnancy_result_id, territory_id)
SELECT
    tpi.pregnancy_year,
    tpi.age_at_pregnancy,
    p.person_id,
    pr.pregnancy_result_id,
    tpi.territory_id
FROM tmp_pregnancy_import tpi
JOIN person p
    ON p.first_name = tpi.first_name AND p.last_name = CONCAT('Embarazo ', tpi.last_name)
JOIN pregnancy_result pr
    ON pr.description = tpi.result;
