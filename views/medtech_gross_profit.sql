CREATE OR REPLACE VIEW medtech_gross_profit AS
WITH fiscal_year_ends AS (
    SELECT ticker,
           month AS dominant_month
    FROM (
        SELECT ticker,
               EXTRACT(MONTH FROM period_end) AS month,
               COUNT(*) as rows,
               ROW_NUMBER() OVER (
                   PARTITION BY ticker 
                   ORDER BY COUNT(*) DESC
               ) as rn
        FROM apple_facts
        WHERE concept = 'us-gaap:NetIncomeLoss'
        AND fiscal_period = 'FY'
        AND unit = 'USD'
        GROUP BY ticker, EXTRACT(MONTH FROM period_end)
    ) ranked
    WHERE rn = 1
),
gp_clean AS (
    SELECT DISTINCT ON (a.ticker, EXTRACT(YEAR FROM 
           CASE 
               WHEN f.dominant_month = 1 
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end 
           END))
        a.ticker,
        EXTRACT(YEAR FROM 
           CASE 
               WHEN f.dominant_month = 1 
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end 
           END)::int AS fiscal_year,
        a.value
    FROM apple_facts a
    JOIN fiscal_year_ends f ON a.ticker = f.ticker
    WHERE a.concept = 'us-gaap:GrossProfit'
    AND a.fiscal_period = 'FY'
    AND a.unit = 'USD'
    AND EXTRACT(MONTH FROM a.period_end) = f.dominant_month
    ORDER BY a.ticker, 
             EXTRACT(YEAR FROM 
                CASE 
                    WHEN f.dominant_month = 1 
                    THEN a.period_end - INTERVAL '1 month'
                    ELSE a.period_end 
                END) DESC,
             a.value DESC
),
rev_clean AS (
    SELECT DISTINCT ON (a.ticker, EXTRACT(YEAR FROM
           CASE
               WHEN f.dominant_month = 1
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end
           END))
        a.ticker,
        EXTRACT(YEAR FROM
           CASE
               WHEN f.dominant_month = 1
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end
           END)::int AS fiscal_year,
        a.value
    FROM apple_facts a
    JOIN fiscal_year_ends f ON a.ticker = f.ticker
    WHERE a.concept IN (
        'us-gaap:Revenues',
        'us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax')
    AND a.fiscal_period = 'FY'
    AND a.unit = 'USD'
    AND EXTRACT(MONTH FROM a.period_end) = f.dominant_month
    ORDER BY a.ticker,
             EXTRACT(YEAR FROM
                CASE
                    WHEN f.dominant_month = 1
                    THEN a.period_end - INTERVAL '1 month'
                    ELSE a.period_end
                END) DESC,
             a.value DESC
),
cogs_clean AS (
    SELECT DISTINCT ON (a.ticker, EXTRACT(YEAR FROM
           CASE
               WHEN f.dominant_month = 1
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end
           END))
        a.ticker,
        EXTRACT(YEAR FROM
           CASE
               WHEN f.dominant_month = 1
               THEN a.period_end - INTERVAL '1 month'
               ELSE a.period_end
           END)::int AS fiscal_year,
        a.value
    FROM apple_facts a
    JOIN fiscal_year_ends f ON a.ticker = f.ticker
    WHERE a.concept = 'us-gaap:CostOfGoodsAndServicesSold'
    AND a.fiscal_period = 'FY'
    AND a.unit = 'USD'
    AND EXTRACT(MONTH FROM a.period_end) = f.dominant_month
    ORDER BY a.ticker,
             EXTRACT(YEAR FROM
                CASE
                    WHEN f.dominant_month = 1
                    THEN a.period_end - INTERVAL '1 month'
                    ELSE a.period_end
                END) DESC,
             a.value DESC
)
SELECT
    COALESCE(gp.ticker, rev.ticker, cogs.ticker) AS ticker,
    COALESCE(gp.fiscal_year, rev.fiscal_year, cogs.fiscal_year) AS fiscal_year,
    CASE
        WHEN gp.value IS NOT NULL THEN gp.value
        WHEN rev.value IS NOT NULL AND cogs.value IS NOT NULL
            THEN rev.value - cogs.value
        ELSE NULL
    END AS gross_profit,
    CASE
        WHEN gp.value IS NOT NULL THEN gp.value / 1000000.0
        WHEN rev.value IS NOT NULL AND cogs.value IS NOT NULL
            THEN (rev.value - cogs.value) / 1000000.0
        ELSE NULL
    END AS gross_profit_millions,
    CASE
        WHEN gp.value IS NOT NULL THEN 'direct'
        WHEN rev.value IS NOT NULL AND cogs.value IS NOT NULL
            THEN 'calculated'
        ELSE 'unavailable'
    END AS gp_method
FROM gp_clean gp
FULL OUTER JOIN rev_clean rev USING (ticker, fiscal_year)
FULL OUTER JOIN cogs_clean cogs USING (ticker, fiscal_year)
ORDER BY ticker, fiscal_year DESC;