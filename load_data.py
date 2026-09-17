import pandas as pd
import sqlite3
import os

# Step 1: Connect to (or create) the SQLite database file
conn = sqlite3.connect('data/olist.db')

# Step 2: List all your CSV files and what table name each should become
csv_files = {
    'orders': 'olist_orders_dataset.csv',
    'order_items': 'olist_order_items_dataset.csv',
    'customers': 'olist_customers_dataset.csv',
    'sellers': 'olist_sellers_dataset.csv',
    'products': 'olist_products_dataset.csv',
    'order_payments': 'olist_order_payments_dataset.csv',
    'order_reviews': 'olist_order_reviews_dataset.csv',
    'geolocation': 'olist_geolocation_dataset.csv',
    'category_translation': 'product_category_name_translation.csv'
}

# Step 3: Loop through each CSV, load it, and write it into the database
for table_name, file_name in csv_files.items():
    file_path = os.path.join('data', file_name)
    df = pd.read_csv(file_path)
    df.to_sql(table_name, conn, if_exists='replace', index=False)
    print(f"Loaded {table_name}: {len(df)} rows")

# Step 4: Close the connection
conn.close()
print("Done. olist.db created inside the data folder.")