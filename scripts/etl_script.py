import pandas as pd
from sqlalchemy import create_engine
from edgar import set_identity, Company

# 1. Declare your identity to the SEC EDGAR system (Required by SEC)
set_identity("Alexandro Silva asilva@example.com")

try:
    print("Connecting to SEC EDGAR...")
    # 2. Fetch data for a target company (e.g., Apple)
    company = Company("AAPL")
    print(f"Extracting financial facts for {company.name}...")
    facts = company.get_facts().to_dataframe()

    # Clean up column names so SQL doesn't complain about spaces or capital letters
    facts.columns = [c.lower().replace(' ', '_') for c in facts.columns]

    print(f"Successfully extracted {len(facts)} rows of data.")

    # 3. Connect to your existing local 'postgres' database
    # Because this is a default local install, no password is required.
    engine = create_engine('postgresql://avsilva:@localhost:5432/postgres')

    print("Streaming data to local PostgreSQL...")
    # 4. Push data to a table named 'apple_facts'
    facts.to_sql('apple_facts', engine, if_exists='replace', index=False)
    print("Success! The data has been uploaded to your local 'postgres' database.")

except Exception as e:
    print(f"An error occurred: {e}")