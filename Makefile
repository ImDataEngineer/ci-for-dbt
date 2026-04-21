.PHONY: install deps seed build test lint clean all

# Installs the Python dependencies.
install:
	pip install --quiet -r requirements.txt

# Installs dbt packages declared in packages.yml.
deps:
	dbt deps --profiles-dir .

# Loads the CSV fixtures from seeds/ into DuckDB.
seed:
	dbt seed --profiles-dir .

# Runs every model and every test end-to-end. This is what CI runs.
build:
	dbt build --profiles-dir .

# Runs only the tests (models must already be built).
test:
	dbt test --profiles-dir .

# Lints the SQL. Reproduces what CI's sqlfluff job does.
lint:
	sqlfluff lint models/

# Wipes the local database and dbt artifacts. Useful when a schema drift
# leaves stale table definitions.
clean:
	rm -f dev.duckdb dev.duckdb.wal ci.duckdb ci.duckdb.wal
	rm -rf target/ logs/

# One-shot "start from scratch": deps + seed + build.
all: deps seed build
