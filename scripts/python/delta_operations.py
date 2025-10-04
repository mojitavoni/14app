"""
Delta Lake operations with Python
Read/Write/Update Delta tables with DuckDB
"""
from deltalake import DeltaTable, write_deltalake
import pandas as pd
import duckdb
from pathlib import Path

def create_delta_table(data_path: str, table_name: str):
    """
    Create a new Delta Lake table from CSV
    
    Args:
        data_path: Path to source CSV file
        table_name: Name for Delta table directory
    """
    print(f"📊 Creating Delta table: {table_name}")
    
    # Read CSV with Pandas
    df = pd.read_csv(data_path)
    
    # Write as Delta Lake table
    delta_path = f"data/processed/{table_name}"
    write_deltalake(delta_path, df, mode="overwrite")
    
    print(f"✅ Created Delta table at {delta_path}")
    print(f"   Rows: {len(df):,}")
    print(f"   Columns: {list(df.columns)}")
    
    return delta_path

def query_delta_with_duckdb(delta_path: str):
    """
    Query Delta Lake table using DuckDB
    Delta extension provides efficient reading
    """
    print(f"🦆 Querying Delta table with DuckDB...")
    
    con = duckdb.connect()
    
    # Install and load delta extension
    con.execute("INSTALL delta;")
    con.execute("LOAD delta;")
    
    # Query Delta table
    result = con.execute(f"""
        SELECT * FROM delta_scan('{delta_path}')
        LIMIT 10
    """).df()
    
    print(f"✅ Query results:\n{result}")
    
    con.close()
    return result

def update_delta_table(delta_path: str):
    """
    Append new data to existing Delta table
    Delta Lake handles ACID transactions
    """
    print(f"➕ Appending to Delta table...")
    
    # Load existing table
    dt = DeltaTable(delta_path)
    
    # Create new data
    new_data = pd.DataFrame({
        'id': [999],
        'value': ['new_record'],
        'timestamp': [pd.Timestamp.now()]
    })
    
    # Append (ACID transaction)
    write_deltalake(delta_path, new_data, mode="append")
    
    print(f"✅ Appended {len(new_data)} row(s)")
    print(f"   Current version: {dt.version()}")

def time_travel_delta(delta_path: str, version: int = 0):
    """
    Read historical version of Delta table
    Delta Lake maintains full history
    """
    print(f"⏰ Time travel to version {version}...")
    
    dt = DeltaTable(delta_path, version=version)
    df = dt.to_pandas()
    
    print(f"✅ Retrieved version {version}")
    print(f"   Rows: {len(df):,}")
    print(f"   History: {dt.history()}")
    
    return df

if __name__ == "__main__":
    # Example usage
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python delta_operations.py <csv_file>")
        sys.exit(1)
    
    csv_file = sys.argv[1]
    table_name = "example_delta"
    
    # Create Delta table
    delta_path = create_delta_table(csv_file, table_name)
    
    # Query with DuckDB
    query_delta_with_duckdb(delta_path)
    
    # Update (append)
    # update_delta_table(delta_path)
    
    # Time travel
    # time_travel_delta(delta_path, version=0)
