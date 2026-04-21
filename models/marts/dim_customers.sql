-- TODO (learner): build the customer dimension.
--
-- Expected columns:
--   customer_id        (primary key, unique, not null)
--   email              (lowercased)
--   name
--   country
--   plan
--   signed_up_at       (date)
--   total_orders       (int, number of orders with status != 'cancelled')
--   total_spend_eur    (decimal, sum of amount_eur for non-cancelled orders)
--   first_order_date   (date, nullable for customers with no paid order)
--
-- Hints:
--   - Start from {{ ref('stg_customers') }} left joined to a per-customer
--     aggregation on {{ ref('stg_orders') }}.
--   - Exclude 'cancelled' orders when computing total_orders and total_spend.
--   - Keep customers who have zero orders: coalesce totals to 0.
--
-- When you're done, run `make build` locally. Then fill _marts.yml with
-- the tests and the contract that the CI will check.

select
    1 as placeholder  -- replace me
