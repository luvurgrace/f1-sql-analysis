from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()

url = URL.create(
    "mysql+pymysql",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", 3306)),
    database=os.getenv("DB_NAME", "f1"),
)

engine = create_engine(url)

data_dir = Path(__file__).resolve().parent.parent / "data"

for csv in sorted(data_dir.glob("*.csv")):
    print(f"Loading {csv.name}...")

    df = pd.read_csv(csv, na_values=["\\N"])

    df.to_sql(
        csv.stem,
        engine,
        if_exists="replace",
        index=False,
        chunksize=10000,
    )

    print(f"{csv.stem}: {len(df)} rows")