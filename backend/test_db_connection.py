import psycopg2

DB_URL = "postgresql://raguser:raguser123@localhost:5432/rag_db_utf8"

try:
    conn = psycopg2.connect(DB_URL)
    print("✅ DB connection successful!")
    conn.close()
except Exception as e:
    print(f"❌ DB connection failed: {e}")
