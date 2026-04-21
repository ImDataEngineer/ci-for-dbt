-- Staging : nettoie et type le seed raw_customers.
-- Implémentation de référence — laissée complète pour que tu voies le pattern.
-- Ton travail est dans la couche marts/.

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
