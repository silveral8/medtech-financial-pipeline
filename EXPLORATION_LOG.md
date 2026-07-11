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
Started drafting README and DATA_DICTIONARY.
Next step: build unified gross profit view using CASE statement.

## June 11 — Project roadmap & Built unified gross profit view
Started drafting project ROADMAP.
View handles both GrossProfit tag and Revenue minus COGS calculation
gp_method column flags which method was used per ticker
ALL 19 tickers returning clearn data witn no NULLs
Found two anomalies to investigate: SKY 2024 showing 14,440 vs normal 3,700-4,600
range, likely the 11 duplicate rows issue
BAX 2024 showing 3,984 vs 959 from earlier query, needs investigation
GMED correctly flips from direct to calculated after 2023 post merger

## June 21-22 - SYK, BAX, EW anomaly investigation
Discovered SYK, BAX, and EW tag quarterly cumulative values as FY in their 
XBRL filings. THis caused our view to pull incorrect values.
Confirmed using distinct_period_ends query - these three tickers show 
9 distinct period_end dates vs normal 3 for the other tickers.
Fix: replaced fiscal_year column with EXTRACT(YEART FROM period_end) 
and added December 31 filter to all subqueries in the view.
Also added value DESC as tiebreaker to pick largest valye per date.
SYK now fixed and returning clean values. EW 2024 still showing wrong
value (1,093 vs excepted ~4,322). ISRG 2021 looks suspicious - 
investigate next session

## June 23 - EW and ISRG anomaly investigation
Isolated EW gross profit issue to the FULL OUTER JOIN with COGS subquery.
EW reports both GrossProfit directly and CostOfGoodsAndServicesSold.
When all three subqueries join, CASE statement sometimes pick
calculated method instead of direct GrossProfit tag.

Fix needed: add priority rule to CASE statement so direct GrossProfit
always wins when available, regardless of COGS presence.
ISRG has same pattern - investigate alongside EW fix next session.

## June 25-26 - Discovered non-December fiscal year end problem
December 31 filter in gross profit view is excluding four tickers:
- AAPL: fiscal year ends in Septemeber
- MDT: fiscal year ends in April
- RMD: fiscal year ends in June 30
- ILMN: fiscal year straddles late December/early January

Need to rebuild view using dominant period_end date per ticker
instead of hardcoded December 31 filter.
EW fix confirmed working after DROP and recreate.

## July 10 - Rebuilt gross profit view with dynamic fiscaly year and CTE
Discovered old view was still running despite CREATE or REPLACE.
Had to DROP VIEW and recreate to force new definition.
Confirmed via SELECT definition FROM pg-views.

Rebuilt view using CTE approach with fiscal_year_ends subquery
that dynamically identifies each ticker's dominant fiscal month
instead of hardcoding December 31.

Fixed tickers:
- APPL now showing correctly using September fiscal year end
- MDT now showing correctly using April fiscal year end
- RMD now showing correctly using June fiscal year end
- ILMN partially fixed, showing 2023-2025, missing 2021-2022

Remaining issues to investigate next session:
- SKY still showing inflated values (16,065 and 14,440)
- ILMN missing 2021 and 2022
- ABT missing entirely

## July 10 - Swithced fiscal_year_ends CTE to use NetIncomeLoss
Changed dominanat month detection from us-gaap:GrossProfit to
us-gaap:NetIncomeLoss since all tickers report net income.
This fxed ABT which had equal row counts across all months
when using GrossProfit, causing wrong dominant month selection.

Fixed this session:
- ABT now showing correctly with caluculated method
- ALL previously fixed tickers still clean

Remaining issues:
- SYK still showing inflated values (16,065 and 14,440)
-ILMN missing 2021 and 2022
- BSX missing entirely