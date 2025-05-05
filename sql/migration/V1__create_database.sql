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
                detention_id INTEGER NOT NULL,
                detention_date TIMESTAMP NOT NULL,
                tp_area_id INTEGER,
                zone INTEGER,
                tp_gender_id INTEGER,
                territory_id INTEGER,
                tp_crime_id INTEGER NOT NULL,
                CONSTRAINT detention_pk PRIMARY KEY (detention_id)
);

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

ALTER TABLE detention ADD CONSTRAINT topology_detention_fk1
FOREIGN KEY (tp_gender_id)
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