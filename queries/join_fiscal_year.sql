-- Select all row

SELECT
    r.ticker,
    r.fiscal_year,
    r.value / 1000000.0 AS revenue_millions,
    c.value / 1000000.0 AS cogs_millions,
    (r.value - c.value) / 1000000.0 AS calculated_gross_profit_millions
FROM
    (SELECT DISTINCT ON (fiscal_year) ticker, fiscal_year, value
     FROM apple_facts
     WHERE ticker = 'ABT'
     AND concept = 'us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax'
     AND fiscal_period = 'FY'
     AND fiscal_year BETWEEN 2021 AND 2026
     AND unit = 'USD'
     ORDER BY fiscal_year DESC, period_end DESC) r
JOIN
    (SELECT DISTINCT ON (fiscal_year) ticker, fiscal_year, value
     FROM apple_facts
     WHERE ticker = 'ABT'
     AND concept = 'us-gaap:CostOfGoodsAndServicesSold'
     AND fiscal_period = 'FY'
     AND fiscal_year BETWEEN 2021 AND 2026
     AND unit = 'USD'
     ORDER BY fiscal_year DESC, period_end DESC) c
ON r.fiscal_year = c.fiscal_year
ORDER BY r.fiscal_year DESC;