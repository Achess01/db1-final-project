CREATE TABLE pregnancy_result (
                pregnancy_result_id SERIAL,
                description VARCHAR(100) NOT NULL,
                CONSTRAINT pregnancy_result_pk PRIMARY KEY (pregnancy_result_id)
);

CREATE TABLE diagnosis (
                diagnosis_id SERIAL,
                description VARCHAR(100) NOT NULL,
                CONSTRAINT diagnosis_pk PRIMARY KEY (diagnosis_id)
);

CREATE TABLE law (
                law_id SERIAL,
                name VARCHAR(100) NOT NULL,
                description VARCHAR(150) NOT NULL,
                CONSTRAINT law_pk PRIMARY KEY (law_id)
);

CREATE TABLE territory (
                territory_id INTEGER NOT NULL,
                name VARCHAR(40) NOT NULL,
                parent_id INTEGER,
                population BIGINT NOT NULL,
                CONSTRAINT territory_pk PRIMARY KEY (territory_id)
);

CREATE TABLE typology (
                typology_id SERIAL,
                value VARCHAR(100) NOT NULL,
                parent_id INTEGER,
                CONSTRAINT typology_pk PRIMARY KEY (typology_id)
);

CREATE TABLE person (
                person_id SERIAL,
                date_of_death TIMESTAMP,
                tp_gender_id INTEGER,
                age INTEGER,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                CONSTRAINT person_pk PRIMARY KEY (person_id)
);

CREATE TABLE pregnancy (
                pregnancy_id SERIAL,
                pregnancy_year INTEGER NOT NULL,
                age_at_pregnancy SMALLINT NOT NULL,
                person_id BIGINT NOT NULL,
                pregnancy_result_id BIGINT NOT NULL,
                territory_id INTEGER NOT NULL,
                CONSTRAINT pregnancy_pk PRIMARY KEY (pregnancy_id)
);


CREATE TABLE necropcy (
                necropcy_id BIGINT NOT NULL,
                necropcy_date DATE NOT NULL,
                territory_id INTEGER,
                tp_causa_id INTEGER NOT NULL,
                person_id BIGINT NOT NULL,
                CONSTRAINT necropcy_pk PRIMARY KEY (necropcy_id)
);

CREATE TABLE offense (
                offense_id BIGINT NOT NULL,
                offense_date TIMESTAMP NOT NULL,
                tp_area_id INTEGER,
                zone INTEGER,
                territory_id INTEGER,
                tp_crime_id INTEGER NOT NULL,
                person_id BIGINT NOT NULL,
                CONSTRAINT offense_pk PRIMARY KEY (offense_id)
);

CREATE TABLE offended (
                offended_id SERIAL,
                person_id BIGINT NOT NULL,
                offense_id BIGINT NOT NULL,
                CONSTRAINT offended_pk PRIMARY KEY (offended_id)
);

CREATE TABLE medical_evaluation (
                medical_evaluation_id BIGINT NOT NULL,
                medical_check_date VARCHAR NOT NULL,
                territory_id INTEGER NOT NULL,
                diagnosis_id BIGINT NOT NULL,
                offended_id BIGINT NOT NULL,
                CONSTRAINT medical_evaluation_pk PRIMARY KEY (medical_evaluation_id)
);

CREATE TABLE judgment (
                judgment_id BIGINT NOT NULL,
                judgement_date DATE NOT NULL,
                tp_involment_id INTEGER NOT NULL,
                tp_rule_id INTEGER NOT NULL,
                territory_id INTEGER NOT NULL,
                law_id BIGINT NOT NULL,
                offense_id BIGINT NOT NULL,
                CONSTRAINT judgment_pk PRIMARY KEY (judgment_id)
);

CREATE TABLE exhumation (
                exhumation_id BIGINT NOT NULL,
                exhumation_date DATE NOT NULL,
                territory_id INTEGER NOT NULL,
                offense_id BIGINT NOT NULL,
                CONSTRAINT exhumation_pk PRIMARY KEY (exhumation_id)
);

ALTER TABLE pregnancy ADD CONSTRAINT pregnancy_result_pregnancy_fk
FOREIGN KEY (pregnancy_result_id)
REFERENCES pregnancy_result (pregnancy_result_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE medical_evaluation ADD CONSTRAINT diagnosis_medical_evaluation_fk
FOREIGN KEY (diagnosis_id)
REFERENCES diagnosis (diagnosis_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE judgment ADD CONSTRAINT law_judgment_fk
FOREIGN KEY (law_id)
REFERENCES law (law_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE territory ADD CONSTRAINT territory_territory_fk
FOREIGN KEY (parent_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offense ADD CONSTRAINT territory_detention_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE necropcy ADD CONSTRAINT territory_necropcy_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE exhumation ADD CONSTRAINT territory_exhumation_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE judgment ADD CONSTRAINT territory_judgment_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE medical_evaluation ADD CONSTRAINT territory_medical_check_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pregnancy ADD CONSTRAINT territory_pregnancy_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE typology ADD CONSTRAINT topology_topology_fk
FOREIGN KEY (parent_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offense ADD CONSTRAINT topology_detention_fk
FOREIGN KEY (tp_area_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offense ADD CONSTRAINT typology_detention_fk
FOREIGN KEY (tp_crime_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE person ADD CONSTRAINT typology_person_fk
FOREIGN KEY (tp_gender_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE necropcy ADD CONSTRAINT typology_necropcy_fk
FOREIGN KEY (tp_causa_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE judgment ADD CONSTRAINT typology_judgment_fk
FOREIGN KEY (tp_involment_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE judgment ADD CONSTRAINT typology_judgment_fk1
FOREIGN KEY (tp_rule_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offense ADD CONSTRAINT person_detention_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE necropcy ADD CONSTRAINT person_necropcy_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offended ADD CONSTRAINT person_offended_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pregnancy ADD CONSTRAINT person_pregnancy_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE exhumation ADD CONSTRAINT detention_exhumation_fk
FOREIGN KEY (offense_id)
REFERENCES offense (offense_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE judgment ADD CONSTRAINT offense_judgment_fk
FOREIGN KEY (offense_id)
REFERENCES offense (offense_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE offended ADD CONSTRAINT offense_offended_fk
FOREIGN KEY (offense_id)
REFERENCES offense (offense_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE medical_evaluation ADD CONSTRAINT offended_medical_evaluation_fk
FOREIGN KEY (offended_id)
REFERENCES offended (offended_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;