-- Staging model: clean and type the raw customers seed.
-- Reference implementation — left complete so you can see the pattern.
-- Your job is in the marts/ layer.

with source as (
    select * from {{ ref('raw_customers') }}
),

renamed as (
    select
        customer_id,
        lower(trim(email)) as email,
        name,
        country,
        plan,
        cast(signed_up_at as date) as signed_up_at
    from source
)

select * from renamed
