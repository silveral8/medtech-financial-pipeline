# Project Roadmap

## Sprint 1 — Data Quality & Core Views (Current)
*Goal: clean, reliable data ready for analysis*

Day 1
- Build unified gross profit view using CASE statement
- Handle both direct GrossProfit tag and Revenue minus COGS
- Test against all 19 tickers
- Commit: "Add unified gross profit SQL view"

Day 2
- Rename clean_apple_financials view to medtech_financials
- Update all associated queries to reflect new name
- Add gross margin % calculation (gross profit / revenue)
- Commit: "Rename views, add gross margin calculation"

Day 3
- Build R&D intensity view (R&D expense / revenue)
- Build operating margin view
- Test all three views across full peer set
- Commit: "Add R&D intensity and operating margin views"

Day 4
- Document all views in DATA_DICTIONARY.md
- Save all finalized SQL to queries/ folder with clean names
- Update EXPLORATION_LOG
- Commit: "Document views, update data dictionary"

---

## Sprint 2 — Analysis & Export
*Goal: meaningful cross-company analysis and first Tableau output*

Day 1
- Build summary analysis query combining all metrics
- Identify top and bottom performers by gross margin
- Flag anomalies (ABT 2024, BAX losses, GMED gaps)
- Commit: "Add cross-company summary analysis query"

Day 2
- Write export_for_tableau.py script
- Export clean views to CSV
- Verify CSV loads correctly in Tableau Public
- Commit: "Add Tableau CSV export script"

Day 3
- Build first Tableau dashboard
- Cross-company gross margin comparison bar chart
- R&D intensity scatter plot
- Commit: "Add Tableau export, document dashboard approach"

Day 4
- Screenshot or export Tableau visuals
- Add dashboard screenshots to README
- Update project status checkboxes in README
- Commit: "Update README with dashboard screenshots"

---

## Sprint 3 — Pipeline Hardening
*Goal: make the pipeline reliable and repeatable*

Day 1
- Rename apple_facts table to medtech_facts
- Update all scripts and views to reflect new table name
- Test full pipeline end to end
- Commit: "Rename master table to medtech_facts"

Day 2
- Add error handling and logging to extraction scripts
- Script should log which tickers succeeded and failed
- Commit: "Improve pipeline error handling and logging"

Day 3
- Set up quarterly cron job to automate data refresh
- Test that new rows append correctly without duplicates
- Commit: "Add quarterly automation via cron"

Day 4
- Write up how to run the full pipeline in README
- Add installation instructions and dependencies
- Commit: "Add pipeline setup and usage documentation"

---

## Sprint 4 — Expansion
*Goal: extend beyond MedTech*

Day 1
- Research Big Pharma peer set (PFE, MRK, LLY, ABBV, BMY)
- Add to extraction script
- Run pipeline for Pharma universe
- Commit: "Add Big Pharma universe to pipeline"

Day 2
- Verify Pharma data quality
- Check for same XBRL issues as MedTech
- Document findings in DATA_DICTIONARY
- Commit: "Pharma data quality audit"

Day 3
- Begin ClinicalTrials.gov API exploration
- Pull trial data for existing MedTech companies
- Store in new clinical_trials table
- Commit: "Add ClinicalTrials.gov extractor prototype"

Day 4
- Link clinical trial activity to R&D spend by company
- First cross-dataset analysis
- Commit: "First R&D to clinical trial correlation analysis"