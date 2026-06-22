CREATE OR REPLACE VIEW medtech_gross_profit AS
SELECT
    COALESCE(gp.ticker, rev.ticker, cogs.ticker) AS ticker,
    COALESCE(gp.true_year, rev.true_year, cogs.true_year) AS fiscal_year,
    CASE
        WHEN gp.value IS NOT NULL THEN gp.value
        ELSE rev.value - cogs.value
    END AS gross_profit,
    CASE
        WHEN gp.value IS NOT NULL THEN gp.value / 1000000.0
        ELSE (rev.value - cogs.value) / 1000000.0
    END AS gross_profit_millions,
    CASE
        WHEN gp.value IS NOT NULL THEN 'direct'
        ELSE 'calculated'
    END AS gp_method
FROM
    (SELECT DISTINCT ON (ticker, EXTRACT(YEAR FROM period_end))
        ticker,
        EXTRACT(YEAR FROM period_end)::int AS true_year,
        value
     FROM apple_facts
     WHERE concept = 'us-gaap:GrossProfit'
     AND fiscal_period = 'FY'
     AND unit = 'USD'
     AND EXTRACT(MONTH FROM period_end) = 12
     AND EXTRACT(DAY FROM period_end) = 31
     ORDER BY ticker, EXTRACT(YEAR FROM period_end) DESC, value DESC) gp
FULL OUTER JOIN
    (SELECT DISTINCT ON (ticker, EXTRACT(YEAR FROM period_end))
        ticker,
        EXTRACT(YEAR FROM period_end)::int AS true_year,
        value
     FROM apple_facts
     WHERE concept IN (
         'us-gaap:Revenues',
         'us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax')
     AND fiscal_period = 'FY'
     AND unit = 'USD'
     AND EXTRACT(MONTH FROM period_end) = 12
     AND EXTRACT(DAY FROM period_end) = 31
     ORDER BY ticker, EXTRACT(YEAR FROM period_end) DESC, value DESC) rev
USING (ticker, true_year)
FULL OUTER JOIN
    (SELECT DISTINCT ON (ticker, EXTRACT(YEAR FROM period_end))
        ticker,
        EXTRACT(YEAR FROM period_end)::int AS true_year,
        value
     FROM apple_facts
     WHERE concept = 'us-gaap:CostOfGoodsAndServicesSold'
     AND fiscal_period = 'FY'
     AND unit = 'USD'
     AND EXTRACT(MONTH FROM period_end) = 12
     AND EXTRACT(DAY FROM period_end) = 31
     ORDER BY ticker, EXTRACT(YEAR FROM period_end) DESC, value DESC) cogs
USING (ticker, true_year)
ORDER BY ticker, fiscal_year DESC;