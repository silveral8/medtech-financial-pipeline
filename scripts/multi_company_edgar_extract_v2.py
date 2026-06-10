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
    {"ticker": "ISRG", "industry": "MedTech"},
    #{"ticker": "SYK", "industry": "MedTech"},
    #{"ticker": "ZBH", "industry": "MedTech"},
    #{"ticker": "ALC", "industry": "MedTech"},
    #{"ticker": "BAX", "industry": "MedTech"},
    #{"ticker": "DXCM", "industry": "MedTech"},
    #{"ticker": "ATEC", "industry": "MedTech"},
    #{"ticker": "ILMN", "industry": "Genomics"},
    #{"ticker": "GMED", "industry": "MedTech"},
    #{"ticker": "", "industry": "MedTech"}
]

print("🚀 Initializing Streamlined Multi-Industry Data Pipeline...")

for comp in target_universe:
    ticker = comp["ticker"]
    industry = comp["industry"]

    try:
        print(f"Connecting to EDGAR for {ticker}...")
        company = Company(ticker)
        
        # 4. Use to_dataframe() to match your original table structure exactly
        facts_df = company.get_facts().to_dataframe()

        # 5. Clean column text formatting so PostgreSQL matches
        facts_df.columns = [c.lower().replace(' ', '_').replace('-', '_') for c in facts_df.columns]

        # 6. Inject our tracking tags
        facts_df['ticker'] = ticker
        facts_df['industry'] = industry

        print(f"📈 Extracted {len(facts_df)} financial rows for {ticker}. Streaming...")

        # 7. Append rows into our master unified data table
        facts_df.to_sql('apple_facts', engine, if_exists='append', index=False)
        print(f"✅ Successfully integrated {ticker} ({industry})!\n")

    except Exception as e:
        # This will now print the EXACT reason it skipped so we can see it in the terminal
        print(f"❌ CRITICAL ERROR for {ticker}: {e}\n")
        
print("🏆 Pipeline execution completed.")