-- Cantidad de homicidios registrados por año y departamento
SELECT
    EXTRACT(YEAR FROM o.offense_date) AS year,
    d.name AS department,
    COUNT(*) AS total_homicides
FROM offense o
JOIN territory m ON o.territory_id = m.territory_id
JOIN territory d ON m.parent_id = d.territory_id
WHERE o.tp_crime_id IN (10, 17, 53, 55)
GROUP BY year, department
ORDER BY year, department;

-- Violencia contra la mujer
SELECT
    t.name AS municipality,
    COUNT(*) AS total_reports
FROM offended o
JOIN person p ON o.person_id = p.person_id
JOIN offense f ON o.offense_id = f.offense_id
JOIN territory t ON f.territory_id = t.territory_id
WHERE p.tp_gender_id = 5
GROUP BY municipality
ORDER BY total_reports DESC;


-- Top 5 tipos de hechos delictivos más frecuentes en los últimos 5 años
SELECT t.value AS tipo_delito, COUNT(*) AS cantidad
FROM offense o
JOIN typology t ON o.tp_crime_id = t.typology_id
WHERE o.offense_date >= NOW() - INTERVAL '5 years'
GROUP BY t.value
ORDER BY cantidad DESC
LIMIT 5;

--Sentencias dictadas por tipo de delito y año
SELECT t.value AS tipo_delito, EXTRACT(YEAR FROM j.judgement_date) AS año, COUNT(*) AS cantidad
FROM judgment j
JOIN offense o ON j.offense_id = o.offense_id
JOIN typology t ON o.tp_crime_id = t.typology_id
GROUP BY t.value, año
ORDER BY año, cantidad DESC;

-- Distribución de embarazos adolescentes (menores de 19 años) por región
SELECT t.name AS region, COUNT(*) AS cantidad
FROM pregnancy p
JOIN territory t ON p.territory_id = t.territory_id
WHERE p.age_at_pregnancy < 19
GROUP BY t.name;

-- Número de necropsias realizadas por año
SELECT EXTRACT(YEAR FROM necropcy_date) AS año, COUNT(*) AS cantidad
FROM necropcy
GROUP BY año
ORDER BY año;

-- Casos de violencia contra la mujer con sentencia firme
SELECT COUNT(*) AS total_sentencias_firmes
FROM offended o
JOIN person p ON o.person_id = p.person_id
JOIN offense f ON o.offense_id = f.offense_id
JOIN judgment j ON j.offense_id = f.offense_id
WHERE p.tp_gender_id = 5 AND j.tp_rule_id = 104;

-- Relación entre edad y tipo de violencia sufrida
SELECT age, COUNT(*) AS total
FROM person p
JOIN offense o ON p.person_id = o.person_id
GROUP BY age
ORDER BY total DESC
LIMIT 1;

-- Comparativa de violencia estructural entre áreas urbanas y rurales
SELECT
    tp_area_id,
    COUNT(*) AS total_cases
FROM offense
WHERE tp_area_id IN (2, 3)
GROUP BY tp_area_id;

-- Exhumaciones
SELECT
    o.tp_crime_id,
    COUNT(*) AS total_exhumations
FROM exhumation e
JOIN offense o ON e.offense_id = o.offense_id
GROUP BY o.tp_crime_id
ORDER BY total_exhumations DESC;
