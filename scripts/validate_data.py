"""
Data validation script for 14app
Validates CSV files in data/raw directory
"""
import os
import sys
from pathlib import Path

def validate_csv_files():
    """Validate all CSV files in data/raw directory"""
    try:
        import duckdb
    except ImportError:
        print("⚠️  DuckDB not installed, skipping validation")
        return True
    
    data_dir = Path("data/raw")
    if not data_dir.exists():
        print("✅ No data directory found, skipping validation")
        return True
    
    csv_files = list(data_dir.glob("*.csv"))
    if not csv_files:
        print("✅ No CSV files to validate")
        return True
    
    print(f"📊 Validating {len(csv_files)} CSV file(s)...")
    
    con = duckdb.connect()
    all_valid = True
    
    for csv_file in csv_files:
        try:
            # Try to read the file
            result = con.execute(f"SELECT COUNT(*) FROM '{csv_file}'").fetchone()
            row_count = result[0]
            print(f"✅ {csv_file.name}: {row_count:,} rows")
        except Exception as e:
            print(f"❌ {csv_file.name}: INVALID - {str(e)}")
            all_valid = False
    
    return all_valid

if __name__ == "__main__":
    success = validate_csv_files()
    sys.exit(0 if success else 1)
