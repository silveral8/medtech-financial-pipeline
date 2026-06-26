SELECT 
    COALESCE(gp.ticker, rev.ticker, cogs.ticker) AS ticker,
    COALESCE(gp.true_year, rev.true_year, cogs.true_year) AS fiscal_year,
    gp.value / 1000000.0 AS gp_value,
    rev.value / 1000000.0 AS rev_value,
    cogs.value / 1000000.0 AS cogs_value
FROM
    (SELECT DISTINCT ON (ticker, EXTRACT(YEAR FROM period_end))
        ticker,
        EXTRACT(YEAR FROM period_end)::int AS true_year,
        value
     FROM apple_facts
     WHERE concept = 'us-gaap:GrossProfit'
     AND ticker = 'EW'
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
     AND ticker = 'EW'
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
     AND ticker = 'EW'
     AND fiscal_period = 'FY'
     AND unit = 'USD'
     AND EXTRACT(MONTH FROM period_end) = 12
     AND EXTRACT(DAY FROM period_end) = 31
     ORDER BY ticker, EXTRACT(YEAR FROM period_end) DESC, value DESC) cogs
USING (ticker, true_year)
WHERE COALESCE(gp.true_year, rev.true_year, cogs.true_year) 
    BETWEEN 2021 AND 2025
ORDER BY fiscal_year DESC;