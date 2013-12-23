DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS provider;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS location;

CREATE TABLE location (
    id      SERIAL       PRIMARY KEY NOT NULL,
    name    VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    zipcode INTEGER      NOT NULL,
    url     VARCHAR(255),
    UNIQUE(name, address, zipcode)
);

CREATE TABLE artist (
    id          SERIAL       PRIMARY KEY NOT NULL,
    name        VARCHAR(255) NOT NULL UNIQUE,
    url         VARCHAR(255)
);

CREATE TABLE provider (
    id          SERIAL       PRIMARY KEY NOT NULL,
    name        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE event (
    id          SERIAL       PRIMARY KEY NOT NULL,
    name        VARCHAR(255),
    location    INTEGER      NOT NULL REFERENCES location (id),
    artist      INTEGER      NOT NULL REFERENCES artist (id),
    provider    INTEGER      NOT NULL REFERENCES provider (id),
    start_date  TIMESTAMP    NOT NULL,
    internal_id VARCHAR(255),
    url         VARCHAR(255),
    buy_url     VARCHAR(255),
    UNIQUE(provider, internal_id)
);
