
import os
import mysql.connector
import psycopg
from dotenv import load_dotenv

# Load credentials from .env
load_dotenv()

# 1. Test MySQL connection
try:
    mysql_conn = mysql.connector.connect(
        host=os.getenv("MYSQL_HOST"),
        port=int(os.getenv("MYSQL_PORT")),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )

    print("MySQL connection successful!")

    cursor = mysql_conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM customers")
    print("MySQL customer records:", cursor.fetchone()[0])

    cursor.close()
    mysql_conn.close()

except Exception as e:
    print("MySQL connection failed:", e)


# 2. Test PostgreSQL connection
try:
    pg_conn = psycopg.connect(
        host=os.getenv("POSTGRES_HOST"),
        port=int(os.getenv("POSTGRES_PORT")),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        dbname=os.getenv("POSTGRES_DATABASE")
    )

    print("PostgreSQL connection successful!")

    cursor = pg_conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM public.customers")
    print("PostgreSQL customer records:", cursor.fetchone()[0])

    cursor.close()
    pg_conn.close()

except Exception as e:
    print("PostgreSQL connection failed:", e)
