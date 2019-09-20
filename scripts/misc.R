conflictRules("dplyr", mask.ok = c("filter", "lag", "intersect", "setdiff", "setequal", "union"))
library(tidyverse)
library(lubridate, include.only = c("year", "month", "mday",
                                    "hour", "minute", "second"))
library(fs)

requireNamespace("processx", quietly = TRUE)

# Source all files in the R directory
dir_walk("R", source)

ed2in_in <- read_ed2in("ED2IN")

obs_times <- c(
  seq(ISOdatetime(1902, 6, 1, 12, 0, 0, "UTC"),
      ISOdatetime(2002, 12, 31, 11, 59, 0, "UTC"),
      by = "1 day")
) %>%
  map_df(list(year = year, month = month, day = mday,
               hour = hour, minute = minute, second = second),
          exec, x = .)
## obs_times <- tibble(
##   year = 1902,
##   month = 6,
##   day = 1:15,
##   hour = 12,
##   minute = 0,
##   second = 0
## )
obs_file <- path("input", "obstime.time")
write_tsv(obs_times, obs_file)

soil_data <- read.csv(file.path(
  "~", "Projects", "forte_project", "fortebaseline",
  "analysis",
  "data",
  "derived-data",
  "soil-moisture.csv"
), header = TRUE, stringsAsFactors = FALSE) %>%
  # Make depth negative
  dplyr::mutate(depth = -depth) %>%
  # Start with deepest layer
  dplyr::arrange(depth)

ed2in <- ed2in_in %>%
  modify_ed2in(
    start_date = "1902-06-01",
    end_date = "1902-08-30",
    IOOUTPUT = 0,
    ITOUTPUT = 0,
    IMOUTPUT = 3,
    OBSTIME_DB = file.path("/data", obs_file),
    OUTFAST = 0,
    DTLSM = 900,
    RADFRQ = 900,
    FRQFAST = 10800,
    INTEGRATION_SCHEME = 1,
    IADD_COHORT_MEANS = 1,
    SLZ = soil_data[["depth"]],
    SLMSTR = soil_data[["slmstr"]],
    add_if_missing = TRUE,
    NSLCON = 1, # Sand
    SLXCLAY = 0.01,
    SLXSAND = 0.92,
    # Soil moisture data from Ameriflux
    # See analysis/scripts/soil-moisture.R
    NZG = nrow(soil_data),
    SLZ = soil_data[["depth"]],
    SLMSTR = soil_data[["slmstr"]]
  )
system.time(
  p <- run_ed(ed2in, echo = TRUE)
)

grep("Total elapsed time", pout, value = TRUE)
pout <- p$stdout %>%
  str_split("\n") %>%
  .[[1]] %>%
  str_remove(".*?\\|") %>%
  str_remove("\033\\[0m")
i <- grep("Each sample counts", pout)
pout %>%
  tail(-i) %>%
  head(30) %>%
  writeLines()


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

f <- "output/analysis-I-1902-06-01-120000-g01.h5"
nc <- ncdf4::nc_open(f)

ncmeta::nc_dims(f)

library(tidync)
out <- tidync(f) %>%
  activate("D6,D2") %>%
  hyper_tibble()
