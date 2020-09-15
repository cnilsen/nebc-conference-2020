
library(bigrquery)
library(tidyverse)
grid = "ID18_V8"

hru = "hru250"

sql_stmt <- paste0("
select
    year, ",hru," as hru, q10, q25, q50, q75, q90, q95, q98, q99
FROM (
  SELECT
    grid, year,
  PERCENTILE_DISC(",hru,",
      0.50) OVER (PARTITION BY grid, year) AS q50,
      PERCENTILE_DISC(",hru,",
      0.75) OVER (PARTITION BY grid, year) AS q75,
      PERCENTILE_DISC(",hru,",
      0.90) OVER (PARTITION BY grid, year) AS q90,
      PERCENTILE_DISC(",hru,",
      0.95) OVER (PARTITION BY grid, year) AS q95,
      PERCENTILE_DISC(",hru,",
      0.98) OVER (PARTITION BY grid, year) AS q98,
    PERCENTILE_DISC(",hru,",
      0.99) OVER (PARTITION BY grid, year) AS q99
  FROM
    hydrology.gfdl_surfaceQ)
where grid = '",grid,"' 
GROUP BY
  grid, year,  q50, q75, q90, q95, q98, q99")


billing <- "tnc-data-v1"

tb <- bq_project_query(billing, sql_stmt)

df.quants <- bq_table_download(tb, max_results = Inf)
df.quants <- df.quants[df.quants$grid != "",]
saveRDS(df.quants,file="quantiles_all_years.rds")

