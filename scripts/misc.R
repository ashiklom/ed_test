library(tidyverse)
library(fs)

# Source all files in the R directory
dir_walk("R", source)

ed2in_in <- read_ed2in("ED2IN")

obs_times <- tibble(
  year = 1902,
  month = 6,
  day = 1:15,
  hour = 12,
  minute = 0,
  second = 0
)
obs_file <- path("input", "obstime.time")
write_tsv(obs_times, obs_file)

ed2in <- ed2in_in %>%
  modify_ed2in(start_date = "1902-06-01",
               end_date = "1902-06-10",
               IOOUTPUT = 3,
               IMOUTPUT = 3,
               OBSTIME_DB = file.path("/data", obs_file),
               OUTFAST = 0,
               IADD_COHORT_MEANS = 1,
               add_if_missing = TRUE)
p <- run_ed(ed2in, echo = TRUE)

# Output files
dir_ls("output")

pat <- "RAD_PROF"
## ncdf4::nc_open("output/analysis-D-1902-06-01-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
## ncdf4::nc_open("output/analysis-E-1902-06-00-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
ncdf4::nc_open("output/analysis-I-1902-06-01-120000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
## ncdf4::nc_open("output/analysis-Q-1902-06-00-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
ncdf4::nc_open("output/analysis-T-1902-00-00-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
ncdf4::nc_open("output/analysis-Y-1902-00-00-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()
ncdf4::nc_open("output/history-S-1902-06-01-000000-g01.h5")$var %>% names() %>% grepl(pattern = pat) %>% any()

nc <- ncdf4::nc_open("output/analysis-I-1902-06-01-120000-g01.h5")
x <- ncdf4::ncvar_get(nc, "FMEAN_RAD_PROFILE_CO")
h <- ncdf4::ncvar_get(nc, "HITE")

## files <- dir_ls("output", regexp = "analysis-I")
## filename <- files[[1]]

## nc <- ncdf4::nc_open(filename)
