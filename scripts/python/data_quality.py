"""
Data quality validation using Great Expectations
Ensures data meets quality standards before processing
"""
import great_expectations as gx
from great_expectations.dataset import PandasDataset
import pandas as pd

def validate_data_quality(df: pd.DataFrame) -> dict:
    """
    Run data quality checks on DataFrame
    
    Returns:
        dict: Validation results with pass/fail status
    """
    print("🔍 Running data quality validations...")
    
    # Wrap DataFrame with Great Expectations
    ge_df = PandasDataset(df)
    
    results = {
        'passed': [],
        'failed': [],
        'warnings': []
    }
    
    # Example expectations (customize for your data)
    
    # 1. Check for required columns
    try:
        ge_df.expect_table_columns_to_match_ordered_list([
            'id', 'name', 'value', 'timestamp'
        ])
        results['passed'].append('Required columns present')
    except:
        results['failed'].append('Missing required columns')
    
    # 2. Check for nulls in critical columns
    try:
        ge_df.expect_column_values_to_not_be_null('id')
        results['passed'].append('No nulls in id column')
    except:
        results['failed'].append('Nulls found in id column')
    
    # 3. Check value ranges
    try:
        ge_df.expect_column_values_to_be_between('value', min_value=0, max_value=1000)
        results['passed'].append('Values within expected range')
    except:
        results['warnings'].append('Some values outside expected range')
    
    # 4. Check for duplicates
    try:
        ge_df.expect_column_values_to_be_unique('id')
        results['passed'].append('No duplicate IDs')
    except:
        results['failed'].append('Duplicate IDs found')
    
    # 5. Check data types
    try:
        ge_df.expect_column_values_to_be_of_type('id', 'int')
        results['passed'].append('Correct data types')
    except:
        results['warnings'].append('Unexpected data types')
    
    # Print summary
    print(f"✅ Passed: {len(results['passed'])}")
    print(f"❌ Failed: {len(results['failed'])}")
    print(f"⚠️  Warnings: {len(results['warnings'])}")
    
    if results['failed']:
        print("\n❌ Failed checks:")
        for check in results['failed']:
            print(f"   - {check}")
    
    return results

def create_data_quality_suite(data_path: str):
    """
    Create a reusable Expectation Suite for data validation
    """
    print(f"📋 Creating data quality suite for {data_path}...")
    
    context = gx.get_context()
    
    # Create datasource
    datasource = context.sources.add_pandas("pandas_datasource")
    
    # Create expectation suite
    suite = context.add_expectation_suite("data_quality_suite")
    
    print("✅ Data quality suite created")
    print("   Customize expectations in the suite for your data")

if __name__ == "__main__":
    # Example: Load data and validate
    # df = pd.read_csv("data/raw/input.csv")
    # results = validate_data_quality(df)
    
    # If validation passes, proceed with pipeline
    # if not results['failed']:
    #     print("✅ Data quality checks passed!")
    #     # Continue with data processing...
    # else:
    #     print("❌ Data quality issues found!")
    #     # Alert, log, or stop pipeline
    
    print("Data quality validation module ready")
