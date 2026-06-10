import pandas as pd
from sqlalchemy import create_engine

print("🔄 Connecting to Postgres and extracting clean financials view...")

# 1. Connect to your local database
engine = create_engine('postgresql://avsilva@localhost:5432/postgres')

# 2. Write the exact SQL query you want to visualize in
# 