-- Staging model: clean and type the raw orders seed.
-- Reference implementation — left complete so you can see the pattern.

with source as (
    select * from {{ ref('raw_orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        cast(order_date as date) as order_date,
        amount_cents,
        cast(amount_cents as decimal(18, 2)) / 100 as amount_eur,
        status
    from source
)

select * from renamed
