# Data Dictionary

## Master Table: `apple_facts`
Note: needs to be renamed to something like `medtech_facts` eventually

## Where the data comes from
SEC EDGAR filings pulled using the edgartools Python library.
Each row represents one reported financial fact from a company's 
10-K or 10-Q filing.

## Columns

**concept** — the XBRL tag for the metric, always starts with us-gaap:
example: us-gaap:NetIncomeLoss

**label** — plain english version of the concept
example: "Net Income Loss"

**value** — the raw number in actual dollars. divide by 1000000 to get millions

**numeric_value** — another version of value, not always populated

**unit** — USD for financial metrics, shares for share counts

**period_start / period_end** — start and end dates of the reporting period
period_end is important for deduplication — most recent = most accurate

**fiscal_year** — the fiscal year. some rows have 0 which is a data issue,
always filter with WHERE fiscal_year > 2000

**fiscal_period** — FY, Q1, Q2, or Q3

**ticker** — stock ticker (DXCM, ISRG, etc)

**industry** — tag added during ingestion: MedTech, High Tech, or Genomics

## Concepts I'm actually using

us-gaap:NetIncomeLoss — net income, available for all tickers
us-gaap:GrossProfit — not available for ABT, MDT, ZBH, GMED in recent years
us-gaap:ResearchAndDevelopmentExpense — available for all tickers
us-gaap:OperatingIncomeLoss — available for all tickers
us-gaap:Revenues — revenue tag used by GMED
us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax — revenue tag used by ABT, MDT, ZBH
us-gaap:CostOfGoodsAndServicesSold — used to back into gross profit for ABT, MDT, ZBH, GMED

## Gross profit — two methods depending on company

Direct us-gaap:GrossProfit tag:
BSX, DXCM, EW, INSP, ISRG, PODD, PEN, RMD, SENS, TNDM, ATEC

Have to calculate Revenue minus COGS:
ABT, GMED, MDT, ZBH