# Benchmark methodology

1. Use the five CSV reports produced by the Phase 2 pandas task.
2. Convert each CSV to Parquet using pandas with the PyArrow engine and Snappy compression.
3. Compare exact logical values after normalizing loaded values to strings.
4. Compare physical file sizes in bytes.
5. Warm up each reader once, then measure 30 reads per format with `time.perf_counter()` and report the median in milliseconds.
6. Interpret results cautiously: the included sample is small, so filesystem and startup overhead can dominate. Larger datasets and column-selective queries are better for assessing Parquet's analytical advantages.

The benchmark script produces the actual machine-specific measurements when run on the user's computer. No timing values are hard-coded or invented.
