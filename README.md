# MedTech Financial Data Pipeline

## Overview
An automated data pipeline that extracts financial data from SEC EDGAR filings 
for a curated universe of 19 MedTech companies, loads it into a local PostgreSQL 
database, and prepares it for financial analysis and visualization. Built as part 
of a broader effort to apply data engineering techniques to institutional-grade 
financial analysis.

## Data Source
- **Source:** SEC EDGAR via the `edgartools` Python library
- **Universe:** 19 publicly traded MedTech and adjacent companies
- **Volume:** 400,000+ individual XBRL financial facts
- **Coverage:** 2009-2025 across annual (10-K) and quarterly (10-Q) filings

## Tech Stack
- **Python** — pandas, sqlalchemy, edgartools
- **PostgreSQL** — local database for storage and analysis
- **Anaconda** — environment management
- **SQL** — data exploration, deduplication, and view creation

## Pipeline Architecture
SEC EDGAR API
↓
Python ETL Script (edgartools + pandas)
↓
Data Cleaning & Metadata Tagging (ticker, industry)
↓
PostgreSQL Local Database (apple_facts master table)
↓
SQL Views (deduplication + normalization)
↓
CSV Export → Tableau Public

## Companies Covered

| Ticker | Company | Sub-Sector |
|--------|---------|------------|
| DXCM | Dexcom | Continuous Glucose Monitoring |
| PODD | Insulet | Insulin Delivery |
| TNDM | Tandem Diabetes Care | Insulin Delivery |
| SENS | Senseonics | Implantable CGM |
| ISRG | Intuitive Surgical | Robotic Surgery |
| SYK | Stryker | Orthopedics & MedTech |
| ZBH | Zimmer Biomet | Joint Reconstruction |
| MDT | Medtronic | Diversified MedTech |
| BSX | Boston Scientific | Cardiovascular |
| EW | Edwards Lifesciences | Structural Heart |
| ABT | Abbott Laboratories | Diversified MedTech |
| BAX | Baxter International | Critical Care |
| RMD | ResMed | Respiratory & Sleep |
| INSP | Inspire Medical | Neurostimulation |
| PEN | Penumbra | Neurovascular |
| ATEC | Alphatec Holdings | Spine Surgery |
| GMED | Globus Medical | Spine & Robotics |
| ALC | Alcon | Ophthalmic Devices |
| ILMN | Illumina | Genomics |

## Key Data Quality Findings
Working directly with raw SEC XBRL data surfaces several important 
normalization challenges:

**Duplicate Filings**
Each fiscal year typically contains 3+ rows per metric due to overlapping 
10-K and amended filings. Resolved using PostgreSQL `DISTINCT ON` with 
`ORDER BY period_end DESC` to retain the most recently filed value.

**Inconsistent Gross Profit Tagging**
Four companies (ABT, MDT, ZBH, GMED) do not explicitly tag 
`us-gaap:GrossProfit` in recent filings. A unified view handles both 
direct reporting and Revenue minus COGS calculation depending on 
availability.

**Post-Merger Reporting Gaps**
GMED (Globus Medical, post-NuVasive merger 2023) shows incomplete 
gross profit tagging for FY2024-2025, a common artifact when combined 
entities restructure their SEC reporting format.

**Fiscal Year Zero Rows**
Some rows contain `fiscal_year = 0` due to SEC filing edge cases where 
the period cannot be mapped to a standard year. Filtered out using 
`WHERE fiscal_year > 2000`.

**Revenue Concept Variations**
Companies use different XBRL tags for top-line revenue including 
`us-gaap:Revenues` and 
`us-gaap:RevenueFromContractWithCustomerExcludingAssessedTax`. 
Queries account for both.

## Project Status
- [x] Automated multi-company ETL pipeline
- [x] PostgreSQL master table with 400k+ rows
- [x] Data quality audit across all 19 companies
- [x] Deduplication via SQL views
- [ ] Unified gross profit view (direct + calculated)
- [ ] Gross margin ratio analysis
- [ ] CSV export for Tableau Public
- [ ] Quarterly automation via cron job
- [ ] ClinicalTrials.gov pipeline integration

## Roadmap
**Phase 1 — Financial Analysis (Current)**
Build cross-company gross margin, R&D intensity, and operating leverage 
views across the MedTech universe.

**Phase 2 — Visualization**
Export clean SQL views to CSV and build Tableau Public dashboards for 
peer benchmarking.

**Phase 3 — Pipeline Expansion**
Extend the pipeline to Big Pharma and High Tech sectors for cross-industry 
comparison.

**Phase 4 — Clinical Pipeline Integration**
Add a ClinicalTrials.gov data extractor to correlate R&D spend with 
active clinical trial activity by company and therapeutic area.

## Author
Alexandro Silva
[github.com/silveral8](https://github.com/silveral8)