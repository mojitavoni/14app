"""
Example: DuckDB data processing with Python
"""
import duckdb
from pathlib import Path

def process_data(input_file: str, output_file: str):
    """
    Process CSV data using DuckDB and export results
    
    Args:
        input_file: Path to input CSV file
        output_file: Path to output Parquet file
    """
    # Connect to DuckDB (in-memory)
    con = duckdb.connect()
    
    # Create output directory
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    
    print(f"📊 Processing {input_file}...")
    
    # Example query - modify as needed
    query = f"""
    COPY (
        SELECT 
            *,
            CURRENT_TIMESTAMP as processed_at
        FROM '{input_file}'
        WHERE 1=1  -- Add filters here
        ORDER BY 1
    ) TO '{output_file}' (FORMAT PARQUET, COMPRESSION ZSTD);
    """
    
    con.execute(query)
    
    # Get statistics
    stats = con.execute(f"SELECT COUNT(*) as rows FROM '{input_file}'").fetchone()
    print(f"✅ Processed {stats[0]:,} rows")
    print(f"   Output: {output_file}")
    
    con.close()

if __name__ == "__main__":
    import sys
    
    input_file = sys.argv[1] if len(sys.argv) > 1 else "data/raw/input.csv"
    output_file = sys.argv[2] if len(sys.argv) > 2 else "data/output/result.parquet"
    
    process_data(input_file, output_file)
