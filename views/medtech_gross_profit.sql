CREATE OR REPLACE VIEW medtech_gross_profit AS
SELECT
    COALESCE(gp.ticker, rev.ticker, cogs.ticker) AS ticker,
    COALESCE(gp.fiscal_year, rev.fiscal_year, cogs.fiscal_year) AS fiscal_year,
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
    (SELECT DISTINCT ON (ticker, fiscal_year) ticker, fiscal_year, value
     FROM apple_facts
     WHERE concept = 'us-gaap:GrossProfit'
     AND fiscal_period = 'FY'
     AND fiscal_year > 2000
     AND unit = 'USD'
     ORDER BY ticker, fiscal_year DESC, period_end DESC) gp
FULL OUTER JOIN
    (SELECT DISTINCT ON (ticker, fiscal_year) ticker, fiscal_year, value
     FROM apple_facts
     WHERE concept IN (
         'us-gaap:Revenues',
         'us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax')
     AND fiscal_period = 'FY'
     AND fiscal_year > 2000
     AND unit = 'USD'
     ORDER BY ticker, fiscal_year DESC, period_end DESC) rev
USING (ticker, fiscal_year)
FULL OUTER JOIN
    (SELECT DISTINCT ON (ticker, fiscal_year) ticker, fiscal_year, value
     FROM apple_facts
     WHERE concept = 'us-gaap:CostOfGoodsAndServicesSold'
     AND fiscal_period = 'FY'
     AND fiscal_year > 2000
     AND unit = 'USD'
     ORDER BY ticker, fiscal_year DESC, period_end DESC) cogs
USING (ticker, fiscal_year)
ORDER BY ticker, fiscal_year DESC;