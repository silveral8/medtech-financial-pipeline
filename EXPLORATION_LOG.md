# Exploration Log

## April 7 — Environment setup
Got Anaconda installed on the Mac. Ran into permission errors right away,
had to fix file ownership with chown before conda init would work.
Finally got (base) showing in terminal prompt.

## April 9 — PostgreSQL and VS Code setup
Set up local PostgreSQL database. Confirmed postgres, template0, template1
databases exist. Installed Python libraries in edgar_pipeline environment:
pandas, sqlalchemy, psycopg2-binary, edgartools.

## April 11 — First EDGAR extraction
Got the first script working for AAPL. Pulled 24,852 rows into local
postgres database. Used set_identity for SEC compliance.
Learned the difference between if_exists='replace' vs 'append'.

## April 14 — Explored AAPL data in psql
First time querying the database directly in terminal.
Looked at the schema, ran some basic SELECT queries.
Noticed the us-gaap: prefix on all concept names.
Created first SQL view: clean_apple_financials.

## April 16 — Built multi-company pipeline
Rewrote the script to loop through multiple tickers.
Added ticker and industry columns to tag each row.
Ran into syntax errors with indentation in the try/except block.
Fixed and successfully pulled first batch of MedTech companies.

## April 22 — Expanded MedTech universe
Added 10 more MedTech companies including ISRG, SYK, ZBH, BAX, ALC.
Also added San Diego cluster: DXCM, RMD, ATEC, GMED, ILMN.
Had a typo with IRSG instead of ISRG which caused 86 orphan rows.
Cleaned those up with DELETE WHERE ticker IS NULL.
Total rows now around 430,000 across 19 companies and 3 industries.

## April 25 — Git and GitHub setup
Initialized git repo. Learned about personal access tokens for GitHub auth.
Accidentally initialized git at the wrong folder level (Prof_Dev_Projects)
instead of the isolated project folder. Had to delete repo and start over.
Set up proper folder structure with scripts/ queries/ views/.

## May 6 — Started SQL data exploration
Turned off psql pager with \pset pager off.
Ran row count queries by ticker and industry.
Discovered duplicate rows per fiscal year — same metric showing
3 different values for the same FY.
Fixed with DISTINCT ON and ORDER BY period_end DESC.

## May 8 — Cross company net income analysis
Pulled net income for all MedTech tickers 2021-2025.
Key observations:
- ISRG most consistent grower
- BAX losing money 3 of 5 years
- ABT 2024 net income anomaly at 13.4B vs normal 6-7B range
- INSP just turned profitable in 2024

## May 13 — Gross profit data quality audit
Ran gross profit query, got 68 rows vs 78 for net income.
Investigated the gap — found four companies don't tag GrossProfit directly:
ABT, MDT, ZBH, GMED.
All four have Revenue and CostOfGoodsAndServicesSold so can calculate it.
GMED issue is post-merger artifact from NuVasive acquisition in late 2023.

## May 15 — Confirmed calculation method for missing tickers
Tested Revenue minus COGS approach for ABT.
Numbers look clean — consistent ~56% gross margin across 5 years.
Same approach confirmed for MDT, ZBH, GMED.
Ready to build unified gross profit view.

## June 10 — Project cleanup and documentation
Reorganized project folder structure.
Moved scripts to scripts/, SQL files to queries/.
Set up GitHub repo properly with .gitignore.
Started drafting README, DATA_DICTIONARY, EXPLORATION_LOG.
Next step: build unified gross profit view using CASE statement.