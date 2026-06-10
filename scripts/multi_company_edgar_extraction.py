import os
import pandas as pd
from sqlalchemy import create_engine
from edgar import set_identity, Company

# 1. Secure identity declaration for EDGAR API
set_identity("AlphaMEdTechPipeline silvadatadev26@gmail.com")

# 2. Establish connection to your local PostgreSQL instance
engine = create_engine('postgresql://avsilva:@localhost:5432/postgres')

# 3. Define the multi-industry universe you want to pull down
target_universe = [
    {"ticker": "PODD", "industry": "MedTech"},
    {"ticker": "ABT", "industry": "MedTech"},
    {"ticker": "TNDM", "industry": "MedTech"},
    {"ticker": "INSP", "industry": "MedTech"},
    {"ticker": "RMD", "industry": "MedTech"},
    {"ticker": "EW", "industry": "MedTech"},
    {"ticker": "BSX", "industry": "MedTech"},
    {"ticker": "MDT", "industry": "MedTech"},
    {"ticker": "PEN", "industry": "MedTech"},
    {"ticker": "SENS", "industry": "MedTech"}
]

print("Initializing Master Multi-Industry Financial Data Pipeline...")

for comp in target_universe:
    ticker = comp["ticker"]
    industry = comp["industry"]
    print(f"Processing {ticker} in {industry} industry...")

    try:
        print(f"Connecting to EDGAR...Processing {ticker} in {industry} industry...")
        # 4. Fetch the company data using EDGAR API
        company = Company(ticker)
        financials = company.get_financials()

        # 5. Convert financial data to a DataFrame
        facts_df = company.get_facts().to_pandas()

        # 6. Clean column text formatting so PostgreSQL doesn't throw errors
        facts_df.columns = [c.lower().replace(' ', '_').replace('-', '_') for c in facts_df.columns]

        # 7. Inject our critical metadata for multi-industry analysis
        facts_df['ticker'] = ticker
        facts_df['industry'] = industry

        print(f"Extracted {len(facts_df)} financial rows. Streaming to master warehouse...")

        # 8. Append rows into our master unified data table
        facts_df.to_sql('apple_facts', engine, if_exists='append', index=False)
        print(f"Successfully appended {ticker} ({industry}) data to master warehouse.\n")

    except Exception as e:
        print(f"Error processing {ticker} in {industry} industry: {e}\n")
        
print("Master Multi-Industry Financial Data Pipeline execution completed.")