"""
Multi-format data processing pipeline
Handles: CSV, JSON, Parquet, XML, Avro, Excel
"""
import pandas as pd
import polars as pl
import duckdb
import xmltodict
import json
from pathlib import Path

class DataPipeline:
    """
    Unified interface for processing multiple data formats
    Optimized for DataOps workflows
    """
    
    def __init__(self, output_dir: str = "data/processed"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.con = duckdb.connect()
    
    def read_csv(self, file_path: str) -> pd.DataFrame:
        """Read CSV - fastest with Polars for large files"""
        print(f"📄 Reading CSV: {file_path}")
        df = pl.read_csv(file_path).to_pandas()
        print(f"✅ Loaded {len(df):,} rows, {len(df.columns)} columns")
        return df
    
    def read_json(self, file_path: str) -> pd.DataFrame:
        """Read JSON/JSONL"""
        print(f"📄 Reading JSON: {file_path}")
        
        # Try JSONL first
        try:
            df = pd.read_json(file_path, lines=True)
        except:
            df = pd.read_json(file_path)
        
        print(f"✅ Loaded {len(df):,} rows")
        return df
    
    def read_parquet(self, file_path: str) -> pd.DataFrame:
        """Read Parquet - native format for analytics"""
        print(f"📄 Reading Parquet: {file_path}")
        df = pd.read_parquet(file_path)
        print(f"✅ Loaded {len(df):,} rows")
        return df
    
    def read_xml(self, file_path: str, record_path: str = None) -> pd.DataFrame:
        """Read XML - converts to DataFrame"""
        print(f"📄 Reading XML: {file_path}")
        
        with open(file_path, 'r') as f:
            xml_dict = xmltodict.parse(f.read())
        
        # Navigate to records if path provided
        if record_path:
            for key in record_path.split('.'):
                xml_dict = xml_dict[key]
        
        # Convert to DataFrame
        if isinstance(xml_dict, list):
            df = pd.DataFrame(xml_dict)
        else:
            df = pd.DataFrame([xml_dict])
        
        print(f"✅ Loaded {len(df):,} rows")
        return df
    
    def read_excel(self, file_path: str, sheet_name: str = 0) -> pd.DataFrame:
        """Read Excel file"""
        print(f"📄 Reading Excel: {file_path}")
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        print(f"✅ Loaded {len(df):,} rows")
        return df
    
    def write_parquet(self, df: pd.DataFrame, filename: str):
        """Write Parquet - most efficient for analytics"""
        output_path = self.output_dir / filename
        df.to_parquet(output_path, compression='snappy', index=False)
        
        # Get file size
        size_mb = output_path.stat().st_size / (1024 * 1024)
        print(f"✅ Wrote Parquet: {output_path} ({size_mb:.2f} MB)")
    
    def write_json(self, df: pd.DataFrame, filename: str, lines: bool = True):
        """Write JSON/JSONL"""
        output_path = self.output_dir / filename
        df.to_json(output_path, orient='records', lines=lines, force_ascii=False)
        print(f"✅ Wrote JSON: {output_path}")
    
    def write_csv(self, df: pd.DataFrame, filename: str):
        """Write CSV"""
        output_path = self.output_dir / filename
        df.to_csv(output_path, index=False)
        print(f"✅ Wrote CSV: {output_path}")
    
    def transform_with_duckdb(self, query: str) -> pd.DataFrame:
        """
        Transform data using DuckDB SQL
        Efficient for complex joins and aggregations
        """
        print(f"🦆 Running DuckDB query...")
        result = self.con.execute(query).df()
        print(f"✅ Result: {len(result):,} rows")
        return result
    
    def profile_data(self, df: pd.DataFrame) -> dict:
        """
        Quick data profiling
        Returns statistics about the dataset
        """
        profile = {
            'rows': len(df),
            'columns': len(df.columns),
            'memory_mb': df.memory_usage(deep=True).sum() / (1024 * 1024),
            'dtypes': df.dtypes.value_counts().to_dict(),
            'missing_values': df.isnull().sum().to_dict(),
            'duplicates': df.duplicated().sum()
        }
        
        print(f"📊 Data Profile:")
        print(f"   Rows: {profile['rows']:,}")
        print(f"   Columns: {profile['columns']}")
        print(f"   Memory: {profile['memory_mb']:.2f} MB")
        print(f"   Duplicates: {profile['duplicates']:,}")
        
        return profile

# Example usage
if __name__ == "__main__":
    pipeline = DataPipeline()
    
    # Read various formats
    # df_csv = pipeline.read_csv("data/raw/input.csv")
    # df_json = pipeline.read_json("data/raw/input.json")
    # df_parquet = pipeline.read_parquet("data/raw/input.parquet")
    # df_xml = pipeline.read_xml("data/raw/input.xml", record_path="root.items")
    # df_excel = pipeline.read_excel("data/raw/input.xlsx", sheet_name="Sheet1")
    
    # Profile data
    # pipeline.profile_data(df_csv)
    
    # Transform with DuckDB
    # result = pipeline.transform_with_duckdb("""
    #     SELECT category, COUNT(*) as count, AVG(amount) as avg_amount
    #     FROM df_csv
    #     GROUP BY category
    #     ORDER BY count DESC
    # """)
    
    # Write outputs
    # pipeline.write_parquet(result, "summary.parquet")
    # pipeline.write_json(result, "summary.json")
    
    print("✅ Pipeline ready for use")
