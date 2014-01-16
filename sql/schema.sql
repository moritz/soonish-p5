DROP TABLE IF EXISTS artist_channel;
DROP TABLE IF EXISTS channel;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS provider;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS login;

CREATE TABLE location (
    id      SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    name    VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    zipcode VARCHAR(5)   NOT NULL,
    country INTEGER      NOT NULL REFERENCES country (id),
    city    VARCHAR(255) NOT NULL,
    url     VARCHAR(255),
    created     TIMESTAMP    NOT NULL DEFAULT NOW(),
    UNIQUE(name, address, zipcode)
);

CREATE TABLE artist (
    id          SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    name        VARCHAR(255) NOT NULL UNIQUE,
    url         VARCHAR(255),
    created     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE provider (
    id          SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    name        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE event (
    id          SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    name        VARCHAR(255),
    location    INTEGER      NOT NULL REFERENCES location (id),
    artist      INTEGER      NOT NULL REFERENCES artist (id),
    provider    INTEGER      NOT NULL REFERENCES provider (id),
    start_date  TIMESTAMP    NOT NULL,
    internal_id VARCHAR(255),
    url         VARCHAR(255),
    buy_url     VARCHAR(255),
    created     TIMESTAMP    NOT NULL DEFAULT NOW(),
    UNIQUE(provider, internal_id)
);

CREATE TABLE login (
    id          SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    is_admin    BOOLEAN      NOT NULL DEFAULT False,
    created     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE channel (
    id          SERIAL       PRIMARY KEY UNIQUE NOT NULL,
    name        VARCHAR(255) NOT NULL,
    login       INTEGER      NOT NULL REFERENCES login (id),
    nonce       INTEGER      NOT NULL UNIQUE DEFAULT (random() * 2147483647)::Integer,
    zipcode     VARCHAR(5),
    country     INTEGER     REFERENCES country (id),
    distance    REAL,
    UNIQUE(name, login)
);

CREATE TABLE artist_channel (
    id          SERIAL      PRIMARY KEY UNIQUE NOT NULL,
    artist      INTEGER     NOT NULL REFERENCES artist  (id),
    channel     INTEGER     NOT NULL REFERENCES channel (id),
    UNIQUE(artist, channel)
);
