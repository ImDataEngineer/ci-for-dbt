# ci-for-dbt — a CI that actually tests your SQL

**Level:** junior · **Estimated time:** ~8 hours · **Stack:** dbt-core, dbt-duckdb, sqlfluff, GitHub Actions

---

## The scenario

You just joined a company whose dbt project has **zero tests and zero
CI**. Analysts break models on every review, nobody notices, and the
regression surfaces on Monday morning when a dashboard shows garbage.

Your mission: **drag this team out of amateur hour**. You start from a
minimal dbt project (staging + marts) on a provided dataset, you add the
tests that matter, and you wire a CI that catches three classes of
regression before they hit production:

1. **SQL syntax error** (via `sqlfluff`)
2. **Schema drift** (via dbt contracts)
3. **Data-quality defect** (via dbt generic + singular tests)

---

## What's already running

So that you focus on what matters pedagogically, the template ships:

- **A working dbt project** (`dbt_project.yml`, `profiles.yml` pointing
  at local DuckDB)
- **The two seeds**: `seeds/raw_customers.csv` (50 customers) +
  `seeds/raw_orders.csv` (200 orders)
- **Two staging models already written** (`stg_customers`, `stg_orders`)
  — reference for the pattern
- **A `sqlfluff` config** for DuckDB
- **A CI evaluation rubric**
  (`.github/workflows/iamdataeng-evaluate.yml`) — **don't modify it**,
  it's the file that decides whether your submission passes

## What you have to do

### 1. Implement the two marts (`models/marts/`)

**`dim_customers.sql`** — customer dimension, one row per `customer_id`.
Expected columns:

| column | type | description |
|---|---|---|
| `customer_id` | varchar | Primary key, unique, not null |
| `email` | varchar | Lowercased email |
| `name` | varchar | Full name |
| `country` | varchar | ISO-2 country code |
| `plan` | varchar | `free` / `pro` / `enterprise` |
| `signed_up_at` | date | Signup date |
| `total_orders` | integer | Count of non-cancelled orders |
| `total_spend_eur` | decimal(18,2) | Sum of `amount_eur` over non-cancelled orders |
| `first_order_date` | date | Nullable if no order |

**`fct_orders.sql`** — orders fact, one row per `order_id`. Expected
columns:

| column | type | description |
|---|---|---|
| `order_id` | varchar | Primary key |
| `customer_id` | varchar | FK to `dim_customers.customer_id` |
| `order_date` | date | |
| `amount_cents` | integer | |
| `amount_eur` | decimal(18,2) | |
| `status` | varchar | One of `placed`, `paid`, `cancelled`, `refunded` |
| `is_revenue` | boolean | `true` if `status = 'paid'` |
| `customer_country` | varchar | Denormalized from `dim_customers.country` |

### 2. Write the tests in `models/marts/_marts.yml`

**Minimum 5 tests** spread across the two models. Use dbt generic tests:
- `not_null` on keys and critical columns
- `unique` on primary keys
- `relationships` for the FK `fct_orders.customer_id` →
  `dim_customers.customer_id`
- `accepted_values` on `fct_orders.status`

### 3. Write at least one singular test in `tests/`

A singular test is a query that returns rows when a business rule is
violated. A relevant example: *"orders must have `amount_cents > 0`
unless their status is cancelled/refunded"*.

### 4. Declare a contract on `dim_customers`

In `_marts.yml`, add `config.contract.enforced: true` on
`dim_customers`, and declare **all columns** with their `data_type`.
The `contract-breakage` CI job simulates a source schema change (a
column rename) — your contract must make `dbt build` **fail** with an
explicit error.

[dbt docs on contracts](https://docs.getdbt.com/reference/resource-configs/contract)

---

## Quick start

```bash
# 1. Python dependencies
make install

# 2. dbt packages (dbt_utils)
make deps

# 3. Load seeds
make seed

# 4. Full build (seeds + models + tests)
make build

# 5. SQL lint
make lint
```

Alternative, zero-setup: open the project in GitHub Codespaces via the
"Start" button on iamdataeng.vercel.app — everything will be installed
automatically in the devcontainer.

---

## How your work is graded

On every push to `main` or to a branch, the workflow
`.github/workflows/iamdataeng-evaluate.yml` runs and checks:

| Check | What's tested | If it fails |
|---|---|---|
| **dbt_build_passes** | Full `dbt build` exits 0 | A model crashed or a test failed. Look at the dbt logs — the first red line gives you the cause. |
| **minimum_test_count ≥ 5** | At least 5 tests executed (generic + singular combined) | You have fewer than 5 tests. Add `not_null` on PKs, `unique` on business keys, `relationships` on FKs. |
| **sqlfluff_passes** | `sqlfluff lint models/` exits 0 | SQL style violations. `sqlfluff fix models/` locally can auto-fix most of them. |
| **contract_breakage_caught** | After a column is renamed in a seed, `dbt build` MUST fail | Your contract doesn't actually enforce the schema. Declare all columns with `data_type` and `enforced: true`. |

You can push as many times as you want to iterate. No submission
limit.

---

## Classic traps to avoid

- **`{{ ref('stg_customers') }}` in the FROM** but not declared as an
  upstream dependency → dbt compile error.
- **`sqlfluff` configured for PostgreSQL** when the project targets
  DuckDB → false positives. The provided `.sqlfluff` is already
  correct, don't change it.
- **Tests run via `dbt test`** only instead of `dbt build` → you miss
  models that crash. Always `dbt build`.
- **Contract declared but `enforced: false`** (or forgotten) → the
  contract is cosmetic, not a guardrail.
- **`data_type` in uppercase** (VARCHAR) when DuckDB returns lowercase
  → the contract fails for the wrong reason. Write types in lowercase.

---

## References

- Reis & Housley, *Fundamentals of Data Engineering*, chapter 2
  (Undercurrents — DataOps, Testing)
- dbt docs — [Tests](https://docs.getdbt.com/docs/build/data-tests),
  [Contracts](https://docs.getdbt.com/reference/resource-configs/contract)
- Kimball & Ross, chapter 3 — Grain discipline (applies to the
  `fct_orders` fact)
