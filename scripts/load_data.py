from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
import pandas as pd
import os

load_dotenv()

engine = create_engine(
    f"mysql+pymysql://{os.getenv('MYSQL_USER')}:"
    f"{os.getenv('MYSQL_PASSWORD')}@"
    f"{os.getenv('MYSQL_HOST')}:"
    f"{os.getenv('MYSQL_PORT')}/"
    f"{os.getenv('MYSQL_DATABASE')}"
)

for csv in sorted(Path("data").glob("*.csv")):
    df = pd.read_csv(csv, na_values=["\\N"])
    df.to_sql(
        csv.stem,
        engine,
        if_exists="replace",
        index=False,
        chunksize=10000
    )
    print(f"{csv.stem}: {len(df)} rows")