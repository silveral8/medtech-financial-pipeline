SELECT ticker, fiscal_year, fiscal_period, 
       value / 1000000.0 AS gp_millions,
       period_end
FROM apple_facts
WHERE ticker = 'SYK'
AND concept = 'us-gaap:GrossProfit'
AND fiscal_period = 'FY'
AND fiscal_year = 2024
AND unit = 'USD'
ORDER BY period_end DESC;