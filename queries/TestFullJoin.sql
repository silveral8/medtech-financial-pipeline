SELECT 
    COALESCE(gp.ticker, rev.ticker) AS ticker,
    COALESCE(gp.true_year, rev.true_year) AS fiscal_year,
    gp.gp_millions,
    rev.rev_millions
FROM
    (SELECT DISTINCT ON (ticker, EXTRACT(YEAR FROM period_end))
        ticker,
        EXTRACT(YEAR FROM period_end)::int AS true_year,
        value / 1000000.0 AS gp_millions
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
        value / 1000000.0 AS rev_millions
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
ORDER BY fiscal_year DESC;