SELECT ticker, fiscal_year, gross_profit_millions, gp_method
FROM medtech_gross_profit
WHERE fiscal_year BETWEEN 2021 AND 2026
ORDER BY ticker, fiscal_year DESC;