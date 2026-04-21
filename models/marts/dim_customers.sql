-- TODO (à toi) : construis la dimension clients.
--
-- Colonnes attendues :
--   customer_id        (clé primaire, unique, not null)
--   email              (lowercase)
--   name
--   country
--   plan
--   signed_up_at       (date)
--   total_orders       (int — nombre de commandes avec status != 'cancelled')
--   total_spend_eur    (decimal — somme amount_eur sur les commandes non-cancelled)
--   first_order_date   (date, nullable pour les clients sans commande payée)
--
-- Pistes :
--   - Pars de {{ ref('stg_customers') }} LEFT JOIN sur une agrégation
--     per-customer de {{ ref('stg_orders') }}.
--   - Exclus les 'cancelled' dans total_orders et total_spend.
--   - Garde les clients sans commande : coalesce les totaux à 0.
--
-- Quand tu as fini, lance `make build` localement. Puis remplis _marts.yml
-- avec les tests et le contrat que la CI va vérifier.

select
    1 as placeholder  -- remplace-moi
