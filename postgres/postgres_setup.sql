CREATE TABLE account(
 id serial PRIMARY KEY,
 username VARCHAR (50) UNIQUE NOT NULL,
 password VARCHAR (500) NOT NULL,
 super INTEGER
);
COPY account (username, password, super) FROM '/data/users.csv' WITH (FORMAT CSV, HEADER);