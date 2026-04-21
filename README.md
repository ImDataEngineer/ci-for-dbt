# ci-for-dbt — Une CI qui teste vraiment ton SQL

**Niveau :** junior · **Durée estimée :** ~8 heures · **Stack :** dbt-core, dbt-duckdb, sqlfluff, GitHub Actions

---

## Le scénario

Tu viens d'arriver dans une boîte dont le projet dbt a **zéro test et zéro CI**. Les analystes cassent les modèles à chaque review, personne ne voit rien, et on découvre la régression quand un dashboard renvoie n'importe quoi le lundi matin.

Ta mission : **sortir cette équipe de l'amateurisme**. Tu pars d'un mini projet dbt (staging + marts) sur un jeu de données fourni, tu ajoutes les tests qui comptent, et tu câbles une CI qui attrape trois classes de régression avant qu'elles atteignent la prod :

1. **Erreur de syntaxe SQL** (via `sqlfluff`)
2. **Dérive de schéma** (via contrats dbt)
3. **Défaut qualité donnée** (via tests dbt génériques + singuliers)

---

## Ce qui tourne déjà

Pour que tu te concentres sur ce qui compte pédagogiquement, le template fournit :

- **Un projet dbt fonctionnel** (`dbt_project.yml`, `profiles.yml` pointant vers DuckDB local)
- **Les deux seeds** : `seeds/raw_customers.csv` (50 clients) + `seeds/raw_orders.csv` (200 commandes)
- **Deux staging models déjà écrits** (`stg_customers`, `stg_orders`) — reference pour le pattern
- **Une config `sqlfluff`** pour DuckDB
- **Une rubrique d'évaluation CI** (`.github/workflows/iamdataeng-evaluate.yml`) — **ne la modifie pas**, c'est elle qui détermine si ta soumission passe

## Ce que tu dois faire

### 1. Implémenter les deux marts (`models/marts/`)

**`dim_customers.sql`** — dimension client, une ligne par `customer_id`. Colonnes attendues :

| colonne | type | description |
|---|---|---|
| `customer_id` | varchar | Clé primaire, unique, non-null |
| `email` | varchar | Email lowercase |
| `name` | varchar | Nom complet |
| `country` | varchar | Code pays ISO-2 |
| `plan` | varchar | `free` / `pro` / `enterprise` |
| `signed_up_at` | date | Date d'inscription |
| `total_orders` | integer | Nombre de commandes non-cancelled |
| `total_spend_eur` | decimal(18,2) | Somme `amount_eur` des commandes non-cancelled |
| `first_order_date` | date | Nullable si aucune commande |

**`fct_orders.sql`** — fait commandes, une ligne par `order_id`. Colonnes attendues :

| colonne | type | description |
|---|---|---|
| `order_id` | varchar | Clé primaire |
| `customer_id` | varchar | FK vers `dim_customers.customer_id` |
| `order_date` | date | |
| `amount_cents` | integer | |
| `amount_eur` | decimal(18,2) | |
| `status` | varchar | Un de `placed`, `paid`, `cancelled`, `refunded` |
| `is_revenue` | boolean | `true` si `status = 'paid'` |
| `customer_country` | varchar | Dénormalisé depuis `dim_customers.country` |

### 2. Écrire les tests dans `models/marts/_marts.yml`

**Minimum 5 tests** répartis sur les deux modèles. Utilise les tests génériques dbt :
- `not_null` sur les clés et colonnes critiques
- `unique` sur les clés primaires
- `relationships` pour la FK `fct_orders.customer_id` → `dim_customers.customer_id`
- `accepted_values` sur `fct_orders.status`

### 3. Écrire au moins un test singulier dans `tests/`

Un test singulier est une requête qui retourne des lignes quand une règle métier est violée. Exemple pertinent : *"les commandes doivent avoir un `amount_cents > 0` sauf si statut cancelled/refunded"*.

### 4. Déclarer un contrat sur `dim_customers`

Dans `_marts.yml`, ajoute `config.contract.enforced: true` sur `dim_customers`, et déclare **toutes les colonnes** avec leur `data_type`. Le job CI `contract-breakage` simule un changement de schéma côté source (rename de colonne) — ton contrat doit faire **échouer** `dbt build` avec une erreur explicite.

[Doc dbt sur les contracts](https://docs.getdbt.com/reference/resource-configs/contract)

---

## Démarrage rapide

```bash
# 1. Dépendances Python
make install

# 2. Packages dbt (dbt_utils)
make deps

# 3. Charger les seeds
make seed

# 4. Build complet (seeds + modèles + tests)
make build

# 5. Lint SQL
make lint
```

En alternative zéro-setup : ouvre le projet dans Ona via le bouton "Commencer" sur iamdataeng.fr — tout sera installé automatiquement dans le devcontainer.

---

## Comment ton travail est évalué

À chaque push sur `main` ou sur une branche, le workflow `.github/workflows/iamdataeng-evaluate.yml` tourne et vérifie :

| Check | Ce qui est testé | Si ça fail |
|---|---|---|
| **dbt_build_passes** | `dbt build` complet exit 0 | Un modèle plante ou un test échoue. Regarde les logs dbt — la première ligne rouge donne la cause. |
| **minimum_test_count ≥ 5** | Au moins 5 tests exécutés (génériques + singuliers combinés) | Tu as moins de 5 tests. Ajoute `not_null` sur les PKs, `unique` sur les business keys, `relationships` sur les FKs. |
| **sqlfluff_passes** | `sqlfluff lint models/` exit 0 | Violations de style SQL. `sqlfluff fix models/` localement peut en corriger la plupart automatiquement. |
| **contract_breakage_caught** | Après rename d'une colonne dans un seed, `dbt build` DOIT échouer | Ton contrat n'enforce pas réellement le schéma. Déclare toutes les colonnes avec `data_type` et `enforced: true`. |

Tu peux push autant de fois que tu veux pour itérer. Aucune limite de soumission.

---

## Pièges classiques à éviter

- **`{{ ref('stg_customers') }}` dans la FROM** mais pas déclaré comme dépendance en amont → erreur de compilation dbt.
- **`sqlfluff` configuré pour PostgreSQL** alors que le projet cible DuckDB → faux positifs. Le `.sqlfluff` fourni est déjà bon, ne le change pas.
- **Tests lancés via `dbt test`** seulement au lieu de `dbt build` → tu rates les modèles qui plantent. Toujours `dbt build`.
- **Contrat déclaré mais `enforced: false`** (ou oublié) → le contrat est cosmétique, pas un garde-fou.
- **`data_type` mis en majuscules** (VARCHAR) alors que DuckDB renvoie minuscules → le contrat échoue pour la mauvaise raison. Écris les types en minuscules.

---

## Références

- Reis & Housley, *Fundamentals of Data Engineering*, chapitre 2 (Undercurrents — DataOps, Testing)
- dbt docs — [Tests](https://docs.getdbt.com/docs/build/data-tests), [Contracts](https://docs.getdbt.com/reference/resource-configs/contract)
- Kimball & Ross, chapitre 3 — Grain discipline (applicable au fact `fct_orders`)
