CREATE TABLE person (
                person_id SERIAL,
                date_of_death TIMESTAMP,
                tp_gender_id INTEGER,
                age INTEGER,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                CONSTRAINT person_pk PRIMARY KEY (person_id)
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

CREATE TABLE detention (
                detention_id BIGINT NOT NULL,
                detention_date TIMESTAMP NOT NULL,
                tp_area_id INTEGER,
                zone INTEGER,
                territory_id INTEGER,
                tp_crime_id INTEGER NOT NULL,
                person_id BIGINT NOT NULL,
                CONSTRAINT detention_pk PRIMARY KEY (detention_id)
);

CREATE TABLE necropcy (
                necropcy_id BIGINT NOT NULL,
                necropcy_date DATE NOT NULL,
                territory_id INTEGER,
                tp_causa_id INTEGER NOT NULL,
                person_id BIGINT NOT NULL,
                CONSTRAINT necropcy_pk PRIMARY KEY (necropcy_id)
);

CREATE TABLE exhumation (
                exhumation_id BIGINT NOT NULL,
                exhumation_date DATE NOT NULL,
                territory_id INTEGER NOT NULL,
                detention_id BIGINT NOT NULL,
                CONSTRAINT exhumation_pk PRIMARY KEY (exhumation_id)
);


ALTER TABLE exhumation ADD CONSTRAINT territory_exhumation_fk
FOREIGN KEY (territory_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE exhumation ADD CONSTRAINT detention_exhumation_fk
FOREIGN KEY (detention_id)
REFERENCES detention (detention_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

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

ALTER TABLE territory ADD CONSTRAINT territory_territory_fk
FOREIGN KEY (parent_id)
REFERENCES territory (territory_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE detention ADD CONSTRAINT territory_detention_fk
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

ALTER TABLE detention ADD CONSTRAINT topology_detention_fk
FOREIGN KEY (tp_area_id)
REFERENCES typology (typology_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE detention ADD CONSTRAINT typology_detention_fk
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

ALTER TABLE detention ADD CONSTRAINT person_detention_fk
FOREIGN KEY (person_id)
REFERENCES person (person_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;