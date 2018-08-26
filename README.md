# PostgreSQL

A description of this package.

## Setting up PostgreSQL for development on Mac:

Use [Postgres.app][Postgres.app] to run PostgreSQL on Mac.

[Postgres.app]: https://postgresapp.com

Tests assume user postgres has password `"allowme"`.
Login to firefly database and run this statement:

```sql
ALTER USER "postgres" WITH PASSWORD 'allowme'
```
