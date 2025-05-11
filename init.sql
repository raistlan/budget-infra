-- we're going to use this setup.sql file to create the database and the tables
-- https://yes-we-can-devops.hashnode.dev/docker-entrypoint-initdbd
-- based on that blog post, we just have to make sure that we mount this file
-- to the /docker-entrypoint-initdb.d/ directory in the container
-- and register the volume in the docker-compose file.
-- this will run against the ${POSTGRES_DB} database.
-- 
-- TODO
-- research migration tools (in the future we can use a migration tool to manage the database schema)
-- copilot is suggesting prisma or flyway
--
-------------
-- DECISIONS
-------------
-- I'm just using TEXT everywhere for simplicity.
-- so I was originally going to use cuids, but I'm going to switch to UUIDs so that I can maintain standards across all the services.
-- it probably doesn't matter that much at the scale that I'm going to be working with initially.
-- emails are also TEXT, but the maximum length is 256 (according to this errata https://www.rfc-editor.org/errata_search.php?rfc=3696).
-- the potential perf differences don't matter at this scale
CREATE TABLE
    IF NOT EXISTS users (
        id UUID NOT NULL DEFAULT gen_random_uuid () PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE
    IF NOT EXISTS entries (
        id UUID NOT NULL DEFAULT gen_random_uuid () PRIMARY KEY,
        user_id UUID NOT NULL,
        value INT NOT NULL,
        description VARCHAR NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    );

-- we are almost always going to be querying by user_id, so let's create an index on that
CREATE INDEX idx_entries_user_id ON entries (user_id);

-- we want to sort by created_at by default, so let's create an index on that too
CREATE INDEX idx_entries_created_at ON entries (created_at);

CREATE TABLE
    IF NOT EXISTS settings (
        user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
        budget INT NOT NULL,
        currency TEXT NOT NULL,
        period TEXT NOT NULL -- weekly/monthly
    );