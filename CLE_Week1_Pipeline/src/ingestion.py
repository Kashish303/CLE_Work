
import os
import logging
import mysql.connector
import psycopg

from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
BATCH_SIZE = 25

# Create logs directory if it does not exist
os.makedirs("logs", exist_ok=True)

# Configure logging
logging.basicConfig(
    filename="logs/ingestion.log",
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    encoding="utf-8"
)

logger = logging.getLogger(__name__)


def run_ingestion():

    mysql_conn = None
    pg_conn = None
    source_cursor = None
    target_cursor = None

    try:
        logger.info("========== INGESTION STARTED ==========")

        # 1. Connect to MySQL source
        mysql_conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=int(os.getenv("MYSQL_PORT")),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )

        logger.info("Connected to MySQL source successfully.")

        # 2. Connect to PostgreSQL target
        pg_conn = psycopg.connect(
            host=os.getenv("POSTGRES_HOST"),
            port=int(os.getenv("POSTGRES_PORT")),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
            dbname=os.getenv("POSTGRES_DATABASE")
        )

        logger.info("Connected to PostgreSQL target successfully.")

        # 3. Create cursors
        source_cursor = mysql_conn.cursor()
        target_cursor = pg_conn.cursor()

        # 4. Extract data from MySQL
        source_cursor.execute("""
            SELECT
                customer_id,
                customer_unique_id,
                customer_zip_code_prefix,
                customer_city,
                customer_state
            FROM customers
        """)

        logger.info("Source query executed successfully.")

        total_records = 0
        batch_number = 0

        # 5. Fetch and load records in batches
        while True:

            batch = source_cursor.fetchmany(BATCH_SIZE)

            if not batch:
                break

            batch_number += 1

            target_cursor.executemany("""
                INSERT INTO public.customers (
                    customer_id,
                    customer_unique_id,
                    customer_zip_code_prefix,
                    customer_city,
                    customer_state
                )
                VALUES (%s, %s, %s, %s, %s)

                ON CONFLICT (customer_id)
                DO UPDATE SET
                    customer_unique_id = EXCLUDED.customer_unique_id,
                    customer_zip_code_prefix = EXCLUDED.customer_zip_code_prefix,
                    customer_city = EXCLUDED.customer_city,
                    customer_state = EXCLUDED.customer_state
            """, batch)

            # Commit current batch
            pg_conn.commit()

            total_records += len(batch)

            logger.info(
                f"Batch {batch_number} completed: "
                f"{len(batch)} records loaded."
            )

        logger.info("Ingestion completed successfully!")
        logger.info(f"Total batches processed: {batch_number}")
        logger.info(f"Total records transferred: {total_records}")
        logger.info("========== INGESTION FINISHED ==========")

    except Exception:

        if pg_conn:
            pg_conn.rollback()

        logger.exception("INGESTION FAILED!")

    finally:

        # Close source cursor
        if source_cursor:
            source_cursor.close()

        # Close target cursor
        if target_cursor:
            target_cursor.close()

        # Close MySQL connection
        if mysql_conn and mysql_conn.is_connected():
            mysql_conn.close()
            logger.info("MySQL connection closed.")

        # Close PostgreSQL connection
        if pg_conn:
            pg_conn.close()
            logger.info("PostgreSQL connection closed.")


if __name__ == "__main__":
    run_ingestion()
