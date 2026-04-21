-- TODO (learner): build the orders fact.
--
-- Expected columns:
--   order_id           (primary key, unique, not null)
--   customer_id        (foreign key to dim_customers.customer_id)
--   order_date
--   amount_cents
--   amount_eur
--   status             (only 'placed', 'paid', 'cancelled', 'refunded')
--   is_revenue         (boolean: true iff status = 'paid')
--   customer_country   (joined from dim_customers — denormalized for the
--                       analyst downstream who wants `revenue by country`
--                       without a join)
--
-- Start from {{ ref('stg_orders') }} left joined to {{ ref('dim_customers') }}
-- on customer_id.

select
    1 as placeholder  -- replace me
