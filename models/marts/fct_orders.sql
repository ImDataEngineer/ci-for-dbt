-- TODO (à toi) : construis le fact commandes.
--
-- Colonnes attendues :
--   order_id           (clé primaire, unique, not null)
--   customer_id        (clé étrangère vers dim_customers.customer_id)
--   order_date
--   amount_cents
--   amount_eur
--   status             (seulement 'placed', 'paid', 'cancelled', 'refunded')
--   is_revenue         (booléen : true ssi status = 'paid')
--   customer_country   (joint depuis dim_customers — dénormalisé pour que
--                       l'analyste en aval fasse "revenue by country" sans
--                       avoir à refaire le join)
--
-- Pars de {{ ref('stg_orders') }} LEFT JOIN {{ ref('dim_customers') }}
-- sur customer_id.

select
    1 as placeholder  -- remplace-moi
