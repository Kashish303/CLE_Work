import sys, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"src"))
from pandas_sql_comparison import load_tables,build_reports

class PandasReportTests(unittest.TestCase):
    def test_five_reports(self):
        reports=build_reports(load_tables(ROOT/"data/source"))
        self.assertEqual(len(reports),5)
        self.assertEqual(int(reports["01_customer_count_by_city"].customer_count.sum()),8)
        self.assertGreater(len(reports["03_revenue_by_category"]),0)
if __name__=="__main__": unittest.main()
