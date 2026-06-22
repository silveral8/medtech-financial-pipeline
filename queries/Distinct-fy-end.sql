SELECT DISTINCT ON (ticker, fiscal_year) ticker, fiscal_year,
        value / 1000000.0 AS gp_millions,
        period_end
FROM apple_facts
WHERE ticker IN ('SYK', 'BAX')
AND concept = 'us-gaap:GrossProfit'
AND fiscal_period = 'FY'
AND fiscal_year BETWEEN 2020 AND 2026
AND unit = 'USD'
AND EXTRACT(MONTH FROM period_end) = 12
AND EXTRACT(DAY FROM period_end) = 31
ORDER BY ticker, fiscal_year DESC, value DESC;